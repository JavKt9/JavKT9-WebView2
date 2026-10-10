package GCPlugins::GCbooks::GCChapitre;
###################################################
#
#  Copyright 2005-2006 Tian
#  Copyright 2015-2016 Kerenoc
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

###################################################
#
# 2015 Changes
#
#    - adaptation aux modifications du site
#
###################################################

use strict;
use utf8;

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginChapitre;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);
    use URI::Escape;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class} =~ m/product-description/)
            {
                $self->{isTitle} = 1;
            }
            elsif ($self->{isTitle} eq 1 && $tagname eq 'a' && $attr->{title} ne '')
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = "http://www.chapitre.com" . $attr->{href};
                $self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                $self->{isTitle} = 0;
            }
            elsif ($tagname eq 'a' && $attr->{itemprop} eq "author")
            {
                $self->{isAuthor} = 1 ;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'publisher')
            {
                $self->{isPublisher} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'publish-date')
            {
                $self->{isPublication} = 1;
            }
        }
        else
        {
            if (($tagname eq 'h1') && ( $attr->{class} eq 'ProductSummary-title'))
            {
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'a' && $attr->{itemprop} eq 'author')
            {
                $self->{isAuthor} = 1 ;
            }
            elsif (($tagname eq 'h1') && ( $attr->{class} eq 'product-title'))
            {
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'publisher')
            {
                $self->{isPublisher} = 1;
            }
            elsif ($self->{isPublisher} eq 1 && $attr->{itemprop} eq 'name')
            {
                $self->{isPublisher} = 2;
            }
            elsif (($tagname eq 'div') && ($attr->{itemprop} eq 'description'))
            {
                $self->{isDescription} = 1 ;
            }
            elsif ($self->{isDescription} eq 1 && $tagname eq 'span')
            {
                $self->{isDescription} = 2 ;
            }
            elsif ($self->{isDescription} eq 3 && $tagname eq 'span' && $attr->{class} =~ m/hidden-lg/)
            {
                $self->{isDescription} = 4 ;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'datePublished')
            {
                $self->{isPublication} = 1;
            }
            elsif (($tagname eq 'a') && ( $attr->{itemprop} eq 'translator'))
            {
                $self->{isTranslator} = 1 ;
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'Carousel1')
            {
                $self->{isCover} = 1;
            }
            elsif ($self->{isCover} eq 1 && $attr->{itemprop} eq 'image')
            {
                $self->{curInfo}->{cover} = $attr->{src} if ($self->{curInfo}->{cover} eq "");
                $self->{isCover} = 0;
            }
            elsif ($self->{isCollection} eq 1 && $tagname eq 'span' && $attr->{class} eq 'productDetails-items-content')
            {
                $self->{isCollection} = 2 ;
            }
            elsif ($self->{isCollection} eq 2 && $tagname eq 'span')
            {
                $self->{isCollection} = 3 ;
            }
            elsif ($self->{isGenre} eq 1 && $tagname eq 'span' && $attr->{class} eq 'productDetails-items-content')
            {
                $self->{isGenre} = 2 ;
            }
            elsif ($self->{isGenre} eq 2 && $tagname eq 'span')
            {
                $self->{isGenre} = 3 ;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'isbn')
            {
                $self->{isISBN} = 1 ;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'inLanguage')
            {
                $self->{isLanguage} = 1 ;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'productDetails')
            {
                $self->{isAnalyse} = 1 ;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
    }

    sub text
    {
        my ($self, $origtext) = @_;

        # Enleve les blancs en debut de chaine
        $origtext =~ s/^\s+//;
        # Enleve les blancs en fin de chaine
        $origtext =~ s/\s+$//g;

        if ($self->{parsingList})
        {
            if ($self->{isAuthor})
            {
                if ($origtext =~ m/Les outils de recherche/i)
                {
                    # the search failed
                    $self->{isAuthor} = 0;
                    return;
                }
                if ($self->{itemsList}[$self->{itemIdx}]->{authors} eq '')
                {
                   $self->{itemsList}[$self->{itemIdx}]->{authors} = $origtext;
                }
                else
                {
                   $self->{itemsList}[$self->{itemIdx}]->{authors} .= ', '.$origtext;
                }
                $self->{isAuthor} = 0 ;
            }
            elsif ($self->{isPublisher} && $origtext =~ m/Editeur/)
            {
                $origtext =~ s/Editeur : //;
                $origtext =~ s/\.$//;
                my @array = split(/\n/,$origtext);
                $self->{itemsList}[$self->{itemIdx}]->{edition} = $array[0];
                $self->{isPublisher} = 0 ;
            }
            elsif ($self->{isPublication} && $origtext =~ m/Date de parution/)
            {
                $origtext =~ s/Date de parution ://;
                $origtext =~ s/\.$//;
                my @array = split(/\n/,$origtext);
                $self->{itemsList}[$self->{itemIdx}]->{publication} = $array[0];
                $self->{isPublication} = 0 ;
            }
        }
        else
        {
            if ($self->{isTitle})
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAuthor} eq 1)
            {
                if ( $origtext ne '')
                {
                   my @array = split(/;/,$origtext);
                   my $element;
                   foreach $element (@array)
                   {
                      my @nom_prenom = split(/,/,$element);
                      # Enleve les blancs en debut de chaine
                      $nom_prenom[0] =~ s/^\s//;
                      $nom_prenom[1] =~ s/^\s//;
                      # Enleve les blancs en fin de chaine
                      $nom_prenom[0] =~ s/\s+$//;
                      $nom_prenom[1] =~ s/\s+$//;
                      if ($self->{curInfo}->{authors} eq '')
                      {
                         if ($nom_prenom[1] ne '')
                         {
                            $self->{curInfo}->{authors} = $nom_prenom[1] ." " . $nom_prenom[0];
                         }
                         else
                         {
                            $self->{curInfo}->{authors} = $nom_prenom[0];
                         }
                      }
                      else
                      {
                         if ($nom_prenom[1] ne '')
                         {
                            $self->{curInfo}->{authors} .= ", " . $nom_prenom[1] ." " . $nom_prenom[0];
                         }
                         else
                         {
                            $self->{curInfo}->{authors} .= ", " . $nom_prenom[0];
                         }
                      }
                   }
                   $self->{isAuthor} = 0 ;
                }
            }
            elsif ($self->{isTranslator} eq 1)
            {
                $self->{curInfo}->{translator} = $origtext;
                $self->{isTranslator} = 0 ;
            }
            elsif ($self->{isPublisher} eq 2)
            {
                $self->{curInfo}->{publisher} = $origtext;
                $self->{isPublisher} = 0 ;
            }
            elsif ($self->{isDescription} eq 2)
            {
                $self->{curInfo}->{description} = $origtext;
                $self->{isDescription} = 3;
            }
            elsif ($self->{isDescription} eq 4)
            {
                $self->{curInfo}->{description} .= '\n'.$origtext;
                $self->{isDescription} = 0;
            }
            elsif ($self->{isPublication})
            {
                $self->{curInfo}->{publication} = $origtext;
                $self->{isPublication} = 0 ;
            }
            elsif ($self->{isISBN})
            {
                $origtext =~ s/^978// if length($origtext) > 10;
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }
            elsif ($self->{isPage})
            {
                if ($origtext ne '')
                {
                   $self->{curInfo}->{pages} = $origtext;
                   $self->{isPage} = 0 ;
                }
            }
            elsif ($self->{isCollection} eq 3)
            {
                $self->{curInfo}->{serie} = $origtext;
                $self->{isCollection} = 0 ;
            }
            elsif ($self->{isGenre} eq 3)
            {
                $origtext =~ s|/|,|gi;
                $self->{curInfo}->{genre} = $origtext;
                $self->{isGenre} = 0 ;
            }
            elsif ($self->{isLanguage})
            {
                $self->{curInfo}->{language} = $origtext;
                $self->{isLanguage} = 0 ;
            }
            elsif ($self->{isAnalyse})
            {
                $self->{isCollection} = 1 if ($origtext =~ m/Collection/i);
                $self->{isPage} = 1 if ($origtext =~ m/Nombre de page/i);
                $self->{isGenre} = 1 if ($origtext =~ m/Cat.+gorie/i);
            }
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
            authors => 1,
            publication => 1,
            format => 0,
            edition => 1,
            serie => 1,
            isbn => 1,
            pages => 1,
            publisher => 1,
        };

        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isPublisher} = 0;
        $self->{isPublication} = 0;
        $self->{isAnalyse} = 0;
        $self->{isDescription} = 0;
        $self->{isISBN} = 0;
        $self->{isLanguage} = 0;
        $self->{isCollection} = 0;
        $self->{isTranslator} = 0;
        $self->{isGenre} = 0;
        $self->{isCover} = 0;

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        if ($self->{parsingList})
        {
            $html =~ s|<b>||gi;
            $html =~ s|</b>||gi;
        }
        else
        {
            $html =~ s|<u>||gi;
            $html =~ s|<li>|\n* |gi;
            $html =~ s|<br>|\n|gi;
            $html =~ s|<br />|\n|gi;
            $html =~ s|<b>||gi;
            $html =~ s|</b>||gi;
            $html =~ s|<i>||gi;
            $html =~ s|</i>||gi;
            $html =~ s|<p>|\n|gi;
            $html =~ s|</p>||gi;
            $html =~ s|\x{92}|'|g;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
            $html =~ s|\n+|\n|gi;
        }
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        # utilisation d'une requête GET à la place d'un POST
        #return ('http://www.chapitre.com/CHAPITRE/fr/search/Default.aspx?search=true', ["quicksearch" => "$word"] );
        #return "http://www.chapitre.com/CHAPITRE/fr/search/Default.aspx?quicksearch=" . $word . "&optSearch=BOOKS";
        return "https://www.chapitre.com/search/Default.aspx?cleanparam=&ne=&n=0&auteur=&peopleId=&quicksearch="
                .$word
                ."&editeur=&reference=&plng=&optSearch=&beginDate=&endDate="
                ."&mot_cle=&prix=&themeId=&collection=&subquicksearch=&page=1";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
    }

    sub getName
    {
        return "Chapitre.com";
    }

    sub getCharset
    {
        my $self = shift;
        return "ISO-8859-15";
    }

    sub getAuthor
    {
        return 'TPF - Kerenoc';
    }

    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }
}

1;
