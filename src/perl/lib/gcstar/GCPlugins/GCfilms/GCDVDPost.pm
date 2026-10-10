package GCPlugins::GCfilms::GCDVDPost;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2016-2018 Kerenoc
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

###################################
#                                 #
#      Plugin soumis par MeV      #
#                                 #
###################################

use strict;
use utf8;

use GCPlugins::GCfilms::GCfilmsCommon;

{

    package GCPlugins::GCfilms::GCPluginDVDPost;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class} eq 'movie-ttl')
            {
                $self->{isMovie} = 1;
            } 
            elsif ($tagname eq "a" && $self->{isMovie} eq 1)
            {
                if ($attr->{href} =~ m/\/products\//)
                {
                    my $url = $attr->{href};
                    $self->{isMovie} = 2;
                    $self->{isInfo}  = 1;
                    $self->{itemIdx}++;
                    $self->{itemsList}[ $self->{itemIdx} ]->{url} = 'http://public.dvdpost.com'.$url;
                }
            }
        }
        else
        {
            if ($tagname eq "img")
            {
                if ($self->{insideRating} && $attr->{alt} eq 'Star-on')
                {
                   $self->{curInfo}->{rating} += 2; 
                }
                elsif ($self->{insideRating} && $attr->{alt} eq 'Star-half')
                {
                   $self->{curInfo}->{rating} += 1; 
                }
                elsif ($attr->{src} =~ /\/images\/dvd\//)
                {
                    $self->{curInfo}->{image} = $attr->{src};
                }
            }
            elsif ($tagname eq 'h2')
            {
                $self->{insideTitle} = 1;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/categories\//)
            {
                $self->{insideGenre} = 1;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/actors\//)
            {
                $self->{insideActors} = 1;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/directors\//)
            {
                $self->{insideDirector} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ /film-descr/)
            {
                $self->{insideSynopsis} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ /formats/)
            {
                $self->{insideFormats} = 1;
                $self->{indexFormats} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ /votes/)
            {
                $self->{insideRating} = 1;
            }
            elsif ($tagname eq 'div')
            {
                $self->{insideActors} = 0;
                $self->{insideSynopsis} = 0;
            }
            elsif ($tagname eq 'th' && $self->{insideFormats} eq 1)
            {
                $self->{insideFormats} = 2;
            }
            elsif ($tagname eq 'td' && $self->{insideFormats} eq 3)
            {
                $self->{indexFormats} += 1;
                $self->{insideSubt}  = 1 if ($self->{indexFormats} eq $self->{indexSubt});
                $self->{insideAudio} = 1 if ($self->{indexFormats} eq $self->{indexAudio});
            }
            elsif ($tagname eq 'span' && $self->{insideSubt} eq 1)
            {
                $self->{curInfo}->{subt} .= ', ' if $self->{curInfo}->{subt};
                $self->{curInfo}->{subt} .= $attr->{title};
            }
            elsif ($tagname eq 'span' && $self->{insideAudio} eq 1)
            {
                $self->{curInfo}->{audio} .= ', ' if $self->{curInfo}->{audio};
                $self->{curInfo}->{audio} .= $attr->{title};
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        if ($tagname eq 'tr' && $self->{insideFormats} eq 1)
        {
            $self->{insideFormats} = 3;
            $self->{indexFormats} = 0; 
        }
        if ($tagname eq 'table')
        {
            $self->{insideFormats} = 0;
            $self->{insideSubt} = 0;
            $self->{insideAudio} = 0;
            $self->{curInfo}->{time} =~ s/ Min *//; 
        }
        if ($tagname eq 'div' && $self->{insideRating})
        {
            $self->{insideRating} = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        return if length($origtext) < 2;

        if ($self->{parsingList})
        {
            if ($self->{isMovie} eq 2)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{"title"} = $origtext;
                $self->{isMovie}                                  = 0;
                $self->{isInfo}                                   = 1;
                return;
            }
        }
        else
        {
            $origtext =~ s/\n*//g if !$self->{insideSynopsis};
            $origtext =~ s/\s{2,}//g;
            return if $origtext eq '';
            
            if ($self->{insideDate})
            {
                $self->{curInfo}->{date} = $origtext;
                $self->{insideDate} = 0;
            }
            elsif ($self->{insideDirector})
            {
                $origtext =~ s/ ,/, /g;
                $origtext =~ s/^(.*), /$1/;
                $self->{curInfo}->{director} .= ', ' if $self->{curInfo}->{director};
                $self->{curInfo}->{director} .= $origtext;
                $self->{insideDirector} = 0;
            }
            elsif ($self->{insideSynopsis})
            {
                $self->{curInfo}->{synopsis} .= $origtext if !($origtext =~ /SYNOPSIS :/);
            }
            elsif ($self->{insideFormats} eq 2)
            {
                $self->{indexFormats} += 1;
                $self->{indexTime}     = $self->{indexFormats} if $origtext =~ /^Dur/i;
                $self->{indexCountry}  = $self->{indexFormats} if $origtext =~ /^Pays/i;
                $self->{indexAge}      = $self->{indexFormats} if $origtext =~ /^Public/i;
                $self->{indexVideo}    = $self->{indexFormats} if $origtext =~ /^Image/i;
                $self->{indexEncoding} = $self->{indexFormats} if $origtext =~ /^Son/i;
                $self->{indexSubt}     = $self->{indexFormats} if $origtext =~ /^Sous-titres/i;
                $self->{indexAudio}    = $self->{indexFormats} if $origtext =~ /^Audio/i;
                $self->{insideFormats} = 1;
            }
            elsif ($self->{insideFormats} eq 3)
            {
                $self->{curInfo}->{time}     = $origtext if ($self->{indexFormats} eq $self->{indexTime});
                $self->{curInfo}->{country}  = $origtext if ($self->{indexFormats} eq $self->{indexCountry});
                $self->{curInfo}->{age}      = $origtext if ($self->{indexFormats} eq $self->{indexAge});
                $self->{curInfo}->{video}    = $origtext if ($self->{indexFormats} eq $self->{indexVideo});
                $self->{curInfo}->{encoding} = $origtext if ($self->{indexFormats} eq $self->{indexEncoding});
            }
            elsif ($self->{insideActors} eq 1)
            {
                $origtext =~ s/ ,/, /g;
                $origtext =~ s/^(.*), /$1/;
                $self->{curInfo}->{actors} .= ', ' if $self->{curInfo}->{actors};
                $self->{curInfo}->{actors} .= $origtext;
                $self->{insideActors} = 0;
            }
            elsif ($self->{insideTitle})
            {
                if ($origtext =~ /(.*) \( *([0-9]{4}) *\)/)
                {
                    $self->{curInfo}->{title} = $1 if !$self->{curInfo}->{title};
                    $self->{curInfo}->{date}  = $2 if !$self->{curInfo}->{date};
                }
                $self->{insideTitle} = 0;
            }
            elsif ($self->{insideGenre})
            {
                $origtext =~ s/\|/,/g;
                $self->{curInfo}->{genre} .= ', ' if $self->{curInfo}->{genre};
                $self->{curInfo}->{genre} .= $origtext;
                $self->{insideGenre} = 0;
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
            date     => 0,
            director => 0,
            actors   => 0,
        };

        $self->{isInfo}  = 0;
        $self->{isMovie} = 0;
        $self->{curName} = undef;
        $self->{curUrl}  = undef;

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $html =~ s/&nbsp;/ /g;
        $html =~ s/<u>|<\/u>//g;
        $html =~ s/<a href="directors\.php\?directors\_id=[0-9]*">([^<]*)<\/a>/$1/gi;
        $html =~ s/<a href="actors\.php\?actors\_id=[0-9]*">([^<]*)<\/a>/$1/gi;
        
        $self->{curInfo}->{synopsis} = '';

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        # return ("http://public.dvdpost.be/fr/search_filters", [ 'search' => "$word", "commit" => "search"]);
        # return "http://www.dvdpost.be/advanced_search_result2.php?language=fr&keywords=$word";
        return "http://public.dvdpost.com/fr/products?search=$word";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url;
        #return "http://www.dvdpost.be/" . $url . "&language=fr" unless $url eq '';
        #return "http://www.dvdpost.be/";
    }

    sub getName
    {
        return "DVDPost.be";
    }

    sub getAuthor
    {
        return 'MeV - Kerenoc';
    }

    sub getLang
    {
        return 'FR';
    }

}

1;
