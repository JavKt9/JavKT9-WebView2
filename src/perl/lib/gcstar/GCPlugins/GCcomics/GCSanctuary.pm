package GCPlugins::GCcomics::GCSanctuary;

###################################################
#
#  Copyright 2005-2007 Tian
#  Copyright 2016-2022 Kerenoc
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

use GCPlugins::GCcomics::GCcomicsCommon;

{

    package GCPlugins::GCcomics::GCPluginSanctuary;

    use base qw(GCPlugins::GCcomics::GCcomicsPluginsBase);

    sub start
    {
        my ( $self, $tagname, $attr, $attrseq, $origtext ) = @_;


        if ( $self->{parsingList} ) # partie en rapport à la page de résultats
        {
            if ($tagname eq 'html' && $self->{loadedUrl} =~ m|fiche/| )
            {
                $self->{pass} = 2 ;
            }
            elsif ($tagname eq 'html' && $self->{loadedUrl} =~ m|objet/| )
            {
                # final page : last pass
                $self->{itemIdx}++;
                $self->{itemsList}[ $self->{itemIdx } ]->{nextUrl} = $self->{loadedUrl};
                $self->{itemsList}[ $self->{itemIdx } ]->{url} = $self->{loadedUrl};
                $self->{parsingList} = 0;
            }
            elsif ( $self->{parsing} && $tagname eq "a" && $attr->{href} =~ m/(objet\/|fiche\/|fiche-edition-objets)/ )
            {
                return if $attr->{href} =~ m|fiche/| && $self->{pass} ne 1;
                if ($self->{pass} eq 2)
                {
                    my $a = 1;
                }
                my $url = "https://www.sanctuary.fr/" . $attr->{href};
                $url =~ s|.fr//|.fr/|;
                # check if item was already detected
                return if $self->existsUrl($url);

                $self->{titleDetected} = 1;
                $self->{itemIdx}++;
                $self->{itemsList}[ $self->{itemIdx} ]->{nextUrl} = $url;
                $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
            }
            elsif ($tagname eq "img" && $attr->{alt} && $self->{titleDetected})
            {
                if ($self->{itemsList}[ $self->{itemIdx} ]->{url} =~ m/objet/)
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{title} = $attr->{alt};
                }
                else
                {
                    $self->{itemsList}[ $self->{itemIdx} ]->{series} = $attr->{alt};
                }

                $self->{titleDetected} = 0;
            }
            elsif ($self->{pass} eq 1 && $tagname eq "div" && $attr->{class} && $attr->{class} =~ m/type-fiche/ )
            {
                $self->{isFin} = 2;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class} =~ m/carousel/)
            {
                $self->{parsing} = 0;
            }
            elsif ( $tagname eq "endoffile")
            {
                if (! defined $self->{nextUrl} && scalar $self->{nextUrlArray})
                {
                        $self->{nextUrl} = pop @{$self->{nextUrlArray}};
                }
            }
            elsif ( $tagname eq "a" && $attr->{class} && $attr->{class} =~ m|easypiechart| )
            {
                $self->{notationDetected} = 1;
            }
        }
        else # partie en rapport à la page de l'élément
        {
            if ( ! $self->{curInfo}->{image} && $tagname eq "img" && $attr->{src} =~ m|objet| )
            {
                $self->{curInfo}->{image} = $attr->{src};
            }
            elsif ( $tagname eq "a" && $attr->{href} && $attr->{href} =~ m|/fiche/| && !$self->{curInfo}->{series} )
            {
                $self->{titleDetected} = 1;
            }
            elsif ( $tagname eq "a" && $attr->{href} && $attr->{href} =~ m|page=genre| )
            {
                $self->{genresDetected} = 1;
            }
            elsif (  ( $tagname eq "img" ) && ( $attr->{src} =~ m/img.sanctuary.*\.[jJ][pP][gG]/ )
                   &&( $attr->{style} =~ m/100%/) && !$self->{curInfo}->{image} )
            {
                $self->{curInfo}->{image} = $attr->{src};
                $self->{downloadThumbnail} =0;
            }
            elsif ( $tagname eq "li" && $attr->{id})
            {
                $self->{dessinateurDetected} = 1 if ($attr->{id} eq "dessinateur");
                $self->{scenaristeDetected} = 1 if ($attr->{id} eq "scenariste");
                $self->{publishdateDetected} = 1 if ($attr->{class} eq "type");
                $self->{categoryDetected} = 1 if ($attr->{id} eq "categorie");
            }
            elsif ( $tagname eq "a" && $attr->{href} =~ m|personne| && $self->{scenaristeDetected})
            {
                $self->{scenaristeDetected} = 2;
            }
            elsif ( $tagname eq "h5")
            {
                $self->{tagH5detected} =1;
            }
            elsif ( $tagname eq "p" && $attr->{id})
            {
                $self->{synopsisDetected} = 1 if ($attr->{id} eq "synopsis");
            }
            elsif ( $tagname eq "h1")
            {
                $self->{serieDetected} =1;
            }
            elsif ( $tagname eq "i" && $attr->{class} =~m/calendar/ && $self->{publishdateDetected})
            {
                $self->{publishdateDetected} = 2;
            }
            # Code pour différencier les types de titres (original /français)
            elsif (  ( $tagname eq "img") && ( $attr->{src} =~ m/\/design\/img\/flags/ ) && ($self->{titleDetected} == 1) )
            {
                $attr->{src} =~ m/\/(\d*)\.png$/;
                if ($1 == 77)
                {
                    $self->{titreFrancais} = 1;
                }
                else
                {
                    $self->{titreFrancais} = 0;
                }
            }
            elsif ($tagname eq 'span')
            {
                $self->{titleDetected} = 0;
            }
        }
    }

    sub end
    {
        my ( $self, $tagname ) = @_;
        if ( $self->{parsingList} ) # partie en rapport à la page de résultats
        {
            if ( $tagname eq "a" )
            {
                # end of collection, next field is title
                $self->{isFin} = 2 if $self->{isFin} == 1;
                $self->{notationDetected} = 0;
            }
        }
        else # partie en rapport à la page de l'élément
        {
            $self->{genresDetected} = 0 if ($tagname eq 'a');
            $self->{synopsisDetected} = 0 if ($tagname eq 'p');

            if ( $tagname eq "li")
            {
                $self->{titleDetected} = 0;
                $self->{titreFrancais} = 1;
                $self->{publisherDetected} = 0;
                $self->{collectionDetected} = 0;
                $self->{publishdateDetected} = 0;
                $self->{costDetected} = 0;
                $self->{typeDetected} = 0;
                $self->{categoryDetected} = 0;
                $self->{scenaristeDetected} = 0;
                $self->{dessinateurDetected} = 0;
                $self->{isbnDetected} = 0;
                $self->{formatDetected} = 0;
                $self->{pagesDetected} = 0;
            }
        }
    }

    sub text
    {
        my ( $self, $origtext ) = @_;
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//;
        $origtext =~ s/\n*//g;

        return if ( $origtext eq '' );

        if ( $self->{parsingList} )# partie en rapport à la page de résultats
        {
            if ( $self->{isFin} eq 2 && $self->{pass} eq 1)
            {
                # filter other media (TV, Film, products... )
                $self->{itemIdx}--
                    if ($origtext ne 'Manga' && $origtext ne 'BD' && $origtext !~ m/Livre/);
                $self->{isFin} = 0;
            }
            elsif ($self->{notationDetected} eq 1)
            {
                $origtext =~ s/,/./;
                $self->{rating} = $origtext;  # save rating in the serie description
            }
        }
        else # partie en rapport à la page de l'élément
        {
            return if ( $origtext eq '***');

            if ( $self->{tagH5detected} == 1 )
            {
                $self->{collectionDetected} = 1 if ($origtext =~ m/^Label/);
                $self->{costDetected}       = 1 if ($origtext =~ m/^Prix/);
                $self->{typeDetected}       = 1 if ($origtext =~ m/^Type/);
                $self->{isbnDetected}       = 1 if ($origtext =~ m/^EAN/);
                $self->{formatDetected}     = 1 if ($origtext =~ m/^Format/);
                $self->{pagesDetected}      = 1 if ($origtext =~ m/^Nombre/);
                $self->{publisherDetected}  = 1 if ($origtext =~ m/^Editeur/);

                $self->{tagH5detected} = 0;
            }
            elsif ($self->{serieDetected} == 1)
            {
                $self->{curInfo}->{title} = $origtext if !$self->{curInfo}->{title};
                if ($origtext =~ m/^(.*)\s\s*(\d\d*)\s\s\(*.*\)$/)
                {
                    $origtext = $1;
                }
                $self->{curInfo}->{series} = $origtext if !$self->{curInfo}->{series};
                $self->{serieDetected} = 0;
            }
            elsif ($self->{scenaristeDetected} == 2)
            {
                $self->{curInfo}->{writer} = $origtext;
            }
            elsif ($self->{dessinateurDetected} == 1)
            {
                $self->{curInfo}->{illustrator} = $origtext;
            }
            elsif ($self->{publisherDetected} == 1)
            {
                $self->{curInfo}->{publisher} = $origtext;
            }
            elsif ($self->{publishdateDetected} == 2)
            {
                $self->{curInfo}->{publishdate} = $self->decodeDate($origtext);
            }
            elsif ($self->{titleDetected} == 1)
            {
                $self->{curInfo}->{series} =  $origtext;
                $self->{titleDetected} = 2;
            }
            elsif ($self->{titleDetected} == 2)
            {
                $self->{curInfo}->{title} =  $origtext;
                $origtext =~ m/^(\d*)/;
                $self->{curInfo}->{volume} = $1;
                $self->{titleDetected} = 0;
            }
            elsif ($self->{volumeDetected} == 1)
            {
                $origtext =~ m/^(\d*)\//;
                $self->{curInfo}->{volume} = $1;
                $self->{volumeDetected} =0;
            }
            elsif ($self->{collectionDetected} == 1)
            {
                $self->{curInfo}->{collection} = $origtext;
                $self->{collectionDetected} =0;
            }
            elsif ($self->{costDetected} == 1)
            {
                $origtext =~ s/,/./;
                $origtext =~ m/^\s*(\d*\.\d*)/;
                $self->{curInfo}->{cost} = $1;
            }
            elsif ($self->{typeDetected} == 1)
            {
                $self->{curInfo}->{type} = $origtext;
            }
            elsif ($self->{categoryDetected} == 1)
            {
                $self->{curInfo}->{category} = $origtext;
            }
            elsif ($self->{genresDetected})
            {
                # no dedicated field for genre
                if ($self->{curInfo}->{synopsis} =~ m/Genres : /)
                {
                    $self->{curInfo}->{synopsis} .= ", ";
                }
                else
                {
                    $self->{curInfo}->{synopsis} .= "Genres : ";

                }
                $self->{curInfo}->{synopsis} .= $origtext;
            }
            elsif ($self->{isbnDetected} == 1)
            {
                $origtext =~ m/^\s*(.*?)\s*$/;
                $self->{curInfo}->{isbn} = $1;
            }
            elsif ($self->{formatDetected} == 1)
            {
                $origtext =~ m/^\s*(.*?)\s*$/;
                $self->{curInfo}->{format} = $1;
            }
            elsif ($self->{pagesDetected} == 1)
            {
                $origtext =~ m/^\s*(\d*?)\s*$/;
                $self->{curInfo}->{numberboards} = $1;
            }
            elsif ($self->{synopsisDetected} == 1)
            {
                $self->{curInfo}->{synopsis} .= "\n\n".$origtext;
            }
        }
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless( $self, $class );

        $self->{hasField} = {
            series => 1,
            title  => 1,
            type   => 1,
            format => 1,
            volume => 1,
            series => 1
        };

        $self->{itemIdx} = 0;
        $self->{downloadThumbnail} = 0;
        $self->{tagH5detected} = 0;
        $self->{titleDetected} = 0;
        $self->{serieDetected} = 0;
        $self->{titreFrancais} = 1;#défaut francais
        $self->{publisherDetected} = 0;
        $self->{collectionDetected} = 0;
        $self->{publishdateDetected} = 0;
        $self->{costDetected} = 0;
        $self->{typeDetected} = 0;
        $self->{categoryDetected} = 0;
        $self->{genresDetected} = 0;
        $self->{synopsisDetected} = 0;
        $self->{scenaristeDetected} = 0;
        $self->{dessinateurDetected} = 0;
        $self->{notationDetected} = 0;
        $self->{isbnDetected} = 0;
        $self->{formatDetected} = 0;
        $self->{pagesDetected} = 0;
        $self->{volumeDetected} = 0;

        $self->{nextUrlArray} = [];

        return $self;
    }

    sub preProcess
    {
        my ( $self, $html ) = @_;

        $self->{isFin} = 0;
        $self->{parsing} = 1;

        if (! $self->{parsingList})
        {
            if ($self->{rating})
            {
                $self->{curInfo}->{ratingpress} = $self->{rating};
                $self->{rating} = undef;
            }
        }
        undef $self->{nextUrl};
        return $html;
    }

    sub decodeDate
    {
        my ($self, $date) = @_;

        # date déjà dans le bon format
        return $date if ($date =~ m|/.*/|);

        $date = GCDates::strToTime($date,"%a %e %b %Y","FR");
        return GCDates::strToTime($date,"%B %Y","FR");
    }

    sub getSearchUrl
    {
        my ( $self, $word ) = @_;
        $word =~ s/\+\+*/ /g;
        return ('https://www.sanctuary.fr/index.php?page=recherche-resultats',['recherche' => $word]);
    }

    sub getItemUrl
    {
        my ( $self, $url ) = @_;

        return $url if $url =~ /^http/;
        return "https://www.sanctuary.fr" . $url;
    }

    sub getNumberPasses
    {
        return 3;
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} ne 3)
        {
            $self->{hasField} = {
                series => 1,
                title  => 1,
                volume => 1,
                publisher => 1,
            };
        }
        else
        {
            $self->{hasField} = {
                title  => 1,
                volume => 1,
                format => 1,
            };
        }
    }

    sub getName
    {
        return "Sanctuary";
    }

    sub getAuthor
    {
        return 'Biggriffon - Kerenoc';
    }

    sub getLang
    {
        return 'FR';
    }
}

1;
