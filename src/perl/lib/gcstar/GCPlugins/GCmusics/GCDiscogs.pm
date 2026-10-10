package GCPlugins::GCmusics::GCDiscogs;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2016-2020 Ilpiero
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
use JSON;

use GCPlugins::GCmusics::GCmusicsCommon;

{
    package GCPlugins::GCmusics::GCPluginDiscogs;

    use base 'GCPlugins::GCmusics::GCmusicsPluginsBase';
    use XML::Simple;

    # Token for Discogs API (profile / applications )
    use constant token => "OmlySInbXXKkXAFWqsTxkDJyiETWEhwcdFHDHruv";
    use constant resultsPerPage => "60";

    sub parse
    {
        my ($self, $page) = @_;

        my $json        = JSON->new->utf8;
        my $json_text   = $page;
        my $json_decoded = $json->decode( $json_text );

        my $key = $self->{searchField};
        if ($self->{parsingList})
        {
            my $release;

            if ($self->{searchField} eq 'title' && scalar @{$json_decoded->{results}} eq 0)
            {
                # check if the title is numeric
                $self->{searchWord} =~ s/[\-\+\s]//g;
                if ($self->{searchWord} =~ /^\d+$/)
                {
                    # search again as EAN
                    $self->{searchField} = 'ean';
                    $self->{nextUrl} = $self->getSearchUrl($self->{searchWord});
                }
                return;
            }
            foreach $release ( @{$json_decoded->{results}})
            {
                if ($release->{type} eq 'release' || $release->{type} eq 'master')
                {
                    $self->{itemIdx}++;
                    $self->{itemsList}[$self->{itemIdx}]->{url} = $release->{resource_url} if ($key eq 'artist' && $release->{type} eq 'master');
                    $self->{itemsList}[$self->{itemIdx}]->{url} = $release->{resource_url};
                    $self->{itemsList}[$self->{itemIdx}]->{release} = $release->{year};

                    my $found = index($release->{title},"-");
                    if ( $found >= 0 )
                    {
                        $self->{itemsList}[$self->{itemIdx}]->{title} = substr($release->{title}, $found +length('-'),length($release->{title})- $found -length('-'));
                        $self->{itemsList}[$self->{itemIdx}]->{title} =~ s/^\s+//;
                        $self->{itemsList}[$self->{itemIdx}]->{artist} = substr($release->{title}, 0, $found);
                        $self->{itemsList}[$self->{itemIdx}]->{artist} =~ s/\s+$//;
                   }
                   else
                   {
                        $self->{itemsList}[$self->{itemIdx}]->{title} = $release->{title};
                   }
                }
            }
        }
        else
        {
            if ($json_decoded->{main_release_url})
            {
                $self->{curInfo}->{nextUrl} = $json_decoded->{main_release_url};
                return;
            }

            $self->{curInfo}->{title} = $json_decoded->{title};
            $self->{curInfo}->{artist} = '';
            for my $art (@{$json_decoded->{artists}})
            {
                $self->{curInfo}->{artist} .= $art->{name}.', ';
            }
            $self->{curInfo}->{artist} =~ s/, $//;
            $self->{curInfo}->{producer} = '';
            $self->{curInfo}->{composer} = '';
            for my $rel (@{$json_decoded->{extraartists}})
            {
                $self->{curInfo}->{producer} .= $rel->{name}.', '
                    if $rel->{role} eq 'Producer';
                $self->{curInfo}->{composer} .= $rel->{name}.', '
                    if (($rel->{role} eq 'Composed By') || ($rel->{role} eq 'Score') || ($rel->{role} eq 'Songwriter') || ($rel->{role} eq 'Written-By'));
            }
            $self->{curInfo}->{producer} =~ s/, $//;
            $self->{curInfo}->{composer} =~ s/, $//;
            $self->{curInfo}->{release} = $json_decoded->{released};
            for my $track(@{$json_decoded->{'tracklist'}})
            {
                my $position = "";
                my $artists = "";
                # Sometimes the position is missing, which causes it to be an array
                if (!ref($track->{position}))
                {
                    $position = $track->{position};
                }
                for my $artist(@{$track->{artists}})
                {
                    $artists .= $artist->{name}.", ";
                }
                for my $artist(@{$track->{extraartists}})
                {
                    $artists .= $artist->{name}.", ";
                }
                $artists =~ s/, $//;
                if ($track->{type_} eq 'track')
                {
                    my $duree = $track->{duration};
                    $duree =~ /([0-9]+):([0-9]+)/;
                    my $duree2 = int($1*60 + $2);
                    $self->addTrack($track->{title}, $duree2, $position, $artists);
                }
                elsif ($track->{type_} eq 'index')
                {
                    for my $subtrack(@{$track->{sub_tracks}})
                    {
                        my $duree = $subtrack->{duration};
                        $duree =~ /([0-9]+):([0-9]+)/;
                        my $duree2 = int($1*60 + $2);
                        $self->addTrack($track->{title}." / ".$subtrack->{title},
                                        $duree2, $subtrack->{position}, $artists);
                    }
                }
            }
            $self->{curInfo}->{tracks} = $self->getTracks;
            $self->{curInfo}->{running} = $self->getTotalTime;

            for my $ident (@{$json_decoded->{identifiers}})
            {
                $self->{curInfo}->{ean} = $ident->{value} if $ident->{type} eq 'Barcode';
            }

            my $image = '';
            for my $cover (@{$json_decoded->{images}})
            {
                $image = $cover->{uri} if ( $image eq '' && $cover->{type} eq 'secondary' );
                $image = $cover->{uri} if ( $cover->{type} eq 'primary' );
            }
            # Change to small res cover
            $image =~ s/image\/R-/image\/R-150-/ if ( ! $self->{bigPics} );
            $self->{curInfo}->{cover} = $image;

            $self->{curInfo}->{label} = '';
            for my $label (@{$json_decoded->{labels}})
            {
                $self->{curInfo}->{label} .= $label->{name}.', '
                    if ! ($self->{curInfo}->{label} =~ /$label->{name}/ );
            }
            $self->{curInfo}->{label} =~ s/, $//;
            $self->{curInfo}->{genre} = '';
            for my $genre (@{$json_decoded->{genres}})
            {
                $self->{curInfo}->{genre} .= $genre.',';
            }
            $self->{curInfo}->{genre} =~ s/,$//;
            $self->{curInfo}->{origin} = $json_decoded->{country};
            $self->{curInfo}->{origin} =~ s/,$//;
            for my $format(@{$json_decoded->{formats}})
            {
                if (  $self->{curInfo}->{format} eq '')
                {
                    $self->{curInfo}->{format} = $format->{name};
                    $self->{curInfo}->{format} =~ s/,$//;
                }
            }
            $self->{curInfo}->{web} = "https://www.discogs.com/release/" . $json_decoded->{id};
        }
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
            release => 1
        };

        $self->{ua}->agent('GCstar/1.7.2 +http://www.gcstar.org');
        $self->{ua}->default_header('Authorization' => 'Discogs token='.token);

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

        $self->{searchWord} = $word;
        my $searchUrl = "https://api.discogs.com/database/search";

        my $searchVar = 'release_title';
        my $key = $self->{searchField};
        $searchVar = 'artist'  if ( $key eq 'artist' );
        $searchVar = 'label'   if ( $key eq 'label'  );
        $searchVar = 'barcode' if ( $key eq 'unique' );
        $searchVar = 'barcode' if ( $key eq 'ean'    );

        my $url = "$searchUrl?$searchVar=$word&per_page=".resultsPerPage."&page=1";

        return $url;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        $url = "http://www.discogs.com" if (!$url);

        return $url;
    }

    sub changeUrl
    {
        my ($self, $url) = @_;

        return $self->getItemUrl($url);
    }

    sub getName
    {
        return 'Discogs';
    }

    sub getAuthor
    {
        return 'TPF - ilpiero';
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
        return ['title', 'artist', 'label', 'unique', 'ean'];
    }
}

1;
