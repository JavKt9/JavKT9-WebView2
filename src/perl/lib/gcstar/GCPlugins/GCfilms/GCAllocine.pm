package GCPlugins::GCfilms::GCAllocine;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2015-2018 Kerenoc
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

    package GCPlugins::GCfilms::GCPluginAllocine;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    use MIME::Base64;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($self->{insideResults} eq 1)
            {
                $self->{isInfo} = 1 if ($tagname eq 'span' && $attr->{class} eq 'date');
                $self->{isInfo} = 2 if ($tagname eq 'span' && $attr->{class} =~ m/blue-link/);
                $self->{isInfo} = 3 if ($tagname eq 'div' && $attr->{class} =~ m/meta-body-actor/);
                if ($tagname eq 'span' && $attr->{class} =~ m/meta-title-link/)
                {
                    (my $urlEncoded = $attr->{class}) =~ s/ .*//;                  
                    my $url = decode_base64("AA".$urlEncoded);
                    $url =~ s/.*fiche/fiche/;
                    $url = "/film/".$url if ($url =~ m/film/);
                    $url = "/series/".$url if ($url =~ m/serie/);
                    if ($url =~ /^\/(film|series)\/fiche(film|serie)_gen_c/)
                    {
                        $self->{isMovie} = 1;
                        $self->{isInfo}  = 0;
                        $self->{itemIdx}++;
                        $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                    }
                }
            }
        }
        else
        {
            if ($tagname eq 'body' && $attr->{id} =~ m/seriespage/)
            {
                $self->{isSerie} = 1;
                $self->{curInfo}->{genre} = 'Serie' if (! $self->{curInfo}->{genre});
            }
            elsif ($tagname eq 'img' && $attr->{class} =~ m/thumbnail-img/ && !$self->{curInfo}->{image})
            {
                my $src = $attr->{src};
                $src = $attr->{'data-src'} if ($src =~ m/base64/);
                $self->{curInfo}->{image} = $src;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'rating-holder') # series
            {
                $self->{insidePressRating} = 1;
            }
            elsif ($tagname eq 'h1' && ! $self->{curInfo}->{title})
            {
                $self->{insideTitle} = 1;
            }
            elsif (($tagname eq 'div') && ($attr->{class} =~ m/md-table-row/) && ($self->{insideActor} eq 2))
            {
                $self->{insideActor} = 3;
                # item where the role is followed by actor name : role part
            }
            elsif ($tagname eq 'strong' && $self->{insideSerie} && (! $self->{curInfo}->{country})) # series
            {
                $self->{insideCountry} = 2;
            }
            elsif (($tagname eq 'span') && ($attr->{class} =~ m/nationality/))
            {
                $self->{insideCountry} = 2;
            }
            elsif (($tagname eq 'span') && ($attr->{class} =~ m/stareval-note/) && ($self->{insidePressRating} eq 1))
            {
                $self->{insidePressRating} = 2;
            }
            elsif (($tagname eq 'div') && ($attr->{class} eq 'breaker'))
            {
                $self->{insidePressRating} = 0;
            }
            elsif (($tagname eq 'section') && ($attr->{id} eq 'synopsis-details'))
            {
                $self->{insideSynopsis} = 1;
                $self->{insideSerie} = 0;
            }
            elsif ($self->{insideSynopsis} eq 1 && $tagname eq 'div' && $attr->{class} =~ m/-txt/)
            {
                $self->{insideSynopsis} = 2;                    
            }
            elsif (($tagname eq 'span') && ($attr->{class} =~ /date/))
            {
                $self->{insideDate} = 2;
            }
            elsif (($tagname eq 'span') && ($self->{insideDate} eq 1))
            {
                $self->{insideDate} = 2;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ m/\/casting/i && ! $self->{curInfo}->{actors})
            {
                # set URL for casting tab
                $self->{curInfo}->{nextUrl} = 'http://www.allocine.fr'.$attr->{href}
                    if ( (! ($attr->{href} =~ m/episode/)) && (! ($self->{loadedUrl} =~ m/casting/)));
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ m/serie-tv\/genre/i)
            {
                $self->{insideGenre} = 2;
            }
            elsif ($tagname eq 'section' && $attr->{class} =~ /casting-actor/ )
            {
                # serie
                $self->{insideActor} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{class} =~ m/meta-body-item/)
            {
                $self->{insideField} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;
        $self->{inside}->{$tagname}--;

        if ($tagname eq 'div') 
        {
            $self->{isInfo} = 0;
            $self->{insideCountry} = 0;
            $self->{insideSynopsis} = 0 if ($self->{insideSynopsis} eq 2);
            $self->{insideDirector} = 0;
            $self->{insideGenre} = 0;
            $self->{insideTime} = 0;
            $self->{insideField} = 0;
            $self->{insideDate} = 0;
            if ($self->{actor} && $self->{role})
            {
                push @{$self->{curInfo}->{actors}}, [$self->{actor}];
                push @{$self->{curInfo}->{actors}->[$self->{actorsCounter}]}, $self->{role};
                $self->{actorsCounter}++;
                $self->{actor} = '';
                $self->{role} = '';
                $self->{insideActor} = 2;
            }
        }
        elsif ($tagname eq 'th')
        {
           $self->{insideSynopsis} = 0;
        }
        elsif ($tagname eq 'table')
        {
            $self->{insideResults} = 0;
        }
        elsif ($tagname eq 'section')
        {
            $self->{insideActor} = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/[\r\n]//g;
        $origtext =~ s/^\s*//;
        $origtext =~ s/\s*$//;

        return if ($origtext eq '');

        if ($self->{parsingList})
        {
            if (($origtext =~ m/(\d+) r..?sultats? trouv..?s? dans les (titres|vid)/) && ($1 > 0))
            {
                $self->{insideResults} = 1;
            }
            elsif ($self->{isMovie} eq 1)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{title} .= $origtext;
                $self->{isMovie} = 0;
            }
            elsif ($self->{isInfo} eq 1 && !($origtext =~ /inconnu/))
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{date} = GCUtils::strToTime($origtext,'%d %B %Y',$self->getLang());
                $self->{isInfo} = 0;
            }
            elsif ($self->{isInfo} eq 2)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{director} .= $origtext
                     if (! ($origtext =~ /^De$/i));
            }
            elsif ($self->{isInfo} eq 3)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{actors} .= $origtext
                    if (! ($origtext =~ /^Avec/i));
            }
        }
        else
        {
            if ($self->{insideTitle} eq 1)        
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{insideTitle} = 0;

                return if ($self->{curInfo}->{actors});
                # two pass plugin : title is set in the first pass
                # loading second web page for casting
                my $fileCasting = $self->{curInfo}->{$self->{urlField}};
                $fileCasting =~ s/_gen_cfilm=/-/;
                # $fileCasting =~ s/_gen_cserie=/-/;
                if ($fileCasting =~ m/serie=/)
                {
                    $self->{curInfo}->{serie} = $origtext;
                }
                $fileCasting =~ s/.html/\/casting/;
                $self->{curInfo}->{nextUrl} = $fileCasting if (! ($fileCasting =~ m/cserie/));              
            }
            elsif ($self->{insideDirector} eq 2 && $origtext ne ',')
            {
                $self->{curInfo}->{director} .= ', ' if ($self->{curInfo}->{director});
                $self->{curInfo}->{director} .= $origtext;
            }
            elsif ($self->{insideGenre} eq 2 && $origtext ne ',' && $origtext ne '/')
            {
                return if ($origtext =~ m/^,*$/);
                $self->{curInfo}->{genre} .= ',' if ($self->{curInfo}->{genre});
                $self->{curInfo}->{genre} .= $origtext;
            }
            elsif ($self->{insideDate} eq 2)
            {
                $self->{curInfo}->{date} = GCUtils::strToTime($origtext,'%d %B %Y',$self->getLang())
                    if !($origtext =~ /inconnu/);
                $self->{insideDate} = 0;
                $self->{insideTime} = 1;
            }
            elsif ($self->{insideTime} eq 1 && $origtext =~ m/\d/ )
            {
                $origtext =~ /(\d+)h\s*(\d+)m.*/;
                my $time = ($1*60) + $2;
                $self->{curInfo}->{time} = $time;
                $self->{insideTime} = 0;
                $self->{insideGenre} = 2;
            }
            elsif ($self->{insideTime} eq 2 && $origtext ne '/')
            {
                if ($origtext =~ /(\d+)h\s*(\d+)m.*/)
                {
                    $self->{curInfo}->{time} = ($1*60) + $2;
                }
                elsif ($origtext =~ /(\d+)min/)
                {
                    $self->{curInfo}->{time} = $1;
                }
                $self->{insideTime} = 0;
                $self->{insideGenre} = 2;
            }
            elsif ($self->{insideCountry} eq 2)
            {
                if ($origtext =~ m/\|/) 
                { 
                    $self->{insideCountry} = 0;
                    return;
                }
                $origtext = ',' if $origtext =~ m/^,/;
                $self->{curInfo}->{country} .= $origtext;
            }
            elsif ($self->{insideSerie} && (! $self->{curInfo}->{date}))
            {
                if ($origtext =~ m/\(.*\)/)
                {
                    $origtext =~ s/[()]*//g;
                    $self->{curInfo}->{date} = $origtext;
                }
            }
            elsif ($self->{insideActor} eq 1 && $origtext =~ m/Acteur/)
            {
                $self->{insideActor} = 2;
            }
            elsif ($self->{insideActor} > 1)
            {
                return if ($origtext eq ',' || $origtext eq '' );
                return if ($origtext =~ m/Voir la liste/i);

                $origtext =~ s/\s*plus\s*//;
                $origtext =~ s/\s*Rôle\s*:\s*//;
                
                if ($self->{insideActor} eq 2)
                {
                    $self->{actor} = $origtext;
                    $self->{insideActor} = 3;
                } 
                else
                {
                    $self->{role} = $origtext;
                    $self->{insideActor} = 2;
                }
            }
            elsif ($origtext =~ /^Presse$/)
            {
                $self->{insidePressRating} = 1;
            }
            elsif ($self->{insidePressRating} eq 2)
            {
                $origtext =~ s/,/./;
                $self->{curInfo}->{ratingpress} .= $origtext * 2;
                $self->{insidePressRating} = 0;
            }
            elsif (($origtext =~ /Date de reprise$/)
                   && (!$self->{curInfo}->{date}))
            {
                $self->{insideDate} = 1;
            }
            elsif ($origtext eq 'Date de sortie')
            {
                $self->{insideDate} = 1;
            }
            elsif ($origtext =~ m/^Interdit aux moins de (\d+) ans/)
            {
                $self->{curInfo}->{age} = $1;
            }
            elsif ($self->{insideSynopsis} eq 2)
            {
                $self->{curInfo}->{synopsis} .= $origtext.' ';
                # l'espace après un point est parfois oublié par Allociné
                $self->{curInfo}->{synopsis} =~ s/\.([^\s\.])/. $1/g;
            }
            elsif ($origtext =~ m/Titre original/)
            {
                $self->{insideOriginal} = 1;
            }
            elsif ($self->{isSerie} && $origtext =~ m/^Depuis /)
            {
                $origtext =~ s/Depuis //;
                $self->{curInfo}->{date} = $origtext;
                $self->{insideTime} = 2;
            }
            elsif ($self->{isSerie} && $origtext =~ m/(\d+) - (\d+)/ && (! $self->{curInfo}->{date}))
            {
                $self->{curInfo}->{date} = $origtext;
                $self->{insideTime} = 2;
            }
            elsif ($self->{insideOriginal} eq 1)
            {
                $self->{curInfo}->{original} = $origtext;
                $self->{insideOriginal} = 0;
            }
            elsif ($self->{insideField} eq 1)
            {
                $self->{insideDirector} = 2 if ($origtext eq 'De');
                $self->{insideGenre} = 2 if ($origtext =~ m/^Genre/);
                $self->{insideTime} = 2 if ($origtext =~ m/^Dur.*e$/); # durée
                $self->{insideField} = 0;
            }
        }
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            director => 1,
            actors   => 1,
        };


        bless($self, $class);
        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;
        
        $self->{isInfo}        = 0;
        $self->{isMovie}       = 0;
        $self->{isSerie}       = 0;
        $self->{insideResults} = 0;
        $self->{insideSerie}   = 0;
        $self->{insideCountry} = 0;
        $self->{insideField}   = 0;
        $self->{curName}       = undef;
        $self->{curUrl}        = undef;
        $self->{actorsCounter} = 0;
        
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return "http://www.allocine.fr/rechercher/?q=$word";
    }

    sub getSearchCharset
    {
        my $self = shift;

        # Need urls to be double character encoded
        return 'utf8';
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return 'http://www.allocine.fr' . $url;
    }

    sub getName
    {
        return 'Allocine.fr';
    }

    sub getAuthor
    {
        return 'Tian - Kerenoc';
    }

    sub getLang
    {
        return 'FR';
    }
    
    sub getCharset
    {
        # return 'UTF-8'; # For 1.5.0 Win32
        return 'ISO-8859-1'; # For 1.5.0 Win32 with /lib/gcstar/GCPlugins/ ver.1.5.9svn
    }
}

1;
