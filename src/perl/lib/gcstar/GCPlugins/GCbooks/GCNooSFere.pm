package GCPlugins::GCbooks::GCNooSFere;

###################################################
#
#  Copyright 2005-2006 Tian
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

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginNooSFere;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    use URI::Escape;
    
    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if (($tagname eq 'span') && ($attr->{class} eq 'TitreNiourf'))
            {
                $self->{parsingList} = 0;
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{loadedUrl};                
            }
            elsif ($tagname eq 'meta' && $attr->{'http-equiv'} eq 'refresh')
            {
                # single book response from website : redirection to the item's page
                $self->{parsingList} = 0;
                $self->{itemIdx}++;
                my $content = $attr->{content};
                $content =~ s/.*URL=//;
                $self->{itemsList}[$self->{itemIdx}]->{url} = "https://www.noosfere.org".$content;
            	
            }
            elsif (($tagname eq 'td') && ($attr->{class} eq 'onglet_bleu'))
            {
                $self->{isFound} = 1 ;
            }
            elsif (($tagname eq 'td' && $attr->{class} eq 'item_puce')
                    || $tagname eq 'h1'
                    || ($tagname eq 'span' && $attr->{class} eq 'resultat_search')
                    || $attr->{class} eq 'TitreNiourf')  # fiche edition ou fiche livre
            {
                $self->{isTitle} = 1;
                $self->{saveAuthors} = '';
                $self->{saveSerie} = '';
                $self->{savePublisher} = '';
                $self->{saveEdition} = '';
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m/editionslivre.asp\?.*item.*=/i) && !($attr->{href} =~ m/numediteur=/i) && !($attr->{href} =~ m/tri=/i))
            {
                $self->{isTitle} = 1 ;
                $self->{isAuthors} = 0 ;
                $self->{loadUrl} = "https://www.noosfere.org" . $attr->{href};
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|/livres/auteur.asp\?NumAuteur=|i) && ($self->{isAuthors} eq 0))
            {
                $self->{isAuthors} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|./editeur.asp\?numediteur=|i))
            {
                $self->{isPublisher} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|./collection.asp\?NumCollection=|i))
            {
                     $self->{isEdition} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|./serie.asp\?NumSerie=|i) && ! $self->{saveSerie})
            {
                $self->{isSerie} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m/editionslivre.asp\?.*item.*=/i) && ($attr->{href} =~ m/numediteur=/i))
            {
				$attr->{href} += '/livres/' if ! $attr->{href} =~ /^\//;
                $self->{loadUrl} = "https://www.noosfere.org" . $attr->{href};
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|./niourf.asp\?numlivre=|i) && $self->{isFound} ne 2)
            {
				$attr->{href} += '/livres/' if ! $attr->{href} =~ /^\//;
                $self->{saveUrl} = "https://www.noosfere.org" . $attr->{href};
            }
            elsif (($tagname eq 'td') && ($attr->{class} eq 'onglet_biblio1'))
            {
                $self->{isAuthors} = 2 ;
            }
            elsif (($tagname eq 'table') && ($attr->{class} eq 'piedpage'))
            {
                $self->{isAuthors} = 0 ;
            }
        }
        else
        {
            if (($tagname eq 'span') && ($attr->{class} eq 'TitreNiourf'))
            {
                $self->{isAnalyse} = 0 ;
                $self->{isTitle} = 1 ;
                $self->{isAuthors} = 0 ;
            }
            elsif (($tagname eq 'span') && ($attr->{class} eq 'AuteurNiourf'))
            {
                $self->{isAuthors} = 1 ;
            }
            elsif (($tagname eq 'span') && ($attr->{class} eq 'sousFicheNiourf'))
            {
                $self->{isAnalyse} = 1;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|/livres/auteur.asp\?NumAuteur=|i) && ($self->{isAuthors} eq 1))
            {
                $self->{isAuthors} = 2 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|actu_annee.asp\?|i))
            {
                $self->{isPublication} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|editeur.asp\?numediteur=|i) && ($self->{curInfo}->{publisher} eq ''))
            {
                $self->{isPublisher} = 1 ;
                $self->{isArtist} = 0;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|serie.asp\?NumSerie=|i) && ($self->{curInfo}->{serie} eq ''))
            {
                $self->{isSerie} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|collection.asp\?NumCollection=|i) && ($self->{curInfo}->{edition} eq ''))
            {
                $self->{isEdition} = 1 ;
            }
            elsif (($tagname eq 'a') && ($attr->{href} =~ m|/livres/auteur.asp\?NumAuteur=|i) && ($self->{isTranslator} eq 1))
            {
                $self->{isTranslator} = 2 ;
            }
            elsif (($tagname eq 'font') && ($attr->{style} eq 'font-size:14px;') && ($self->{isAnalyse} eq 0))
            {
                $self->{isAnalyse} = 1 ;
            }
            elsif ($tagname eq 'img' && $attr->{name} eq "couverture" && (! $self->{curInfo}->{cover}))
            {
                $self->{curInfo}->{cover} = $attr->{src} ;
            }
            elsif ($tagname eq 'br')
            {
                $self->{isPublisher} = 0;
                $self->{isTranslator} = 0;
                $self->{isSerie} = 0;
                $self->{isTranslation} = 1 if ($self->{isAuthors} > 0);
                $self->{isAuthors} = 0;
                $self->{curInfo}->{description} .= "\n" if ($self->{isDescription});
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ m/R.*sumes|Sommaire|List/)
            {
                # categories : R.*sumes|Sommaire|ListRef|CitationListes
                $self->{isDescription} = 1;
            }
            elsif ($tagname eq 'style')
            {
                $self->{isDescription} = 0;
            }
            elsif ($self->{isDescription})
            {
                $self->{curInfo}->{description} .= "\n" if ($tagname eq 'tr' && $self->{curInfo}->{description});
            }
        }
    }

    sub wasUrlDetected()
    {
        my ($self, $url) = @_;
        
        foreach (@{$self->{itemsList}})
        {
            return 1 if ($_->{url} eq $url);
        }
        return 0;
    }
    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        $self->{isAnalyse} = 0 if ($tagname eq 'span');
        $self->{curInfo}->{description} .= "\n" if ($self->{isDescription} && $tagname eq 'div');
        if ($self->{parsingList})
        {
            if (($tagname eq 'table' || $tagname eq 'tr') && $self->{saveUrl})
            {
                if ($self->wasUrlDetected($self->{saveUrl}))
                {
                    $self->{saveUrl} = '';
                    $self->{saveAuthors} = '';
                    $self->{saveSerie} = '';
                }
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{title} = $self->{saveTitle};
                $self->{itemsList}[$self->{itemIdx}]->{authors} = $self->{saveAuthors};
                $self->{itemsList}[$self->{itemIdx}]->{serie} = $self->{saveSerie};
                $self->{itemsList}[$self->{itemIdx}]->{publisher} = $self->{savePublisher};
                $self->{itemsList}[$self->{itemIdx}]->{edition} = $self->{saveEdition};
                $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{saveUrl};
                $self->{saveAuthors} = '';
                $self->{saveSerie} = '';
                $self->{saveUrl} = '';
            }
            elsif ($tagname eq 'td' && $self->{loadUrl})
            {
                # test if page already processed
                foreach (@{$self->{loadedUrls}})
                { 
                    return if $_ eq $self->{loadUrl};
                }
                push @{$self->{loadedUrls}}, $self->{loadUrl};
                
                my $html = $self->loadPage($self->{loadUrl} , 0, 0 );
                my $found = index($html,"Fiche livre&nbsp;: les &eacute;ditions");
                if ( $found >= 0 )
                {
                   while (index($html,"./niourf.asp?numlivre="))
                   {
                      $found = index($html,"./niourf.asp?numlivre=");
                      if ( $found >= 0 )
                      {
                         my $index0 = $found +length('./niourf.asp?numlivre=');
                         my $index1 = index($html, "\"",$index0);
                         my $index2 = index($html, "\'",$index0);
                         $index1 = $index2 if ($index1 <1 || $index2 < $index1);
                         
                         my $url = "https://www.noosfere.org/livres/niourf.asp?numlivre=" . substr($html,$index0,$index1-$index0);
                         if (! $self->wasUrlDetected($url))
                         {
                             $index2 = index($html, "numediteur", $index0);
                             $index2 = index($html, ">", $index2);
                             my $index3 = index($html, "<", $index2);
                             $self->{itemIdx}++;
                             $self->{itemsList}[$self->{itemIdx}]->{title} = $self->{saveTitle};
                             $self->{itemsList}[$self->{itemIdx}]->{authors} = $self->{saveAuthors};
                             $self->{itemsList}[$self->{itemIdx}]->{serie} = $self->{saveSerie};
                             $self->{itemsList}[$self->{itemIdx}]->{publisher} = $self->{savePublisher};
                             $self->{itemsList}[$self->{itemIdx}]->{edition} = $self->{saveEdition};
                             $self->{itemsList}[$self->{itemIdx}]->{url} = $url;
                             
                             my $index4 = index($html, "numcollection=", $index3);
                             my $index5 = index($html, "numediteur=", $index3);
                             if ($index4 > 0 && ($index4 < $index5 || $index5 < 0) )
                             {
                                 # get collection
                                 $index4 = index($html, '>', $index4);
                                 $index5 = index($html, "</", $index4);
                                 $self->{itemsList}[$self->{itemIdx}]->{edition} = substr($html, $index4+1, $index5-$index4-1);
                             }
                         }
                         $html = substr($html, $index0, length($html)-$index0);
                      }
                      else
                      {
                         last;
                      }
                   }
                }
                else
                {
                   if ($self->wasUrlDetected($self->{loadUrl}))
                   {
                       $self->{loadUrl} = '';
                       return;
                   }
                   $self->{itemIdx}++;
                   $self->{itemsList}[$self->{itemIdx}]->{title} = $self->{saveTitle};
                   $self->{itemsList}[$self->{itemIdx}]->{authors} = $self->{saveAuthors};
                   $self->{itemsList}[$self->{itemIdx}]->{serie} = $self->{saveSerie};
                   $self->{itemsList}[$self->{itemIdx}]->{edition} = $self->{saveEdition};
                   $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{loadUrl};
                }
                $self->{saveAuthors} = '';
                $self->{saveSerie} = '';
                $self->{loadUrl} = '';
            }
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        if ($self->{parsingList})
        {
            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en fin de chaine
            $origtext =~ s/\s+$//g;
            if ($self->{isTitle})
            {
                $self->{saveTitle} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAuthors} eq 1)
            {
                if (($self->{saveAuthors} eq '') && ($origtext ne ''))
                {
                   $self->{saveAuthors} = $origtext;
                }
                elsif ($origtext ne '')
                {
                   $self->{saveAuthors} .= ', ';
                   $self->{saveAuthors} .= $origtext;
                }
                $self->{isAuthors} = 0 ;
            }
            elsif ($self->{isPublisher})
            {
                $self->{savePublisher} = $origtext;
                $self->{isPublisher} = 0 ;
            }
            elsif ($self->{isEdition})
            {
                $self->{saveEdition} = $origtext;
                $self->{isEdition} = 0 ;
            }
            elsif ($self->{isSerie})
            {
                if ($origtext eq ')')
                {
                    $self->{isSerie} = 0;
                }
                else
                {
                    $self->{saveSerie} .= $origtext;
                }
            }
            elsif ($self->{isFound} eq 1)
            {
                if ($origtext eq 'Fiche livre')
                {
                   # directly on final page : the search list has only one book
                   $self->{saveUrl} = $self->{loadedUrl};
                   $self->{isFound} = 2;
                   #$self->{itemIdx}++;
                   #$self->{itemsList}[$self->{itemIdx}]->{url} = $self->{loadedUrl};
                   #$self->{isFound} = 2 ;
                }
                else
                {
                   $self->{isFound} = 0 ;
                }
            }
        }
        else
        {
            return if ($origtext eq '');

            if ($self->{isDescription})
            {
                # if ($origtext =~ m/Pas de texte sur la quatri.me de couverture\./i)
                return if ($origtext =~ /^[\r\t ]*$/);
                my $s = $self->{curInfo}->{description}.$origtext;
                $s =~ s/[\r\t]//g;
                $s =~ s/  *( |,|\.)/$1/g;
                $s =~ s/\n\n*\s\s*/\n\n/g;
                $s =~ s/^[\n\s]//;
                $self->{curInfo}->{description} = $s;
                return;
            }

            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en fin de chaine
            $origtext =~ s/\s+$//g;

            if ($origtext =~ m/Titre original/)
            {
                $self->{isTranslation} = 1;
            }
            elsif ($origtext =~ m/Traduction de/i)
            {
                $self->{isTranslator} = 1;
                $self->{isAuthors} = 0;
                $origtext =~ s/ *Traduction.*//;
            }
            elsif ($self->{isTitle} eq '1')
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isPublication})
            {
                $self->{curInfo}->{publication} = $self->decodeDate($origtext);
                $self->{isPublication} = 0;
                $self->{isAnalyse} = 1;
            }
            elsif ($self->{isAnalyse} eq 1)
            {
               if ($origtext =~ m/([0-9][0-9]*) *pages/)
               {
                  $self->{curInfo}->{pages} = $1;
               }
               elsif ($origtext =~ m/ISBN : ([^ ]*)/)
               {
                  $self->{curInfo}->{isbn} = $1;
                  $self->{curInfo}->{isbn} =~ s/-//g;
               }
               elsif ($origtext =~ m/Format : (.*)/)
               {
                  $self->{curInfo}->{format} = $1;
               }
               elsif ($origtext =~ m/D.*p.*t l.*gal :\s*([1-4]*).*trimestre\s*([0-9]*)/)
               {
                   my $trimestre = $1;
                   my $annee = $2;
                   my $date = "01/".($trimestre*3-2)."/".$annee;
                   $self->{curInfo}->{publication} = $self->decodeDate($date);
               }
               elsif ($origtext =~ m/Genre : (.*)/)
               {
                   $self->{curInfo}->{genre} = $1;
               }
            }
            elsif ($self->{isAuthors} eq 2)
            {
                if (! ($origtext =~ m/^[-A-Z ]+$/) && ($origtext =~ m/ /))
                {
                    # detect surname in capital letter and invert with name
                    $origtext = reverse $origtext;
                    $origtext =~ s/^([-A-ZaciÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÔÖ ]+) (.*)/$2 $1/;
                    $origtext = reverse $origtext;
                }
                if (($self->{curInfo}->{authors} eq '') && ($origtext ne ''))
                {
                   $self->{curInfo}->{authors} = $origtext;
                }
                elsif ($origtext ne '')
                {
                   $self->{curInfo}->{authors} .= ', '.$origtext;
                }
                $self->{isAuthors} = 1 ;
            }
            elsif ($self->{isTranslation} eq 1)
            {
                $self->{curInfo}->{original} = $origtext;
                $self->{isTranslation} = 0;
            }
            elsif ($self->{isTranslator} eq 1)
            {
                    #elsif ($origtext =~ m/Cycle /i)
                    #{
                    # $self->{isAuthors} = 0;
                    #}
                    $origtext =~ s/[^ a-zA-Z].*//;
                    $self->{curInfo}->{genre} = $origtext;
                    $self->{isAuthors} = 0;
            }
            elsif ($self->{isPublisher} eq 1)
            {
                $self->{curInfo}->{publisher} = $origtext;
                $self->{isPublisher} = 2 ;
            }
            elsif ($self->{isEdition} eq 1)
            {
                $self->{curInfo}->{edition} = $origtext;
                $self->{isEdition} = 2 ;
            }
            elsif ($self->{isEdition} eq 2)
            {
                my $numero = $origtext;
                $numero =~ s/[-,].*//;
                $numero =~ s/[^0-9]*//g;
                $self->{curInfo}->{rank} = $numero if ($numero =~ m/[0-9]+/);
                $self->{isEdition} = 0 ;
            }
            elsif ($self->{isSerie} eq 1)
            {
                $self->{curInfo}->{serie} = $origtext;
                $self->{isSerie} = 2 ;
            }
            elsif ($self->{isSerie} eq 2)
            {
                return if ($origtext eq '');
                my $numero = $origtext;
                $numero =~ s/,.*//;
                return if ! ($numero =~ m/[0-9]+/);
                $self->{curInfo}->{volume} = $numero;
            }
            elsif ($self->{isTranslator} > 0)
            {
                $origtext = ", ".$origtext if ($self->{curInfo}->{translator});
                $self->{curInfo}->{translator} .= $origtext if ($origtext ne ", &");
            }
            elsif ($self->{isArtist} > 0 && $origtext)
            {
                $origtext = ", ".$origtext if ($self->{curInfo}->{artist});
                $self->{curInfo}->{artist} .= $origtext if ($origtext ne ", &");
            }
            elsif ($origtext =~ m/Traduction de/i)
            {
                $self->{isTranslator} = 1;
                $self->{isAuthors} = 0;
            }
            elsif ($origtext =~ m/Illustration de/i)
            {
                $self->{isArtist} = 1;
                $self->{isTranslator} = 0;
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
            publication => 0,
            publisher => 1,
            format => 0,
            edition => 1,
            serie => 1,
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{saveTitle} = '';
        $self->{saveAuthors} = '';
        $self->{saveEdition} = '';
        $self->{saveSerie} = '';
        $self->{savePublisher} = '';
        $self->{isFound} = 0;
        $self->{isTitle} = 0;
        $self->{isAuthors} = 0;
        $self->{isPublisher} = 0;
        $self->{isEdition} = 0;
        $self->{isPublication} = 0;
        $self->{isSerie} = 0;
        $self->{isDescription} = 0;
        $self->{isTranslator} = 0;
        $self->{isTranslation} = 0;
        $self->{isAnalyse} = 0;
        $self->{isArtist} = 0;
        $self->{isVolume} = 0;
        $self->{loadedUrls} = ();

        if ($self->{parsingList})
        {
        }
        else
        {
            # transcodage des caractères spéciaux
            $html =~ s|\x{92}|'|g;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#156;|oe|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
            return $html;
        }
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

	    #return "https://www.noosfere.org/livres/cyborg_livre.asp?mini=1000&maxi=3000&mode=Idem&EtOuParution=NS&isbn=". $word;
        #return "https://www.noosfere.org/livres/cyborg_livre.asp?mini=1000&maxi=3000&mode=Tous&EtOuParution=NS&titre=". $word;
        return "https://www.noosfere.org/noosearch_simple.asp?Mots=". $word;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url if $url;
        return 'https://www.noosfere.org/';
    }

    sub getName
    {
        return "NooSFere";
    }

    sub getCharset
    {
        my $self = shift;
        return "ISO-8859-15";
    }

    sub getAuthor
    {
        return 'TPF - Varkolak - Kerenoc - HDA12/BMHD';
    }

    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }

    sub decodeDate
    {
        my ($self, $date) = @_;

        # date déjà dans le bon format
        return $date if ($date =~ m|/.*/|);
        # année seule
        return "01/01/".$date if ($date =~ m/^[0-9]+$/);
        # pas d'année
        return '' if (! $date =~ m/[0-9][0-9][0-9][0-9]/);
        if ($date =~ m/trimestre/)
        {
            $date =~ s/[^0-9]* *trimestre */ /;
            my @dateItems = split(/\s/, $date);
            $date = "01/01/".$dateItems[1] if ($dateItems[0] eq '1');
            $date = "01/04/".$dateItems[1] if ($dateItems[0] eq '2');
            $date = "01/07/".$dateItems[1] if ($dateItems[0] eq '3');
            $date = "01/10/".$dateItems[1] if ($dateItems[0] eq '4');
            return $date;
        }
        $date = GCUtils::strToTime($date,"%e %B %Y","FR");
        return  GCUtils::strToTime($date,"%B %Y","FR");
    }
}

1;
