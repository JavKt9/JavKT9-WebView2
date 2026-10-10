#
# More information here: http://wiki.gcstar.org/en/websites_plugins
#

package GCPlugins::GCcoins::GCNumista;

###################################################
#
#  Copyright 2005-2010 Tian
#  Copyright 2014-2020 MesBedes
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
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################

use strict;
use utf8;  # pour dire que le source est en utf8
use GCPlugins::GCcoins::GCcoinsCommon;
#use open qw(:std :utf8); # pour dire que les entrées et sorties sont par défaut en utf8

{
    package GCPlugins::GCcoins::GCPluginNumista;
    use base qw(GCPlugins::GCcoins::GCcoinsPluginsBase);
    use URI::Escape;

    # getSearchUrl
    sub getSearchUrl
    {
        my ($self, $word) = @_;
        my $url;
        # q=50 permet d'avoir 50 résultats dans la page
        # les valeurs possibles : 10, 20, 50 ou 100

        if ($self->{searchField} eq 'name')
        {
            # recherche simplifiée sur le nom de la monnaie
            # TODO : en cas d'espace en trop, exemple "20 francs 1848   "
            # Enlève les blancs en début de chaine
            $word =~ s/^\s*//;
            # Enlève les blancs en fin de chaine
            $word =~ s/\s*$//;
            # on remplace les espaces internes par des plus
            $word =~ s/ /\+/gi;
            $url = "https://fr.numista.com/catalogue/index.php?mode=simplifie&p=1&e=&d=&ca=3&no=&i=&v=&m=&a=&t=&dg=&w=&g=&f=&c=&tb=y&tc=y&tn=y&tp=y&tp=y&tt=y&te=y&cat=y&ct=coin&q=100&r=$word";
        }
        elsif ($self->{searchField} eq 'country')
            {
                # recherche sur le pays (&r=pays:nom traduit en &r=pays%3Anom)
                $url = "https://fr.numista.com/catalogue/index.php?ca=3&no=&c=&tb=y&tc=y&tn=y&tp=y&tp=y&tt=y&te=y&cat=y&mode=simplifie&p=1&e=&d=&i=&v=&m=&a=&t=&dg=&w=&g=&f=&ct=coin&q=100&r=pays:".$word;
            }
            else
            {
                # recherche par KM (&km=numero)
                # todo : ne marche pas si séparateur espace
                # KM# 757 ne fonctionne pas, il faut envoyer KM#757
                $word =~ s/ //;
                $url = "https://fr.numista.com/catalogue/index.php?mode=simplifie&p=1&e=&d=&ca=3&no=&i=&v=&m=&a=&t=&dg=&w=&g=&f=&c=&tb=y&tc=y&tn=y&tp=y&tp=y&tt=y&te=y&cat=y&ct=coin&q=100&r=".$word;
            }
        return $url;
    }

    # getItemUrl
    sub getItemUrl
    {
        my ($self, $url) = @_;
        my $absUrl;
        $absUrl = "https://fr.numista.com" . $url;
        return $absUrl;
    }

    # getCharset
    sub getCharset
    {
        my $self = shift;
        return "ISO-8859-1";
    }

    # getName
    sub getName
    {
        return "fr.numista";
    }

    # getAuthor
    sub getAuthor
    {
        return 'MesBedes';
    }

    # getLang
    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        return ['name', 'country', 'number1'];
    }

    # getSearchCharset
    sub getSearchCharset
    {
        my $self = shift;
        return "utf8";
    }

    # getExtra
    sub getExtra
    {
        return '';
    }

    # getNumberPasses
    sub getNumberPasses
    {
        return 1;
    }

    # changeUrl
    sub changeUrl
    {
        my ($self, $url) = @_;
        return $url;
    }

    # start
    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;
        if ($self->{parsingList})
        {
            # exploitation de la liste des résultats de la recherche
            if (($tagname eq "div") && ($attr->{id} eq "resultats_recherche"))
            {
                $self->{insideResults} = 1;
            }
            if ($self->{insideResults} eq 1)
            {
                if (($tagname eq "div") && ($attr->{class} eq "resultat_recherche") && ($attr->{class} ne "resultat_recherche_ad") && ($self->{isCoin} eq 0))
                {
                    $self->{isCoin} = 1;
                    $self->{itemIdx}++;
                    $self->{isInfo} = 0;
                }
                elsif (($tagname eq "div") && ($attr->{class} eq "photo_avers") && ($self->{isCoin} eq 1))
                {
                    $self->{isCoin} = 2;
                }
                elsif (($tagname eq "div") && ($attr->{class} eq "photo_revers") && ($self->{isCoin} eq 2))
                {
                    $self->{isCoin} = 3;
                }
                elsif (($tagname eq "div") && ($attr->{class} eq "description_piece") && ($self->{isCoin} eq 3))
                {
                    $self->{isCoin} = 4;
                }
                elsif (($tagname eq "span") && ($attr->{class} =~ /^sprite/) && ($self->{isCoin} eq 4))
                {
                    $self->{isCoin} = 5;
                    $self->{itemsList}[ $self->{itemIdx} ]->{country} = $attr->{title};
                }
                elsif (($tagname eq "a") && ($attr->{href} =~ /pieces(\d+)\.html/) && ($self->{isCoin} eq 5))
                {
                    my $url = $attr->{href};
                    $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                    # nom/série
                    $self->{isCoin} = 6;
                    $self->{isInfo} = 1;
                }
                elsif ($self->{isCoin} eq 6)
                {
                    # TODO : au 25/07/2020, les ND (non daté) ne renvoi pas la date entre parenthèse
                    # année
                    $self->{isCoin} = 7;
                }
                elsif ($self->{isCoin} eq 7)
                {
                    # TODO : au 25/07/2020, problème des balise BR qui empêchent le remplissage référence, valeur, atelier et métal
                    # TODO : ne fonctionne pas si ligne supplémentaire concernant la commémorative (une balise BR en plus)
                    # par exemple 100 shillings 2017 (Elephant) 
                    # métal
                    $self->{isCoin} = 8;
                }
                elsif ($self->{isCoin} eq 8)
                {
                    # TODO : au 25/07/2020, problème des balise BR qui empêchent le remplissage référence, valeur, atelier et métal
                    # TODO : ne fonctionne pas si ligne supplémentaire concernant la commémorative (une balise BR en plus)
                    # par exemple 100 shillings 2017 (Elephant) 
                    # référence
                    $self->{isCoin} = 9;
                }
                elsif ($self->{isCoin} eq 9)
                {
                    # pièce suivante
                    $self->{isCoin} = 10;
                }
            }
        }
        else
        {
            # le titre de la page
            if ($tagname eq "h1")
            {
                $self->{insideSerie} = 1;
            }
            elsif (($tagname eq "span") && ($self->{insideSerie} eq 1))
            {
                # attention : il n'y a pas forcément de balise <span> dans la balise <h1>
                $self->{insideSerie} = 2;
            }

            ### les infos techniques
            if (($tagname eq "section") && ($attr->{id} eq "fiche_caracteristiques"))
            {
                $self->{insideTech} = 1;
                $self->{insideSerie} = 0;
                $self->{insidePicture} = 0;
                $self->{insideCollec} = 0;
                $self->{insideDesc} = 0;
                $self->{insideEch} = 0;
                $self->{isVoir} = 0 ;
            }
            elsif ($tagname eq "td")
            {
                if ($self->{isCountry} eq 1)
                {
                    $self->{isCountry} = 2 ;
                }
                elsif ($self->{isAutorit} eq 1)
                {
                    $self->{isAutorit} = 2 ;
                }
                elsif ($self->{isPeriod} eq 1)
                {
                    $self->{isPeriod} = 2 ;
                }
                elsif ($self->{isType} eq 1)
                {
                    $self->{isType} = 2 ;
                }
                elsif ($self->{isYear} eq 1)
                {
                    $self->{isYear} = 2 ;
                }
                elsif ($self->{isCalend} eq 1)
                {
                    $self->{isCalend} = 2 ;
                }
                elsif ($self->{isValue} eq 1)
                {
                    $self->{isValue} = 2 ;
                }
                elsif ($self->{isCurrency} eq 1)
                {
                    $self->{isCurrency} = 2 ;
                }
                elsif ($self->{isMetal} eq 1)
                {
                    $self->{isMetal} = 2 ;
                }
                elsif ($self->{isWeight} eq 1)
                {
                    $self->{isWeight} = 2 ;
                }
                elsif ($self->{isDiameter} eq 1)
                {
                    $self->{isDiameter} = 2 ;
                }
                elsif ($self->{isDepth} eq 1)
                {
                    $self->{isDepth} = 2 ;
                }
                elsif ($self->{isForm} eq 1)
                {
                    $self->{isForm} = 2 ;
                }
                elsif ($self->{isAxis} eq 1)
                {
                    $self->{isAxis} = 2 ;
                }
                elsif ($self->{isDemon} eq 1)
                {
                    $self->{isDemon} = 2 ;
                }
                elsif ($self->{isRef} eq 1)
                {
                    $self->{isRef} = 2 ;
                }
            }
            elsif ($tagname eq 'th')
            {
                $self->{isAnalyse} = 1 ;
            }
            elsif (($tagname eq "td") && ($self->{insideTech} eq 1))
            {
                # source
                $self->{insideTech} = 2;
            }
            elsif (($tagname eq "td") && ($self->{insideTech} eq 2))
            {
                # pays émetteur
                $self->{insideTech} = 3;
            }
            elsif (($tagname eq "a") && ($self->{isCountry} eq 2))
            {
                $self->{isCountry} = 3 ;
            }
            elsif (($tagname eq "abbr") && ($self->{isRef} eq 2))
            {
                $self->{isRef} = 3 ;
            }

            ### les photos
            # attention les photos sont maintenant avant les caractéristiques
            if (($tagname eq "div") && ($attr->{id} eq "fiche_photo"))
            {
                $self->{insidePicture} = 1;
                $self->{insideTech} = 0;
                $self->{insideSerie} = 0;
                $self->{insideCollec} = 0;
                $self->{insideDesc} = 0;
                $self->{insideEch} = 0;
                $self->{isVoir} = 0 ;
            }
            elsif (($tagname eq "a") && ($self->{insidePicture} eq 1))
            {
                # image de l'avers
                my $src1 = $attr->{href};
                
                # le https met la pagaille (pb de certificat ?, bug de GCstar ?)
                if (($src1 =~ /https:/)) {
                    $src1 =~ s/https\:/http\:/;
                }
                $self->{curInfo}->{picture} = $src1;
                $self->{insidePicture} = 2;
            }
            elsif (($tagname eq "img") && ($self->{insidePicture} eq 1) && ($attr->{alt} =~ /avers/))
            {
                if ($self->{curInfo}->{picture} eq "")
                {
                    # petite image de l'avers si pas de grande
                    my $srcp1 = $attr->{src};
                    $self->{curInfo}->{picture} = $srcp1;
                    $self->{insidePicture} = 2;
                }
            }
            elsif (($tagname eq "a") && ($self->{insidePicture} eq 2))
            {
                # image du revers
                my $src2 = $attr->{href};
                
                # le https met la pagaille (pb de certificat ?)
                if (($src2 =~ /https:/)) {
                    $src2 =~ s/https\:/http\:/;
                }
                $self->{curInfo}->{back} = $src2;
                $self->{insidePicture} = 3;
            }
            elsif (($tagname eq "img") && ($self->{insidePicture} eq 2) && ($attr->{alt} =~ /revers/))
            {
                if ($self->{curInfo}->{back} eq "")
                {
                    # petite image du revers si pas de grande
                    my $srcp2 = $attr->{src};
                    $self->{curInfo}->{back} = $srcp2;
                    $self->{insidePicture} = 3;
                }
            }

            ### la description
            if (($tagname eq "section") && ($attr->{id} eq "fiche_descriptions"))
            {
                $self->{insideDesc} = 1 ;
                $self->{insidePicture} = 0 ;
                $self->{insideTech} = 0 ;
                $self->{insideSerie} = 0 ;
                $self->{insideCollec} = 0 ;
                $self->{insideEch} = 0 ;
                $self->{isVoir} = 0 ;
            }
            elsif (($tagname eq "p") or ($tagname eq "span"))
            {
                if ($self->{isCommemo} eq 1)
                {
                    $self->{isCommemo} = 2 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{isTranche} = 0 ;
                    $self->{isComment} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isAvers} eq 1)
                {
                    $self->{isAvers} = 2 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{isTranche} = 0 ;
                    $self->{isComment} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isRevers} eq 1)
                {
                    $self->{isRevers} = 2 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isTranche} = 0 ;
                    $self->{isComment} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isTranche} eq 1)
                {
                    $self->{isTranche} = 2 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{isComment} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isAtelier} eq 1)
                {
                    $self->{isAtelier} = 2 ;
                    $self->{isTranche} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{isComment} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isComment} eq 1)
                {
                    $self->{isComment} = 2 ;
                    $self->{isTranche} = 0 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{isVoir} = 0 ;
                }
                elsif ($self->{isVoir} eq 1)
                {
                    $self->{isVoir} = 2 ;
                    $self->{isComment} = 0 ;
                    $self->{isTranche} = 0 ;
                    $self->{isAtelier} = 0 ;
                    $self->{isCommemo} = 0 ;
                    $self->{isAvers} = 0 ;
                    $self->{isRevers} = 0 ;
                    $self->{insideCollec} = 0 ;
                    $self->{insideEch} = 0 ;
                    $self->{insideDesc} = 0 ;
                }
            }
            elsif (($tagname eq "a") && ($self->{isTranche} eq 2))
            {
                # grande image de la tranche
                my $src3 = $attr->{href};

                # le https met la pagaille (pb de certificat ?)
                if (($src3 =~ /https:/)) {
                    $src3 =~ s/https\:/http\:/;
                }
                $self->{curInfo}->{edge1} = $src3;
                $self->{isTranche} = 3;
            }
            elsif (($tagname eq "img") && ($self->{isTranche} eq 3) && ($attr->{class} =~ /haut/))
            {
                if ($self->{curInfo}->{edge1} eq "")
                {
                    # petit image de la tranche
                    my $srcp3 = $attr->{src};
                    $self->{curInfo}->{edge1} = $srcp3;
                    $self->{isTranche} = 4;
                }
            }
            elsif ($tagname eq "h3")
            {
                $self->{isAnalyse2} = 1 ;
            }

            ### la collection
            if (($tagname eq "table") && ($attr->{class} eq "collection"))
            {
                $self->{insideCollec} = 1 ;
                $self->{insidePicture} = 0 ;
                $self->{insideTech} = 0 ;
                $self->{insideSerie} = 0 ;
                $self->{insideDesc} = 0 ;
                $self->{insideEch} = 0 ;
                $self->{isVoir} = 0 ;
                $self->{isTranche} = 0 ;
                $self->{isAtelier} = 0 ;
                $self->{isCommemo} = 0 ;
                $self->{isAvers} = 0 ;
                $self->{isRevers} = 0 ;
                $self->{isComment} = 0 ;
            }
            elsif (($tagname eq "td") && ($attr->{class} eq "date"))
            {
                $self->{insideCollec} = 2 ;
            }
            elsif (($tagname eq "td") && ($attr->{class} eq "tirage") && ($self->{isAnnee} eq 1))
            {
                $self->{insideCollec} = 3 ;
            }

           ### les échanges
           # on arrête de remplir les autres champs
           # todo : attention, le site a été refondu complètement dans cette partie
            if (($tagname eq "section") && ($attr->{id} eq "fiche_echanges"))
            {
                $self->{insideEch} = 1 ;
                $self->{insidePicture} = 0 ;
                $self->{insideTech} = 0 ;
                $self->{insideSerie} = 0 ;
                $self->{insideCollec} = 0 ;
                $self->{insideDesc} = 0 ;
                $self->{isVoir} = 0 ;
                $self->{isTranche} = 0 ;
                $self->{isAtelier} = 0 ;
                $self->{isCommemo} = 0 ;
                $self->{isAvers} = 0 ;
                $self->{isRevers} = 0 ;
                $self->{isComment} = 0 ;
            }
        }
    }

    # end
    sub end
    {
        my ($self, $tagname) = @_;
        $self->{inside}->{$tagname}--;
        if ($self->{parsingList})
        {

        }
        else
        {
            # construction du nom de la monnaie
            # doit correspondre à l'ordre de création du nom dans le modèle GCCoins
            $self->{curInfo}->{name} = $self->{curInfo}->{value} ." ". $self->{curInfo}->{currency} ." ". $self->{curInfo}->{year} ." ". $self->{curInfo}->{series};
        }
    }

    # text
    # si zéro pièce trouvé, la fenêtre de nouvelle proposition de recherche (pays, km...) s'affiche
    sub text
    {
        my ($self, $origtext) = @_;
        if ($self->{parsingList})
        {
            # au 04/06/2020 la liste de résultat ne s'affiche plus (modification de l'intitulé pièce en résultat)
            # au 25/07/2020 la liste ne renvoi plus le bon nombre de pièces, détection fin de pièce cassé (class resultat_recherche_ad en trop google)
            # TODO : la liste des résultats ne se remplie plus correctement, pb de balise BR
            if ((($origtext =~ /(\d+) résultat trouvé/) || ($origtext =~ /(\d+) résultats trouvés/) || ($origtext =~ /(\d+) r..?sultats trouv..?s/) || ($origtext =~ /(\d+) r..?sultat trouv..?/)) && ($1 > 0))
            {
                $self->{insideResults} = 1;
            }
            elsif ($self->{isCoin} eq 6)
            {
                # Enlève les blancs en début de chaine
                $origtext =~ s/^\s*//;

                # nom
                $self->{itemsList}[ $self->{itemIdx} ]->{name} .= $origtext;
                
                # valeur (marche pas)
                if ($origtext =~ /^([0-9]{1,10})/)
                {
                    $self->{curInfo}->{value} .= $1;
                }

                # Enlève les blancs en fin de chaine
                $origtext =~ s/\s*$//;
                # série
                $self->{itemsList}[ $self->{itemIdx} ]->{series} .= $origtext;
            }
             elsif ($self->{isCoin} eq 7)
            {
                # année
                if ($origtext =~ /([0-9]{1,4}-[0-9]{1,4})/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{year} .= $1;
                }
                elsif ($origtext =~ /([0-9]{1,4})/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{year} .= $1;
                }
             }
              elsif ($self->{isCoin} eq 8)
            {
                # TODO : au 25/07/2020, si commémorative, décalage d'une balise BR
                
                # Enlève les blancs en début de chaine
                $origtext =~ s/^\s*//;

                # métal
                # remplir la colonne métal dans le résultat de la recherche
                # todo : trouver un autre moyen de détection du métal
                if ($origtext =~ /Argent |Or |Cuivre|Bronze|Cupro|Bi-m|Alu|Nickel|Zinc|Laiton|Fer |Acier|Alliage|Billon|Maille/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{metal} .= $origtext;
                }
                
                # rattrapage si vide : commémorative ou essai (on prend tout)
                 if ($self->{itemsList}[ $self->{itemIdx} ]->{metal} eq "")
                {
                    # Enlève les blancs en début de chaine
                    $origtext =~ s/^\s*//;
                    # Enlève les blancs en fin de chaine
                    $origtext =~ s/\s*$//;
                    $self->{itemsList}[ $self->{itemIdx} ]->{metal} .= $origtext;
                 }
            }
              elsif ($self->{isCoin} eq 9)
            {
                # Enlève les blancs en début de chaine
                $origtext =~ s/^\s*//;

                # référence
                # il faut récupérer la première référence Krause (KM) seulement
                if ($origtext =~ /(KM\# \d+\D?\.?\d*\D?\d*)|(KM\# \d+\D?\.?\d*\D?\d*)|(KM\#\d+\D?\.?\d*\D?\d*)|(KM\#\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                elsif ($origtext =~ /(Y\# \d+\D?\.?\d*\D?\d*)|(Y\# \d+\D?\.?\d*\D?\d*)|(Y\#\d+\D?\.?\d*\D?\d*)|(Y\#\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                elsif ($origtext =~ /(C\# \d+\D?\.?\d*\D?\d*)|(C\# \d+\D?\.?\d*\D?\d*)|(C\#\d+\D?\.?\d*\D?\d*)|(C\#\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                elsif ($origtext =~ /(X\# \d+\D?\.?\d*\D?\d*)|(X\# \d+\D?\.?\d*\D?\d*)|(X\#\d+\D?\.?\d*\D?\d*)|(X\#\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                elsif ($origtext =~ /(KM\# [A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(KM\# [A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(KM\#[A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(KM\#[A-Z]{0,2}\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                elsif ($origtext =~ /(Y\# [A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(Y\# [A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(Y\#[A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(Y\#[A-Z]{0,2}\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{number1} = $1;
                }
                # on vire la virgule de fin
                $self->{itemsList}[ $self->{itemIdx} ]->{number1} =~ s/,//gi;
                
                # en cas d'absence de référence kreuze (antique par exemple)
                 if ($self->{itemsList}[ $self->{itemIdx} ]->{number1} eq "")
                {
                     $self->{itemsList}[ $self->{itemIdx} ]->{number1} .= $origtext;
                 }

            }
              elsif ($self->{isCoin} eq 10)
            {
               # on doit passer à la pièce suivante
                $self->{isCoin} = 0;
            }
        }
        else
        {
            # Enlève les blancs en début de chaine
            $origtext =~ s/^\s*//;
            # Enlève les blancs en fin de chaine
            $origtext =~ s/\s*$//;
            
            return if ($origtext eq '');
            if ($self->{insideSerie} eq 1)
            {
                if ($self->{inside}->{h1})
                {
                    $self->{curInfo}->{series} .= $origtext;
                }
            }
            elsif ($self->{insideSerie} eq 2)
            {
                # on complète la série avec la balise <span> si elle existe !
                $self->{curInfo}->{series} .= " (" . $origtext . ")";
                $self->{insideSerie} = 0;
            }

            if ($self->{isAnalyse} eq 1)
            {
                $self->{isCountry} = 1 if ($origtext =~ m/Emetteur/i);
                $self->{isAutorit} = 1 if ($origtext =~ m/Autorit/i);
                $self->{isPeriod} = 1 if (($origtext =~ m/Période/i) || ($origtext =~ m/P..?riode/i));
                $self->{isType} = 1 if ($origtext =~ m/Type/i);
                # TODO : au 25/07/2020, il y a confusion avec le mot "Date" sans S dans le tableau des tirages
                # en cas d'année unique, par exemple les commémoratives (cf rattrapage)
                #$self->{isYear} = 1 if (($origtext =~ m/^Dates/i) || ($origtext =~ m/^Date/i));
                $self->{isYear} = 1 if ($origtext =~ m/Dates/i);
                $self->{isCalend} = 1 if ($origtext =~ m/Calendrier/i);
                $self->{isValue} = 1 if ($origtext =~ m/Valeur/i);
                $self->{isCurrency} = 1 if ($origtext =~ m/Devise/i);
                $self->{isMetal} = 1 if ($origtext =~ m/Composition/i);
                $self->{isWeight} = 1 if ($origtext =~ m/Poids/i);
                $self->{isDiameter} = 1 if ($origtext =~ m/Diam..?tre/i);
                $self->{isDepth} = 1 if ($origtext =~ m/Epaisseur/i);
                $self->{isForm} = 1 if ($origtext =~ m/Forme/i);
                $self->{isAxis} = 1 if ($origtext =~ m/Orientation/i);
                $self->{isDemon} = 1 if ($origtext =~ m/D..?mon..?tis..?e/i);
                $self->{isRef} = 1 if ($origtext =~ m/R..?f..?rences/i);

                $self->{isAnalyse} = 0 ;
            }
            elsif ($self->{isCountry} eq 3)
            {
                return if ($origtext =~ m/Jetons/i);
                $origtext =~ s/[()]//g;
                $self->{curInfo}->{country} .= $origtext;
                $self->{isCountry} = 0 ;
            }
            elsif ($self->{isAutorit} eq 2)
            {
                # en attendant mieux, on colle en commentaire
                $self->{curInfo}->{comments} .= $origtext."\n";
                $self->{isAutorit} = 0 ;
            }
            elsif ($self->{isPeriod} eq 2)
            {
                # en attendant mieux, on colle en commentaire
                $self->{curInfo}->{comments} .= $origtext."\n";
                $self->{isPeriod} = 0 ;
            }
            elsif ($self->{isType} eq 2)
            {
                $origtext =~ s/,/\./g;
                $origtext = 'coin' if ($origtext =~ m/Pi..?ce courante/i);
                $origtext = 'token' if ($origtext =~ m/Jeton/i);
                $origtext = 'medal' if ($origtext =~ m/M..?daille/i);
                $origtext = 'an_coin' if ($origtext =~ m/Pi..?ce circulante comm..?morative/i);
                $origtext = 'nc_coin' if ($origtext =~ m/Pi..?ce non circulante/i);
                $self->{curInfo}->{type} = $origtext;
                $self->{isType} = 0 ;
            }
            elsif ($self->{isYear} eq 2)
            {
                if ($origtext =~ /^([0-9]{1,4})/)
                {
                    # pour le moment c'est la première date d'une fourchette
                    # par exemple prend 1959 quand il y a 1959-1982
                    $self->{curInfo}->{year} = $1;
                    # todo : prendre la date de la recherche initiale (si elle existe)
                }
                if ($origtext =~ /^([0-9]{1,4}-[0-9]{1,4})/)
                {
                    $self->{curInfo}->{years_of_coinage} = $1;
                }
                elsif ($origtext =~ /^([0-9]{1,4})/)
                {
                    $self->{curInfo}->{years_of_coinage} = $1;
                }
                $self->{isYear} = 0 ;
            }
            elsif ($self->{isCalend} eq 2)
            {
                $self->{curInfo}->{calendar} = $origtext;
                $self->{isCalend} = 0 ;
            }
            elsif ($self->{isValue} eq 2)
            {
                # on se trouve sur la ligne qui affiche : valeur+devise+(valeur+unité)
                # on remplace la virgule par le point
                # a cause de la notation américaine dans GCStar
                $origtext =~ s/,/\./g;
                # on enlève les tabulations
                $origtext =~ s/\t/ /g;
                if ($origtext =~ /^([0-9]{1,3} [0-9]{3} [0-9]{3}) /)
                {
                   # on se trouve sur un format de nombre avec des espaces
                   # exemple : 1 000 000 Francs CFA (Éléphant d'Afrique)
                    $self->{curInfo}->{value} = $1;
                }
                elsif ($origtext =~ /^(\d+) |^(\d+\.?\d*) /)
                {
                    # todo : récupérer des valeurs avec décimal
                    # exemple : 2,50 euros The Family of Man
                    $self->{curInfo}->{value} = $1;
                }
                elsif ($origtext =~ /^(\d\/\d+) /)
                {
                    # on se trouve avec des fractions 1/2, 1/4, 1/8, 1/12, 1/16 ...
                    # il faut transformer en 0.50, 0.25, , 0.125, 0.083, 0.0625 ...
                    my $val = $1;
                    $val =~ s/1\/2/0\.50/;
                    $val =~ s/1\/4/0\.25/;
                    $val =~ s/1\/8/0\.125/;
                    $val =~ s/1\/12/0\.083/;
                    $val =~ s/1\/16/0\.0625/;
                    $self->{curInfo}->{value} = $val;
                }
                
                if ($origtext =~ /^[0-9]{1,3} [0-9]{3} [0-9]{3} (\w+ \w+)|^[0-9]{1,3} [0-9]{3} [0-9]{3} (\w+)/)
                {
                    # on se trouve sur un format de nombre avec des espaces
                    $self->{curInfo}->{currency} = $1;
                }
                elsif (($origtext =~ /^\d+ (\w+ de \w+)/) || ($origtext =~ /^\d+ (\w+ d'\w+)/))
                {
                    # si devise et sous-devise (plusieurs mots)
                    # pour "cent d'euro" ou "centime de franc", on récupère tout
                    # attention, il peut n'y avoir qu'un seul mot (cents)
                    $self->{curInfo}->{currency} = $1;
                }
                elsif (($origtext =~ /^\d+ (\w+ \w+)|^\d+\.?\d* (\w+ \w+)/) || ($origtext =~ /^\d+ (\w+)|^\d+\.?\d* (\w+)/))
                {
                    # todo : récupérer aussi quand des valeurs avec décimal
                    # exemple : 2,50 euros The Family of Man
                    $self->{curInfo}->{currency} = $1;
                }
                elsif ($origtext =~ /^\d\/\d (\w+)/)
                {
                    # les valeurs sous forme de fractions
                    $self->{curInfo}->{currency} = $1;
                }
                if ($self->{curInfo}->{value} eq "")
                {
                    # si la valeur est vide, on peut rattraper avec la série
                    if (($self->{curInfo}->{series} =~ /^(\d+) /) || ($self->{curInfo}->{series} =~ /^(\d\/\d+) /))
                    {
                        $self->{curInfo}->{value} = $1;
                    }
                }
                if ($self->{curInfo}->{currency} eq "")
                {
                    # si la devise est vide, on peut rattraper avec la série
                    if (($self->{curInfo}->{series} =~ /^\d+ (\w+)/) || ($self->{curInfo}->{series} =~ /^\d\/\d+ (\w+)/))
                    {
                        $self->{curInfo}->{currency} = $1;
                    }
                }
                $self->{isValue} = 0 ;
            }
             elsif ($self->{isDevise} eq 2)
            {
                if ($self->{curInfo}->{currency} eq "")
                {
                    $self->{curInfo}->{currency} = $origtext;
                }
                # TODO : en attendant, juste en commentaire, pas de remplacement de la détection de la devise.
                $self->{curInfo}->{comments} .= $origtext."\n";
                $self->{isDevise} = 0 ;
            }
            elsif ($self->{isMetal} eq 2)
            {
                # todo : parfois le pour mille est un carré 
                # il faudrait mettre le bon caractère
                # problème de codification ISO-8859-1 vers UTF8
                $origtext =~ s/&#8240;/‰/gi;
                $origtext =~ s/&permil;/‰/gi;
                $origtext =~ s/‰/‰/g;
                
                # uniformiser les métaux
                $origtext =~ s/Cupronickel/Cupro-nickel/gi;
                $origtext =~ s/Bimétallique/Bi-métallique/gi;
                # nouveau champ métal avec plusieurs valeurs possibles
                # chaque valeur séparée par une virgule
                # todo : revoir les types de séparateur existant sur Numista
                # exemple 2 euros All 2007 : Bi-métallique ; centre : maillechort - anneau : cupronickel
                # exemple 2 livres Gib 1998 : Bimétallique : centre en cupronickel, anneau en laiton
                # exemple 20 francs Mon 1992 : Trimétallique : Cu 92%, Al 6%, Ni 2% / nickel / Cu 92%, Al 6%, Ni 2%
                if ($origtext =~ /(\d+\,?\d*)‰/)
                {
                    # remplacer la virgule décimale par un point sinon 2 métaux au lieu d'un seul
                    # attention, le point peut servir pour le séparateur décimal à la place de la virgule
                    # exemple : argent 999,9‰
                    $origtext =~ s/\,/\./;
                }
                $origtext =~ s/ \: | \(|\)| \; | - | et | ou | \+ | entouré | \/ /\,/gi;
                $self->{curInfo}->{metal} .= $origtext;
                $self->{isMetal} = 0 ;
            }
            elsif ($self->{isWeight} eq 2)
            {
                $origtext =~ s/,/\./g;
                if ($origtext =~ /(\d+\.?\d*) g/)
                {
                    $self->{curInfo}->{weight} = $1;
                }
                $self->{isWeight} = 0 ;
            }
            elsif ($self->{isDiameter} eq 2)
            {
                $origtext =~ s/,/\./g;
                if ($origtext =~ /(\d+\.?\d*) mm/)
                {
                    $self->{curInfo}->{diameter} = $1;
                }
                $self->{isDiameter} = 0 ;
            }
            elsif ($self->{isDepth} eq 2)
            {
                $origtext =~ s/,/\./g;
                if ($origtext =~ /(\d+\.?\d*) mm/)
                {
                    $self->{curInfo}->{depth} = $1;
                }
                $self->{isDepth} = 0 ;
            }
            elsif ($self->{isForm} eq 2)
            {
                $self->{curInfo}->{form} .= $origtext;
                $self->{isForm} = 0 ;
            }
            elsif ($self->{isAxis} eq 2)
            {
                # orientation
                # Frappe monnaie = Monnaie = monetary
                # Frappe médaille = Médaille = medal
                if ($origtext =~ /Frappe monnaie/)
                {
                    $self->{curInfo}->{axis} = "monetary";
                    $self->{isAxis} = 0 ;
                }
                if ($origtext =~ /Frappe médaille/)
                {
                    $self->{curInfo}->{axis} = "medal";
                    $self->{isAxis} = 0 ;
                }
            }
            elsif ($self->{isDemon} eq 2)
            {
                # todo : mettre un champs démonétisée dans le modèle de collection GCCoins ?
                $self->{curInfo}->{comments} .= "Démonétisée : ".$origtext."\n";
                $self->{isDemon} = 0 ;
            }
            elsif ($self->{isRef} eq 2)
            {
                # test niveau 1
                # rien ?
            }
            elsif ($self->{isRef} eq 3)
            {
                # test niveau 2
                # avant le 04/10/2019 le contenu de la balise <abbr> (KM) + la valeur (#757)
                # modification après le 04/10/2019 : KM dans la balise <abbr> et la valeur (#757) en dehors
                if ($origtext =~ /^(KM|Y|C|X)/)
                {
                    $self->{curInfo}->{number1} .= $1;
                    $self->{curInfo}->{catalogue1} = "World Coins";
                    $self->{isRef} = 4 ;
                }
            }
            elsif ($self->{isRef} eq 4)
            {
                # la suite de la balise <td> ? (entre abbr et div/em) :
                if ($origtext =~ /(\# )/)
                {
                    $self->{curInfo}->{number1} .= $1;
                }
                if ($origtext =~ /(\d+\D?\.?\d*\D?\d*)|([A-Z]{0,2}\d+\D?\.?\d*\D?\d*)|(\d+\D?\.?\d*\D?\d*)\,|([A-Z]{0,2}\d+\D?\.?\d*\D?\d*)\,/)
                {
                    $self->{curInfo}->{number1} .= $1;
                    # on vire la virgule 
                    $self->{curInfo}->{number1} =~ s/,//gi;
                    # on vire l'espace dedans pour faciliter la recherche par référence
                    $self->{curInfo}->{number1} =~ s/ //;
                }
                 $self->{isRef} = 0 ;
            }

                if ($self->{isAnalyse2} eq 1)
                {
                    $self->{isCommemo} = 1 if ($origtext =~ m/Pi..?ce comm..?morative/i);
                    $self->{isAvers} = 1 if ($origtext =~ m/Avers/i);
                    $self->{isRevers} = 1 if ($origtext =~ m/Revers/i);
                    $self->{isTranche} = 1 if ($origtext =~ m/Tranche/i);
                    $self->{isAtelier} = 1 if (($origtext =~ m/Ateliers mon..?taires/i) || ($origtext =~ m/Atelier mon..?taire/i));
                    $self->{isComment} = 1 if ($origtext =~ m/Commentaires/i);
                    $self->{isVoir} = 1 if ($origtext =~ m/Voir aussi/i);
                    $self->{isVoir} = 1 if ($origtext =~ m/Obtenir cette/i);
                    $self->{isRevers} = 0 if ($origtext =~ m/Gestion/i); # zone Gestion de ma collection
                    $self->{isAvers} = 0 if ($origtext =~ m/Gestion/i); # zone Gestion de ma collection

                    $self->{isAnalyse2} = 0 ;
                }
                elsif ($self->{isCommemo} eq 2)
                {
                    if ($self->{inside}->{p})
                    {
                        # permet de prendre l'information des pièces commémoratives
                        $self->{curInfo}->{comments} .= $origtext."\n";
                    }
                    elsif ($self->{inside}->{span})
                    {
                        $self->{curInfo}->{comments} .= $origtext."\n";
                    }
                }
                elsif ($self->{isAvers} eq 2)
                {
                    if ($self->{inside}->{p})
                    {
                        # on insère un saut de ligne avant le mot "inscription :"
                        $origtext =~ s/^Inscription/ \nInscription/;
                        # on insère un saut de ligne avant le mot "traduction :"
                        $origtext =~ s/^Traduction/ \nTraduction/;
                        # on insère un saut de ligne avant le mot "graveur :"
                        $origtext =~ s/^Graveur/ \nGraveur/;
                        $self->{curInfo}->{head} .= $origtext;

                        if (($self->{curInfo}->{head}  =~ /Graveur :(.*), né/) || ($self->{curInfo}->{head}  =~ /Graveur :(.*)/))
                        {
                            # todo : ne pas prendre tout le texte derrière le nom du graveur
                            $self->{curInfo}->{mintmaster} .= $1;
                            $self->{isMintmaster} = 0 ;
                        }
                    }
                }
                elsif ($self->{isRevers} eq 2)
                {
                    if ($self->{inside}->{p})
                    {
                        # on insère un saut de ligne avant le mot "inscription :"
                        $origtext =~ s/^Inscription/ \nInscription/;
                        # on insère un saut de ligne avant le mot "traduction :"
                        $origtext =~ s/^Traduction/ \nTraduction/;
                        # on insère un saut de ligne avant le mot "graveur :"
                        $origtext =~ s/^Graveur/ \nGraveur/;
                        $self->{curInfo}->{tail} .= $origtext;

                        if (($self->{curInfo}->{tail} =~ /Graveur :(.*), né/) || ($self->{curInfo}->{tail} =~ /Graveur :(.*)/))
                        {
                            # todo : ne pas prendre tout le texte derrière le nom du graveur
                            $self->{curInfo}->{mintmaster} .= " ".$1;
                            $self->{isMintmaster} = 0 ;
                        }
                    }
                }
                elsif ($self->{isTranche} eq 2)
                {
                    if ($self->{inside}->{p})
                    {
                        # on insère un saut de ligne avant le mot "inscription :"
                        $origtext =~ s/^Inscription/ \nInscription/;
                        # on insère un saut de ligne avant le mot "traduction :"
                        $origtext =~ s/^Traduction/ \nTraduction/;
                        # on insère un saut de ligne avant le mot "graveur :"
                        $origtext =~ s/^Graveur/ \nGraveur/;
                        $self->{curInfo}->{edge} .= $origtext;
                        
                        # enlever le point de fin de ligne pour le type de tranche seulement
                        # todo : ne marche pas avec les phrases complètes
                        $origtext =~ /(.*)\.$/;
                        $self->{curInfo}->{edge_type} .= $1;
                        # si vide on prend tout
                        if ($1 eq "")
                        {
                            $self->{curInfo}->{edge_type} .= $origtext;
                        }
                    }
                }
                elsif ($self->{isAtelier} eq 2)
                {
                    # todo : voir à prendre le contenu d'un tableau (actuellement ne fonctionne pas avec l'allemagne)
                    $self->{curInfo}->{comments} .= $origtext."\n";
                    $self->{isAtelier} = 0 ;
                }
                elsif ($self->{isComment} eq 2)
                {
                    if ($self->{inside}->{p})
                    {
                        $self->{curInfo}->{comments} .= $origtext."\n";
                        $self->{isComment} = 0 ;
                    }
                }
                elsif ($self->{isVoir} eq 2)
                {
                    # rien a prendre (fin de la page)
                    $self->{isVoir} = 0 ;
                }

            if (($self->{insideCollec} eq 3))
            {
                if ($self->{inside}->{td})
                {
                    # prend la quantité fabriquée de l'année recherchée
                    #        voir tableau année/tirage
                    # actuellement, c'est la première quantité qui est sélectionnée
                    # l'année recherchée devrait se trouver dans $self->{curInfo}->{year}
                    if (($origtext =~ /^([0-9]{1,3} [0-9]{3} [0-9]{3} [0-9]{3})/) || ($origtext =~ /^([0-9]{1,3} [0-9]{3} [0-9]{3})/) 
                         || ($origtext =~ /^([0-9]{1,3} [0-9]{3})/) || ($origtext =~ /^([0-9]{1,3})/))
                    {
                        $self->{curInfo}->{quantity} = $1;
                        $self->{insideCollec} = 0;
                    }
                }
            }
            # recherche de la bonne ligne du tirage
            # todo : à finir
            elsif ($self->{insideCollec} eq 2)
            {
                # on est sur une ligne de date
                if ($self->{inside}->{td})
                {
                    # Enlève les blancs en début de chaine
                    $origtext =~ s/^\s*//;
                    # Enlève les blancs en fin de chaine
                    $origtext =~ s/\s*$//;

                    if (($origtext =~ /^([0-9]{1,4})/) || ($origtext =~ /^ND \(([0-9]{1,4})/))
                    {
                        # TODO : rattrapage, année peut être vide si pb date sans S
                        # attention au ND (non daté)
                        if ($self->{curInfo}->{year} eq "")
                           {
                                $self->{curInfo}->{year} = $1;
                           }
                          # TODO : rattrapage, année de fabrication peut être vide si pb date sans S
                          if ($self->{curInfo}->{years_of_coinage} eq "")
                             {
                                  $self->{curInfo}->{years_of_coinage} = $1;
                             }
                        # on est sur la ligne de l'année recherchée ou celle-ci est vide
                        if (($self->{curInfo}->{year} eq $1) || ($self->{curInfo}->{year} eq ""))
                        {
                            $self->{isAnnee} = 1;
                            if (($origtext =~ /^[0-9]{1,4} (\w+)/) || ($origtext =~ /^ND ([0-9]{1,4}) (\w+)/))
                            {
                                 # todo : on récupère les lettres d'atelier qui se trouvent après l'année
                                 $self->{curInfo}->{city_letter} = $1;
                            }
                        }
                        else 
                        {
                            $self->{isAnnee} = 0;
                        }
                    }
                }
            }
        }
    }

    # new
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        $self->{hasField} = {
        name => 1,
        country => 1,
        number1 => 1,
        year => 1,
        series => 1,
        value => 1,
        mint => 1,
        metal => 1,
        };

        bless ($self, $class);

        return $self;
    }

    # getFields
    sub getReturnedFields
    {
        my $self = shift;
        $self->{hasField} = {
        name => 1,
        country => 1,
        number1 => 1,
        year => 1,
        series => 1,
        value => 1,
        mint => 1,
        metal => 1,
        };
    }

    # preProcess
    sub preProcess
    {
        my ($self, $html) = @_;

        # initialisation
        $self->{isInfo} = 0;
        $self->{isCoin} = 0;

        # remise à zéro pour recherche suivante
        $self->{insideResults} = 0;
        $self->{insideSerie} = 0;
        $self->{insideTech} = 0;
        $self->{insidePicture} = 0;
        $self->{insideCollec} = 0;
        $self->{insideDesc} = 0;
        $self->{insideEch} = 0;
        
        $self->{isWeight} = 0;
        $self->{isValue} = 0;
        $self->{isMetal} = 0;
        $self->{isDiameter} = 0;
        $self->{isDepth} = 0;
        $self->{isForm} = 0;
        $self->{isAxis} = 0;
        $self->{isCalend} = 0;
        $self->{isDemon} = 0;
        $self->{isRef} = 0;
        $self->{isCountry} = 0;
        $self->{isAnalyse} = 0;
        $self->{isAnalyse2} = 0;
        $self->{isCommemo} = 0;
        $self->{isAvers} = 0;
        $self->{isRevers} = 0;
        $self->{isTranche} = 0;
        $self->{isAnnee} = 0;
        $self->{isComment} = 0;
        $self->{isVoir} = 0;
        $self->{isMintmaster} = 0;
        $self->{isType} = 0;
        $self->{isPeriod} = 0;
        $self->{isCurrency} = 0;
        $self->{isAtelier} = 0;
        $self->{isAutorit} = 0;

        $html =~ s/&ndash;/ /gi;
        $html =~ s/&nbsp;/ /gi;

        # on remplace les caractères html spéciaux
        $html =~ s/&#146;/'/gm;
        $html =~ s/&#039;/'/gm;
        $html =~ s/&#133;/.../gm;
        $html =~ s/&#156;/oe/gm;
        $html =~ s/&#080;/€/gm;
        $html =~ s/&#x92;/'/gi;
        $html =~ s/&#092;/'/gm;
        $html =~ s/&#149;/*/gi;
        $html =~ s/&#133;/.../gi;
        $html =~ s/&#x85;/.../gi;
        $html =~ s/&#x8C;/OE/gi;
        $html =~ s/&#x9C;/oe/gi;
        
        # attention le champ de la valeur n'accepte pas le 1/2 ou 1/4
        $html =~ s|&frac14;|0\.25|gi;
        $html =~ s|&frac12;|0\.50|gi;
        $html =~ s|&#188;|0\.25|gi;
        $html =~ s|&#189;|0\.50|gi;

        # on supprime la phrase si pas connecté
        $html =~ s|Gestion de votre collection||gi;
        $html =~ s|Pour g..?rer votre collection, veuillez vous||gi;
        $html =~ s|connecter||gi;
        $html =~ s|ou si ce n'est pas d..?j..? fait,||gi;
        $html =~ s|inscrivez-vous||gi;
        # on supprime la phrase des souhaits
        $html =~ s|Je souhaite l\'obtenir||gi;
        $html =~ s|Je ne souhaite pas l\'obtenir||gi;
        # on supprime la phrase des échanges
        $html =~ s|Des membres du site désirent échanger cette pièce :||gi;
        $html =~ s|Aucun membres du site ne veut actuellement l'échanger||gi;
        $html =~ s|Acheter des pièces de ||gi;

        #todo : remplacer les caractères spéciaux (point,• ...) qui s'affiche mal ()
        # surtout les "pour mille" : ‰
        $html =~ s/&#8240;/‰/gi;
        $html =~ s/&permil;/‰/gi;
        
        # on remplace les flêches de l'orientation
        $html =~ s/&uarr;/A/gi;
        $html =~ s/&darr;/V/gi;
        
        if ($self->{parsingList})
        {

        }
        else
        {
            # on remplace les mises en forme html
            $html =~ s/<strong>|<\/strong>//gim;
            $html =~ s/<b>|<\/b>//gim;
            $html =~ s/<i>|<\/i>//gim;
            $html =~ s/<ul>|<\/ul>/\n/gim;
            $html =~ s/<li>([^<])/- $1/gim;
            $html =~ s|([^>])</li>|$1\n|gim;
            $html =~ s|<br ?/?>|\n|gi;
            $html =~ s|<br>|\n|gi;
            $html =~ s/<em>|<\/em>//gim;
        }
        return $html;
    }

}

1;
