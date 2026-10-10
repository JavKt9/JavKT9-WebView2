package GCPlugins::GCbooks::GCFnac;

###################################################
#
#  Copyright 2005-2006 Tian
#  Copyright 2015-2017 Kerenoc
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

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginFnac;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);
    
    use URI::Escape;

    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        
        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class} eq "Article-itemInfo")
            {
                $self->{isTitle} = 1;
                $self->{isPublisher} = 0;
            }        
            elsif ($self->{isTitle} eq 1 && $tagname eq 'a' && $attr->{class} eq " js-minifa-title")
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
                $self->{isTitle} = 2;
            }
            elsif ($tagname eq 'p' && $attr->{class} eq "Article-descSub")
            {
                $self->{isAuthor} = 1;
            }
            elsif ($self->{isAuthor} eq 1 && $tagname eq 'a')
            {
                $self->{isAuthor} = 2;
            }
            elsif ($self->{isAuthor} && $tagname eq 'div')
            {
                $self->{isAuthor} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq "editorialInfo")
            {
                $self->{isAnalyse} = 1;
            }
        }
        else
        {
            if ($attr->{class} =~ m/productHeader-Title/)
            {
                $self->{isTitle} = 1 ;
            }
            elsif (($tagname eq 'div') && ($attr->{class} eq 'ProductHeader-subTitle'))
            {
                $self->{isTitle} = 1 ;
            }
            elsif (($self->{isAuthor} eq 1) && ($tagname eq 'a'))
            {
                $self->{isAuthor} = 2 ;
            }
            elsif (($tagname eq 'img') && ($attr->{class} =~ m/f-productVisuals-main/i))
            {
                $self->{curInfo}->{cover} = $attr->{src} ;
            }
            elsif ($tagname eq 'section' && $attr->{id} eq 'ficheResume')
            {
                $self->{isDescription} = 1 ;
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'productStrateTop')
            {
                $self->{isDescription} = 1 ;
            }
            elsif ($self->{isDescription} eq 1 && $tagname eq 'div' && $attr->{class} eq 'whiteContent')
            {
                $self->{isDescription} = 2 ;
            }
            elsif (($tagname eq 'ul') && ($attr->{class} =~ m/Feature-list/))
            {
                $self->{isAnalyse} = 1 ;
                $self->{isDescription} = 0;
            }
            elsif (($tagname eq 'span') && ($attr->{class} =~ m/Feature-label/))
            {
                $self->{isAnalyse} = 2 ;
            }
            elsif (($self->{isAnalyse} eq 1) && ($attr->{class} =~ m/Feature-desc/))
            {
                $self->{isPublisher} = 2 if ($self->{isPublisher});
                $self->{isPublication} = 2 if ($self->{isPublication});
                $self->{isSerie} = 2 if $self->{isSerie}; 
                $self->{isISBN} = 2 if $self->{isISBN}; 
                $self->{isPage} = 2 if $self->{isPage}; 
                $self->{isAuthor} = 2 if $self->{isAuthor};
                $self->{isTranslator} = 2 if $self->{isTranslator};
                $self->{isArtist} = 2 if $self->{isArtist};
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;

        if ($tagname eq 'div')
        {
            $self->{isAnalyse} = 0;
            $self->{isAuthor} = 0;
            # parfois des descriptions en double : resume + le mot de l'editeur
            # meme contenu avec une orthographe et une mise en page différente!
            $self->{isDescription} = 0 if ($self->{isDescription} eq 2);
        }
        elsif ($self->{isAnalyse} eq 2 && $tagname eq 'strong')
        {
            $self->{isAnalyse} = 1;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        # Enleve les blancs en debut et fin de chaine
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;
        if ($self->{parsingList})
        {
            if ($self->{isTitle} eq 2)
            {
                $origtext = '-'.$origtext if ($self->{itemsList}[$self->{itemIdx}]->{title} ne '');
                $self->{itemsList}[$self->{itemIdx}]->{title} .= $origtext if ($origtext ne '-' && $origtext ne '');      
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAnalyse} > 0)
            {
                my @listInfo = split(/\n/, $origtext);
                my $nbInfos = scalar @listInfo ;
                return if ($nbInfos eq 1);
                    
                my $publication = $listInfo[$nbInfos-1];
                $publication =~ s/^[-\s]+//;
                $publication =~ s/\s+$//g;
                $self->{itemsList}[$self->{itemIdx}]->{publication} = $publication;
                my $edition = $listInfo[$nbInfos-2];
                $edition =~ s/^[-\s]+//;
                $edition =~ s/\s+$//g;
                $self->{itemsList}[$self->{itemIdx}]->{edition} = $edition;
            }
            elsif ($self->{isAuthor} eq 2)
            {
                $origtext = ', '.$origtext if ($self->{itemsList}[$self->{itemIdx}]->{authors} ne ''); 
                $self->{itemsList}[$self->{itemIdx}]->{authors} .= $origtext if ($origtext ne '' && $origtext ne ', ');
                $self->{isAuthor} = 1;
            }
        }
        else
        {
            if ($self->{isTitle} eq '1')
            {
                $origtext = ' - '.$origtext if ($self->{curInfo}->{title} ne '');
                $self->{curInfo}->{title} .= $origtext if ($origtext ne '' && $origtext ne ' - ');
                if ($self->{curInfo}->{title} =~ /(.*) - Tome (\d+) : /)
                {
                    $self->{curInfo}->{serie} = $1;
                    $self->{curInfo}->{volume} = $2;
                }
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAnalyse} eq 2)
            {
                $self->{isISBN} = 1 if ($origtext =~ m/ISBN/i);
                $self->{isPublisher} = 1 if ($origtext =~ m/Editeur/i);
                $self->{isFormat} = 1 if ($origtext =~ m/Format/i);
                $self->{isSerie} = 1 if ($origtext =~ m/Collection/i);
                $self->{isPublication} = 1 if ($origtext =~ m/Date de parution/i);
                $self->{isPage} = 1 if ($origtext =~ m/pages/i);
                $self->{isTranslator} = 1 if ($origtext =~ m/Traduction/i);
                $self->{isArtist} = 1 if ($origtext =~ m/Illustration/i);
                $self->{isAuthor} = 1 if ($origtext =~ m/(Auteur|Dessinateur|Sc.nario)/i);
                $self->{isAnalyse} = 1 ;
            }
            elsif ($self->{isAuthor} eq 2)
            {
                # Enleve les virgules
                $origtext =~ s/,//;
                $origtext = ','.$origtext if ($self->{curInfo}->{authors});
                $self->{curInfo}->{authors} .= $origtext;
                $self->{isAuthor} = 0;
            }
            elsif ($self->{isTranslator} eq 2)
            {
                # Enleve les virgules
                $origtext =~ s/,//;
                $self->{curInfo}->{translator} = $origtext;
                $self->{isTranslator} = 0;
            }
            elsif ($self->{isArtist} eq 2)
            {
                # Enleve les virgules
                $origtext =~ s/,//;
                $self->{curInfo}->{artist} = $origtext if ! ($origtext =~ m/illustration/i);
                $self->{isArtist} = 0;
            }
            elsif ($self->{isISBN} eq 2)
            {
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }
            elsif ($self->{isPublisher} eq 2)
            {
                $self->{curInfo}->{publisher} = $origtext;
                $self->{isPublisher} = 0 ;
            }
            elsif ($self->{isFormat} eq 2)
            {
                $self->{curInfo}->{format} = $origtext;
                $self->{isFormat} = 0 ;
            }
            elsif ($self->{isSerie} eq 2)
            {
                if ($origtext =~ m/(.*),.* ([0-9]+) *$/)
                {
                    $self->{curInfo}->{edition} = $1;
                    $self->{curInfo}->{rank} = $2;
                }
                else 
                {
                    $self->{curInfo}->{edition} = $origtext;
                }
                $self->{isSerie} = 0 ;
            }
            elsif ($self->{isPublication} eq 2)
            {
                $self->{curInfo}->{publication} = $self->decodeDate($origtext) 
                    if (!$self->{curInfo}->{publication});
                $self->{isPublication} = 0 ;
            }
            elsif (($self->{isPage} eq 2))
            {
                $self->{curInfo}->{pages} = $origtext;
                $self->{isPage} = 0 ;
            }
            elsif ($self->{isDescription} eq 2)
            {
                $origtext =~ s/\r\n/ /g;
                $self->{curInfo}->{description} .= $origtext."\n" if ($origtext ne '');
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
            format => 1,
            edition => 1,
            serie => 0,
            translator => 1,
            isbn => 1,
            pages => 1,
            publisher => 1,
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        if (1 eq 0 && ! $self->{parsingList})
        {
            # est-ce encore necessaire?
            $html =~ s|<li>|\n* |gi;
            $html =~ s|<br>|\n|gi;
            $html =~ s|<br />|\n|gi;
            $html =~ s|<b>||gi;
            $html =~ s|</b>||gi;
            $html =~ s|<i>||gi;
            $html =~ s|</i>||gi;
            $html =~ s|<p>|\n\r|gi;
            $html =~ s|</p>||gi;
            $html =~ s|</h4>||gi;
            $html =~ s|\x{92}|'|g;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
        }        

        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isPublisher} = 0;
        $self->{isISBN} = 0;
        $self->{isPublication} = 0;
        $self->{isFormat} = 0;
        $self->{isSerie} = 0;
        $self->{isPage} = 0;
        $self->{isDescription} = 0;
        $self->{isTranslator} = 0;
        $self->{isArtist} = 0;

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        
        # suppression des accents
        $word =~ s/%E[89AB]/e/g ; 
        $word =~ s/%E[024]/a/g ;
        $word =~ s/%E[EF]/i/g ;
        $word =~ s/%F[9B]/u/g ;
        $word =~ s/%F[46]/o/g ;
        $word =~ s/%E7/c/g ;

        return "http://www.fnac.com/search/quick.do?filter=-3&text=". $word ."&category=book";
    }
    
    sub getItemUrl
    {
        my ($self, $url) = @_;
                
        return $url if $url;
        return 'http://www.fnac.com/';
    }

    sub getName
    {
        return "ZZZ Fnac (FR)";
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
        return ['title', 'isbn', 'authors'];
    }

    sub decodeDate
    {
        my ($self, $date) = @_;

        # date déjà dans le bon format
        return $date if ($date =~ m|/.*/|);

        $date = GCUtils::strToTime($date,"%e %B %Y","FR");
        return GCUtils::strToTime($date,"%B %Y","FR");
    }
}

1;
