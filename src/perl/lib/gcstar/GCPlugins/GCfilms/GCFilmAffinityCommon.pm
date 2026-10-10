package GCPlugins::GCfilms::GCFilmAffinityCommon;

###################################################
#
#  Copyright 2005-2007 Tian
#  Edited 2009 by FiXx
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

use strict;
use utf8;

use GCPlugins::GCfilms::GCfilmsCommon;

{

    package GCPlugins::GCfilms::GCPluginFilmAffinityCommon;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($self->{parsingEnded})
            {
                if (   ($tagname eq 'a')
                    && ($attr->{href} =~ /\/.*\.php\?movie_id=([0-9]*)/))
                {
                    $self->{hasUrl} = 'film' . $1 . '.html';
                }
            }
            elsif ($self->{searchingMovie} && $tagname eq 'a' && $attr->{href} =~ /^\/[a-z][a-z]\/(film.*)$/)
            {
                my $url = $1;
                $self->{itemIdx}++;
                $self->{isMovie} = 1;
                $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $attr->{title};
                $self->{itemsList}[ $self->{itemIdx} ]->{date} = $self->{currentDate};
            }
            elsif (($tagname eq 'a') && $self->{searchingMovie}
                && ($attr->{href} =~ m/search.php.stype=director/))
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{director} = $attr->{title};
            }
            elsif (($tagname eq 'a') && $self->{searchingMovie}
                && ($attr->{href} =~ m/search.php.stype=cast/))
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{actors} = $attr->{title};
            }
            elsif ($tagname eq 'div' && $attr->{class} =~ /ye.w/)
            {
                $self->{isDate} = 1;
                $self->{isMovie} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'z-search')
            { 
            	$self->{searchingMovie} = 1;
            }
        }
        else
        {
            if ($tagname eq 'h1' && $attr->{id} eq 'main-title')
            {
                $self->{isTitle} = 1;
            }
            elsif ($tagname eq 'img')
            {
                if ($attr->{src} =~ /^\/imgs\/countries/)
                {
                    $self->{curInfo}->{country} = $attr->{title};
                }
                elsif ($attr->{src} =~ /pics.*filmaffinity\.com\/.*-full\.jpg/)
                {
                    $self->{curInfo}->{image} = $attr->{src}
                      if not exists $self->{curInfo}->{image};
                }
            }
            elsif ($tagname eq 'a')
            {
                if ($attr->{href} =~ /pics.*filmaffinity\.com\/.*-large\.jpg/)
                {
                    $self->{curInfo}->{image} = $attr->{href};
                }
            }
            elsif ($tagname eq 'div' && $attr->{itemprop} eq 'ratingValue')
            {
                $self->{curInfo}->{ratingpress} = $attr->{content};
             }
            elsif ($tagname eq 'dl' && $attr->{class} eq "movie-info")
            {
                $self->{isMovie} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        
        $self->{isTitle}  = 0 if ($self->{isTitle}  && $tagname eq 'h1');
        $self->{isMovie}  = 0 if ($self->{isMovie}  && $tagname eq 'dl');
        $self->{isGenre}  = 0 if ($self->{isGenre}  && $tagname eq 'dd');
        $self->{isActors} = 0 if ($self->{isActors} && $tagname eq 'dd');
    }

    sub text
    {
        my ($self, $origtext) = @_;

        if ($self->{parsingList})
        {
            if ($self->{parsingEnded})
            {
                if ($self->{hasUrl})
                {
                    $self->{itemsList}[0]->{url} = $self->{hasUrl};
                    $self->{hasUrl} = 0;
                }
                return;
            }

            if ($self->{inside}->{title} && ($origtext !~ $self->{patternSearch}))
            {
                $self->{parsingEnded} = 1;
                $self->{hasUrl}       = 0;
                $self->{itemIdx}      = 0;
            }
            elsif ($self->{isDate})
            {
                $self->{currentDate} = $origtext;
                $self->{isDate} = 0;
            }
        }
        else
        {
            $origtext =~ s/^\s*//;
            $origtext =~ s/\s*$//;

            return if (!$origtext || $origtext =~ m/^[\.\|]$/);
            if ($self->{isMovie})
            {
                
            }
            if ($self->{isTitle})
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0;
            }
            elsif ($self->{isOrig})
            {
                $self->{curInfo}->{original} = $origtext;
                $self->{isOrig} = 0;
            }
            elsif ($self->{isDate})
            {
                $self->{curInfo}->{date} = $origtext;
                $self->{isDate} = 0;
            }
            elsif ($self->{isTime})
            {
                $origtext =~ s/ min.*//;
                $self->{curInfo}->{time} = $origtext;
                $self->{isTime} = 0;
            }
            elsif ($self->{isDirector})
            {
                $self->{curInfo}->{director} = $origtext;
                $self->{isDirector} = 0;
            }
            elsif ($self->{isActors})
            {
                if ($self->{inside}->{a} && $origtext)
                {
                    $origtext =~ s/\n//g;
                    $self->{curInfo}->{actors} .= $origtext . ', ';
                }
            }
            elsif ($self->{isGenre})
            {
                $origtext = ','.$origtext if ($self->{curInfo}->{genre} ne '');
                $self->{curInfo}->{genre} .= $origtext;
            }
            elsif ($self->{isSynopsis})
            {
                $self->{curInfo}->{synopsis} = $origtext;
                $self->{isSynopsis} = 0;
            }
            elsif ($self->{isMovie})
            {
                foreach my $item (@{$self->{items}})
                {
                    if ($origtext =~ $self->{'pattern'.$item})
                    {
                        $self->{'is'.$item} = 1;
                        return;
                    }
                }                
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
            actors   => 1,
        };
        my @items = ('Original', 'Date', 'Time', 'Director', 'Actors', 'Genre', 'Synopsis');
        $self->{items} = \@items;
        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{parsingEnded} = 0;

        $self->{isInfo}  = 0;
        $self->{isMovie} = 0;
        $self->{searchingMovie} = 0;
        $self->{curName} = undef;
        $self->{curUrl}  = undef;
        $self->{curInfo}->{genre}  = '';
        $self->{curInfo}->{actors} = '';

        
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return $self->{urlRoot} . "search.php?"
              ."stext=$word&stype=title";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $self->{urlRoot} . $url;
    }

    sub changeUrl
    {
        my ($self, $url) = @_;

        return $url;
    }

    sub getName
    {
        return "Film affinity (EN)";
    }

    sub getCharset
    {
        my $self = shift;

        return "ISO-8859-1";
    }

    sub getAuthor
    {
        return 'Tian - PIN - FiXx - Kerenoc';
    }

    sub getLang
    {
        return 'EN';
    }
}

1;
