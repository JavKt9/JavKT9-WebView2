package GCPlugins::GCfilms::GCIbs;
###################################################
#
#  Copyright 2008 t-storm
#  Copyright 2016-2019 Kerenoc
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

use GCPlugins::GCfilms::GCfilmsCommon;

{
    package GCPlugins::GCfilms::GCPluginIbs;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        if ($self->{parsingList})
        {
            if ($tagname eq 'li' && $attr->{class} =~ m/search-list-item/)
            {
                $self->{inside}->{movie} = 1;
            }
            elsif ($tagname eq "a" && $self->{inside}->{movie})
            {
                my $url = $attr->{href};
                $url =~ s/\?.*//;
                if (!$self->{alreadyListed}->{$url})
                {
                    $self->{inside}->{movie} = 1;
                    $self->{itemIdx}++;
                    $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                    $self->{alreadyListed}->{$url} = 1;
                }
            }
        }
        else
        {
            if ($tagname eq "a")
            {
                if ($attr->{href} =~ m|img.ibs.it/images|)
                {
                    $self->{curInfo}->{image} = $attr->{href};
                }
                elsif (0 && $attr->{href} =~ m/^\/film\/registi\//)
                {
                    $self->{inside}->{director} = 1;
                }
                elsif ($attr->{href} =~ m/^\/film\/attori\//)
                {
                    $self->{inside}->{actors}   = 1;
                    $self->{inside}->{roles}    = 0;
                    $self->{inside}->{director} = 0;
                }
                else
                {
                    $self->{inside}->{genre} = 1
                      if ($attr->{href} =~ m|/Sections/Genres/|)
                      && !($self->{curInfo}->{synopsis}
                        || $self->{curInfo}->{country}
                        || $self->{curInfo}->{time});
                }
            }
            elsif ($tagname eq 'td')
            {
                if ($attr->{class} eq 'lbarrasup')
                {
                    $self->{inside}->{movie} = 1;
                }
            }
            elsif ($tagname eq "div" && $attr->{id} eq "title")
            {
                $self->{inside}->{movie}  = 1;
            }
            elsif ($tagname eq 'ul')
            {
                if ($attr->{class} =~ m/category-list/ || $attr->{class} eq 'levels')
                {
                    $self->{inside}->{genre} = 1;
                }
            }
            elsif ($tagname eq 'div')
            {
                $self->{inside}->{movie} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{class} =~ m/allcontent/)
            {
            	# longuest description for movie
                $self->{inside}->{synopsis} = 1;
                $self->{curInfo}->{synopsis} = '';
            }
            elsif ($tagname eq 'br')
            {
            	$self->{inside}->{synopsis} = 0;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;
        if ($tagname eq 'div')
        {
            $self->{inside}->{genre}    = 0;
            $self->{inside}->{synopsis} = 0;
            $self->{inside}->{director} = 0;
        }
        elsif ($tagname eq 'li')
        {
            $self->{inside}->{audio} = 0;
            $self->{inside}->{subt}  = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/&#34;/"/g;
        $origtext =~ s/&#179;/3/g;
        $origtext =~ s/&#[0-9]*;//g;
        $origtext =~ s/[\n\r]\s*//g;
        $origtext =~ s/^\s*//g;
        $origtext =~ s/\s*$//;
        return if ($origtext eq '' || $origtext eq ',');

        if ($self->{parsingList})
        {
            if ($self->{inside}->{movie})
            {
                return if $self->{itemIdx} eq -1;
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $origtext;
                $self->{itemsList}[ $self->{itemIdx} ]->{date}  = $self->{listDate};
                $self->{inside}->{movie} = 0;
                return;
            }
            elsif ($self->{inside}->{date})
            {
                $origtext =~ /([0-9]+)/;
                $self->{listDate} = $1;
                $self->{inside}->{date} = 0;
            }
            elsif ($self->{inside}->{director})
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{director} = $origtext;
                $self->{inside}->{director} = 0;
            }
            $self->{inside}->{director} = 1 if $origtext eq 'Regia';
            $self->{inside}->{date} = 1 if $origtext eq 'Anno';
        }
        else
        {
            foreach my $item (keys %{$self->{patterns}})
            {
                if ($origtext =~ m/^$self->{patterns}->{$item}/ && ! $self->{curInfo}->{$item})
                {
                    $origtext =~ s/^$self->{patterns}->{$item}:*\s*//;
                    $self->{inside}->{$item} = 1;
                    return if (! $origtext);
                }
                if ($self->{inside}->{$item})
                {
                    $origtext =~ s/\s+min\s*// if $item eq 'time';
                    $origtext = $self->{curInfo}->{$item}.', '.$origtext
                       if ($item eq 'synopsis' || $item eq 'director') && $self->{curInfo}->{$item};
                    if ($item eq 'ratingpress')
                    {
                        if ($origtext =~ m{(\d+\,\d+)\s+di\s5\s*})
                        {
                            $origtext = $1;
                            $origtext =~ s/\,/\./;
                            $origtext = int(2*$origtext + 0.5);
                        }
                        $self->{curInfo}->{$item} = $origtext;
                    }
                    elsif ($item eq 'audio')
                    {
                        my @languages = split(';',$origtext);
                        foreach my $lang (@languages)
                        {
                            if ($lang =~ m/\s*(.*)\s*\((.*)\)\s*/)
                            {
                                push @{$self->{curInfo}->{audio}}, [$1, $2];
                            }
                        }
                    }
                    elsif ($self->{inside}->{subt})
                    {
                        my @subtitles = split('; ', $origtext);
                        foreach my $titl (@subtitles)
                        {
                            push @{$self->{curInfo}->{subt}}, [$titl];
                        }
                    }
                    else
                    {
                        $self->{curInfo}->{$item} = $origtext;
                    }
                    $self->{inside}->{$item} = 0 if $item ne 'synopsis' && $item ne 'director';
                    return;
                }
            }

            if ($origtext =~ m/Vietato ai minori di ([0-9]+) anni/)
            {
                $self->{curInfo}->{age} = $1;
            }
            elsif ($self->{inside}->{genre})
            {
                $origtext = $self->capWord($origtext);
                return if $self->{curInfo}->{genre} =~ m/^$origtext/;
                return if $self->{curInfo}->{genre} =~ m/,\s*$origtext\s*,/;
                return if $self->{curInfo}->{genre} =~ m/,\s*$origtext\s*$/;
                $self->{curInfo}->{genre} .= $origtext . ',';
                $self->{curInfo}->{genre} =~ s|\s*/\s*|,|g;
            }
            elsif (0 && $self->{inside}->{director})
            {
                $self->{curInfo}->{director} = $origtext;
                $self->{inside}->{director} = 0;
            }
            elsif ($self->{inside}->{actors} )
            {
                $self->{inside}->{actors} = 0;
                return if ($origtext =~ m/Approfondisci/);
                push @{$self->{curInfo}->{actors}}, [$origtext]
                  if ($self->{actorsCounter} <
                    $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS);
                $self->{actorsCounter}++;
            }
            elsif ($self->{inside}->{roles})
            {
                # As we incremented it above, we have one more chance here to add a role
                # Without <= we would skip the role for last actor
                push @{$self->{curInfo}->{actors}->[ $self->{actorsCounter} - 1 ]},
                  $origtext
                  if ($self->{actorsCounter} <=
                    $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS);
                $self->{inside}->{roles} = 0;
            }
            elsif ($self->{inside}->{movie})
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{inside}->{movie} = 0;
            }
        }
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            director => 1,
            actors   => 0,
        };

        # patterns used to detect the fields
        $self->{patterns} = {
            date        => 'Anno',
            synopsis    => 'Descrizione',
            time        => 'Durata',
            format      => 'Supporto',
            country     => 'Paese',
            ean         => 'EAN',
            original    => 'Titolo originale',
            ratingpress => 'Media clienti',
            audio       => 'Lingua audio',
            subt        => 'Lingua sottotitoli',
            director    => 'Regia',
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $html =~ s/"&#34;/'"/g;
        $html =~ s/&#34;"/"'/g;

        foreach my $item ('movie', 'director', 'actors', 'genre', 'roles')
        {
            $self->{inside}->{$item} = 0;
        }
        foreach my $item (keys %{$self->{patterns}})
        {
            $self->{inside}->{$item} = 0;
        }

        if ($self->{parsingList})
        {
            $self->{alreadyListed} = {};
        }
        else
        {
            $html =~ s|.*<div class="container main-ctn">|<div>|s;
            $self->{curInfo}->{actors} = [];
        }
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return "https://www.ibs.it/search/?ts=as&query=$word&filterProduct_type=MOVIE&query_seo=$word&qs=true";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url if $url =~ /^http:/;
        return "http://www.ibs.it" . $url;
    }

    sub getName
    {
        return "IBS - Internet Bookshop";
    }

    sub getAuthor
    {
        return 't-storm - Kerenoc';
    }

    sub getLang
    {
        return 'IT';
    }

}

1;
