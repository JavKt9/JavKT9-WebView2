package GCPlugins::GCfilms::GCCDON;

###################################################
#
#  Copyright 2005-2010 Tian, Michael Mayer
#  Copyright 2025-2026 Kerenoc
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

use GCPlugins::GCfilms::GCfilmsCommon;

{

    package GCPlugins::GCfilms::GCPluginCDON;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            return if $self->{parsingEnded};
            if ($tagname eq 'a' && $attr->{href} =~ m|/produkt/| && $attr->{title})
            {
                $self->{itemIdx}++;
                $self->{itemsList}[ $self->{itemIdx} ]->{url} = $attr->{href};
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $attr->{title};
            }
        }
        else
        {
            return if $self->{parsingEnded};

            if ($tagname eq 'div' && $attr->{"aria-label"})
            {
                $self->{isSynopsis} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{class})
            {
                if ($attr->{class} =~ m/testfreaks/)
                {
                    $self->{parsingEnded} = 1;
                }
                elsif ($attr->{class} =~ m/ds_produkt_left/)
                {
                    $self->{isCover} = 1;
                }
            }
            elsif ($tagname eq 'img')
            {
                if (!$self->{curInfo}->{image})
                {
                    $self->{curInfo}->{image} = $attr->{src};

                    if ($self->{bigPics})
                    {
                        $self->{curInfo}->{image} =~ s|front_normal|front_large|;
                        $self->{curInfo}->{backpic} = $self->{curInfo}->{image};
                        $self->{curInfo}->{backpic} =~ s|front_large|back_large|;
                    }
                }
                elsif ($self->{isRating})
                {
                    $self->{curInfo}->{ratingpress} += 2
                      if ($attr->{src} =~ m/rate_big_1.gif/);
                    $self->{curInfo}->{ratingpress} += 1
                      if ($attr->{src} =~ m/rate_big_05.gif/);
                }
            }
            elsif ($tagname eq 'strong')
            {
                $self->{isSynopsis} = 0;
                $self->{isItem} = 1;
                $self->{isActor} = 0;
            }
            elsif ($tagname eq 'br')
            {
                $self->{curInfo}->{synopsis} .= "\n"
                  if ($self->{isSynopsis} && $self->{curInfo}->{synopsis});
            }
            elsif ($tagname eq 'tr')
            {
                $self->{isItem} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;

        if ($tagname eq 'div')
        {
            $self->{isCover} = 0;
        }
        elsif ($tagname eq 'p')
        {
            $self->{curInfo}->{synopsis} .= "\n"
              if ($self->{isSynopsis} && $self->{curInfo}->{synopsis});
        }
        elsif ($tagname eq 'tr')
        {
            $self->{isItem} = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^\s*//;
        $origtext =~ s/\s*$//;
        return if !$origtext;

        if ($self->{parsingList})
        {
            # evaluate the search result page
            if ($self->{isMovie})
            {
                if ($self->{inside}->{b})
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{title} = $origtext;
                }
                elsif ($self->{inside}->{div})
                {
                    $origtext =~ /^.*?(\d{4}) +(med +([^-.]*))?/;
                    if ($1)
                    {
                        $self->{itemsList}[ $self->{itemIdx} ]->{date}   = $1;
                        $self->{itemsList}[ $self->{itemIdx} ]->{actors} = $3;
                    }
                    else
                    {
                        $origtext =~ /med +([^-.]*)/;
                        $self->{itemsList}[ $self->{itemIdx} ]->{actors} = $1
                          if $1;
                    }
                    $self->{itemsList}[ $self->{itemIdx} ]->{actors} =~ s/ och/,/g;
                    $self->{isMovie} = 0;
                }
            }
        }
        else
        {
            return if $self->{parsingEnded};
            # evaluate the film details page
            if ($self->{inside}->{h3})
            {
                if ($origtext eq "Filmens handling")
                {
                    $self->{isSynopsis} = 1;
                }
            }
            elsif ($self->{isSynopsis})    # important: elsif, not only if!
            {
                $self->{curInfo}->{synopsis} .= $origtext;
            }
            elsif ($self->{isItem} == 1)
            {
                if ($origtext eq 'SKÅDESPELARE:')
                {
                    $self->{isActor} = 1;
                    $self->{isItem} = 0;
                }
                else
                {
                    $self->{isItem} = 2;
                }
            }
            elsif ($self->{isItem} == 2 and $origtext =~ /(.*:) *(.*)/)
            {
                my $key = $1;
                $origtext = $2;
                if (   ($key eq "Slag")
                    or ($key eq "Filmgenre:")
                    or ($key eq "Underkategori:"))
                {
                    $origtext =~ s| *film$||i;    # remove the trailing "film"
                    $origtext =~ s|/|,|i;
                    $self->{curInfo}->{genre} .= $origtext . ","
                      if (!($self->{curInfo}->{genre} =~ m/$origtext/));
                }
                elsif ($key eq "Längd:")
                {
                    my $minutes = ($origtext =~ m/(\d+) *min/) ? $1 : 0;
                    my $hours = ($origtext =~ m/(\d+) *tim/) ? $1 : 0;
                    $self->{curInfo}->{time} = 60 * $hours + $minutes;
                }
                elsif ($key eq "Svensk titel:")
                {
                    $self->{curInfo}->{title} = $origtext;
                }
                elsif ($key eq "Språk:")
                {
                    $self->{curInfo}->{audio} = $origtext;
                }
                elsif ($key eq "Text:")
                {
                    $self->{curInfo}->{subt} = $origtext;
                }
                elsif ($key eq "Originaltitel:")
                {
                    $self->{curInfo}->{original} = $origtext;
                }
                elsif ($key eq "Produktionsland:")
                {
                    if ($self->{curInfo}->{country}) {
                        $self->{curInfo}->{country} .= ", ";
                    }
                    $self->{curInfo}->{country} .= $origtext;
                }
                elsif ($key eq "Produktionsår:")
                {
                    $self->{curInfo}->{date} = $origtext;
                }
                elsif ($key eq "Regi:")
                {
                    if ($self->{curInfo}->{director})
                    {
                        $self->{curInfo}->{director} .= ", ";
                    }
                    $self->{curInfo}->{director} = $origtext;
                }
                elsif ($key eq "Åldersgräns:")
                {
                    $origtext =~ m/^(\d+) /;
                    $self->{curInfo}->{"age"} = $1;
                }
            }
            elsif ($self->{isActor})
            {
                push @{$self->{curInfo}->{actors}}, [$origtext]
                      if ($self->{actorsCounter} < $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS);
                $self->{actorsCounter}++;
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
            director => 0,
            actors   => 1,
            age      => 1,
        };

        $self->{isInfo}   = 0;
        $self->{isRating} = 0;
        $self->{isCover}  = 0;

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{parsingEnded} = 0;
        $self->{isTitle}      = 0;
        $self->{isSynopsis}   = 0;
        $self->{isItem}       = 0;

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return "https://cdon.se/film/filmboxar/?q=$word";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return 'https://cdon.se' . $url;
    }

    sub changeUrl
    {
        my ($self, $url) = @_;

        return $url;
    }

    sub getName
    {
        return "CDON (SE)";
    }

    sub getCharset
    {
        my $self = shift;

        return "UTF-8";
    }

    sub getAuthor
    {
        return 'Tian - Kerenoc';
    }

    sub getLang
    {
        return 'SV';
    }
}

1;
