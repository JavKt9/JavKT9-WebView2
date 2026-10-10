package GCPlugins::GCmusics::GCMusicBrainz;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#
#  This file is part of GCstar.
#
#  GCstar is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  GCstar is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with GCstar; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
###################################################

use strict;
use utf8;

use GCPlugins::GCmusics::GCmusicsCommon;

{
    package GCPlugins::GCmusics::GCPluginMusicBrainz;

    use base 'GCPlugins::GCmusics::GCmusicsPluginsBase';
    use XML::Simple;
    use Locale::Country;
    use JSON qw( decode_json );

    sub parse
    {
        my ($self, $page) = @_;
        my $xml;
        my $xs = XML::Simple->new;
        if ($self->{parsingList})
        {
            $xml = $xs->XMLin($page,
                              ForceArray => ['release', 'event'],
                              KeyAttr => {'release' => ''});
            my $release;
            foreach $release ( @{ $xml->{'release-list'}->{release} } )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = 'http://musicbrainz.org/album/'.$release->{id}.'.html';
                $self->{itemsList}[$self->{itemIdx}]->{title} = $release->{title};
                if (ref($release->{'artist-credit'}->{'name-credit'}) eq "ARRAY")
                {
                    $self->{itemsList}[$self->{itemIdx}]->{artist} = $release->{'artist-credit'}->{'name-credit'}[0]->{artist}->{name};
                }
                else
                {
                    $self->{itemsList}[$self->{itemIdx}]->{artist} = $release->{'artist-credit'}->{'name-credit'}->{artist}->{name};
                }

                my $releaseDate='9999-12-31';
                if (ref($release->{'release-event-list'}->{'release-event'}) eq 'HASH')
                {
                    $releaseDate = $release->{'release-event-list'}->{'release-event'}->{date}
                       if (ref($release->{'release-event-list'}->{'release-event'}->{date}) ne 'HASH');
                }
                else
                {
                    $releaseDate = $release->{'release-event-list'}->{'release-event'}[0]->{date}
                       if (ref($release->{'release-event-list'}->{'release-event'}[0]->{date}) ne 'HASH');
                }

                $self->{itemsList}[$self->{itemIdx}]->{release} = $releaseDate
                    if $releaseDate ne '9999-12-31';
            }
        }
        else
        {
            # plugin with multiple passes : {curInfo}->{title} is set during the first pass
            if ($self->{curInfo}->{title})
            {
                # second pass is json from coverartarchive.org
                return if ($page eq '');
                my $resu = decode_json($page);
                for my $image (@{$resu->{images}})
                {
                    if ((!$self->{curInfo}->{cover}) || $image->{front})
                    {
                        $self->{curInfo}->{cover} = $image->{image};
                    }
                }
                return;
            }
            $xml = $xs->XMLin($page,
                              ForceArray => ['track', 'event', 'relation', 'relation-list','tag'],
                              KeyAttr => {'track' => ''});
            $self->{curInfo}->{title} = $xml->{release}->{title};
            $self->{curInfo}->{web} = 'http://musicbrainz.org/release/'.$xml->{release}->{id}.'.html';
            if (ref $xml->{release}->{'artist-credit'}->{'name-credit'} eq 'HASH')
            {
                $self->{curInfo}->{artist} = $xml->{release}->{'artist-credit'}->{'name-credit'}->{artist}->{name};
            }
            else
            {
                $self->{curInfo}->{artist} = $xml->{release}->{'artist-credit'}->{'name-credit'}[0]->{artist}->{name};
            }
            $self->{curInfo}->{ratingpress} = int($xml->{release}->{rating}->{content}) * 2;
            $self->{curInfo}->{producer} = '';
            $self->{curInfo}->{composer} = '';

            # Step through the relations
            for my $relation (@{$xml->{release}->{'relation-list'}})
            {
                if ($relation->{'target-type'} eq 'Artist')
                {
                    # Artist type relations
                    for my $rel (@{$relation->{relation}})
                    {
                        # Search for producer or composer relations
                        $self->{curInfo}->{producer} .= $rel->{artist}->{name}.', '
                            if $rel->{type} eq 'Producer';
                        $self->{curInfo}->{composer} .= $rel->{artist}->{name}.', '
                            if $rel->{type} eq 'Composer';
                    }
                }
                elsif ($relation->{'target-type'} eq 'Url')
                {
                    # Look for url type relations.
                    # Get covers from jamendo.
                    for my $rel (@{$relation->{relation}})
                    {
                        # Alternate cover art sites
                        if (($rel->{target} =~ m/jamendo.com/) && (!$self->{curInfo}->{cover}))
                        {
                            # Cover art should be on jamendo
                            $rel->{target} =~ /\/([0-9]+)$/;
                            my $id = $1;
                            if ($self->{bigPics})
                            {
                                $self->{curInfo}->{cover} = "http://img.jamendo.com/albums/$id/covers/1.0.jpg";
                            }
                            else
                            {
                                $self->{curInfo}->{cover} = "http://img.jamendo.com/albums/$id/covers/1.200.jpg";
                            }
                        }
                    }
                }
            }

            $self->{curInfo}->{producer} =~ s/, $//;
            $self->{curInfo}->{composer} =~ s/, $//;
            $self->{curInfo}->{ean} = $xml->{release}->{barcode} if $xml->{release}->{barcode};

            my $releaseDate;
            my $releaseLabel;
            my $releaseCountry;
            my $releaseFormat;
            my $releaseDateFromCompare='9999-12-12';
            $releaseDate = $xml->{release}->{date};
            $releaseCountry = $xml->{release}->{country};
            for my $releaseEvent (@{$xml->{release}->{'release-event-list'}->{event}})
            {
                my $releaseDateToCompare;
                # Check if musicbrainz only has the year, if so, set things up so we'll prefer
                # releases with the month & day over year-only releases
                if (length($releaseEvent->{date}) == 4)
                {
                    $releaseDateToCompare = $releaseEvent->{date}."-12-31";
                }
                else
                {
                    $releaseDateToCompare = $releaseEvent->{date};
                }

                if (($releaseDateToCompare lt $releaseDateFromCompare) ||
                        (($releaseDateToCompare eq $releaseDateFromCompare) &&
                            (($releaseEvent->{country} eq 'US') || ($releaseEvent->{country} eq 'GB'))))
                {
                    # Find the earliest release event, which has a month & day
                    # Big call, but we're probably more correct choosing a US or UK release if there's two
                    # release events with the same date, so prioritise them
                    $releaseDate = $releaseEvent->{date};
                    $releaseLabel = $releaseEvent->{label}->{name}
                        if $releaseEvent->{label};
                    $releaseCountry = code2country($releaseEvent->{country});
                    $releaseFormat = $releaseEvent->{format};
                    $releaseDateFromCompare = $releaseDateToCompare;
                }
            }

            $self->{curInfo}->{release} = $releaseDate;
            $self->{curInfo}->{label} = $releaseLabel;
            $self->{curInfo}->{origin} = $releaseCountry;
            $self->{curInfo}->{format} = $releaseFormat;
            if ($self->{curInfo}->{release} =~ m/\-.*\-/)
            {
                $self->{curInfo}->{release} = GCUtils::strToTime($self->{curInfo}->{release},"%Y-%m-%d", $self->getLang());
            }
            elsif ($self->{curInfo}->{release} =~ m/\-/)
            {
                $self->{curInfo}->{release} = GCUtils::strToTime($self->{curInfo}->{release},"%Y-%m", $self->getLang());
            }
            my $tracks;
            if (ref $xml->{release}->{'medium-list'}->{medium} eq 'ARRAY')
            {
                $tracks = $xml->{release}->{'medium-list'}->{medium}[0]->{'track-list'}->{track};
            }
            else
            {
                $tracks = $xml->{release}->{'medium-list'}->{medium}->{'track-list'}->{track};
            };
            for my $track(@{$tracks})
            {
                $self->addTrack($track->{recording}->{title}, $track->{length} / 1000,"");
            }
            $self->{curInfo}->{tracks} = $self->getTracks;
            $self->{curInfo}->{running} = $self->getTotalTime;

            for my $genre(@{$xml->{release}->{'tag-list'}->{tag}})
            {
                # Capitalize first letter of each word
                $genre->{content} =~ s/\b(\w+)\b/ucfirst($1)/ge;
                # Only add genres if they have more then 1 vote, strips out a lot of
                # weird/wrong tags
                push @{$self->{curInfo}->{genre}}, [$genre->{content}]
                        if ($genre->{count} > 1);
            }

            # If amazon artwork exists, use it
            if (($xml->{release}->{asin}) && (!$self->{curInfo}->{cover}))
            {
                if ($self->{bigPics})
                {
                    $self->{curInfo}->{cover} = 'http://images.amazon.com/images/P/'.$xml->{release}->{asin}.'.01.LZZZZZZZ.jpg'
                }
                else
                {
                    $self->{curInfo}->{cover} = 'http://images.amazon.com/images/P/'.$xml->{release}->{asin}.'.01.MZZZZZZZ.jpg'
                }
            }

            # Get other URL to try covers from coverartarchive.org
            if (!$self->{curInfo}->{cover})
            {
                $self->{curInfo}->{nextUrl} = "http://coverartarchive.org/release/".$xml->{release}->{id};
            }
        }
    }

    sub convertDate
    {
        my ($self, $date) = @_;
        $date =~ /([0-9]{4})-?([0-9]{2})?-?([0-9]{2})?/;
        return $3 .($3 ? '/' : '').$2.($2 ? '/' : '').$1;
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title => 1,
            artist => 1,
            release => 1,
            tracks => 1
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        return $html;
    }

    sub decodeEntitiesWanted
    {
        return 0;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        my $key = ($self->{searchField} eq 'unique') ? 'barcode:' : '';
        return "http://musicbrainz.org/ws/2/release/?query=$key$word";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url if $url;
        return "http://musicbrainz.org/";
    }

    sub changeUrl
    {
        my ($self, $url) = @_;
        $url =~ s|http://musicbrainz.org/album/(.*?)\.html|http://musicbrainz.org/ws/2/release/$1?inc=artists+recordings|;
        $url =~ s|http://musicbrainz.org/release/(.*?)\.html|http://musicbrainz.org/ws/2/release/$1?inc=artists+recordings|;
        return $url;
    }

    sub getName
    {
        return 'MusicBrainz';
    }

    sub getAuthor
    {
        return 'Tian';
    }

    sub getLang
    {
        return 'EN';
    }

    sub getCharset
    {
        my $self = shift;

        return "UTF-8";
    }

    sub getSearchCharset
    {
        my $self = shift;

        # Need urls to be double character encoded
        return "utf8";
    }

    sub convertCharset
    {
        my ($self, $value) = @_;
        return $value;
    }

    sub getNotConverted
    {
        my $self = shift;
        return [];
    }

    sub getSearchFieldsArray
    {
        return ['title', 'artist', 'unique'];
    }

    sub getEanField
    {
        return 'unique';
    }
    sub isPreferred
    {
        # Return status of 2 means plugin is default regardless of user's language
        return 2;
    }
}

1;
