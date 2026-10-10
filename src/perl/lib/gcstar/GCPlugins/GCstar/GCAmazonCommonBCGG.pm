package GCPlugins::GCstar::GCAmazonCommonBCGG;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2016-2024 Kerenoc
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

use GCPlugins::GCPluginsBase;
use GCPlugins::GCstar::GCAmazonCommon;

{
    package GCPlugins::GCstar::GCPluginAmazonCommonBCGG;

    # used for Books, Comics, Gadgets, Games

    use base ('GCPluginParser', 'GCPlugins::GCstar::GCPluginAmazonCommon');
    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'a' && $attr->{class} && $attr->{class} =~ /sponsored/ && $self->{getSponsored} ne 1)
            {
                $self->{isSponsored} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class} =~ /s-result-item/)
            {
                $self->{isSponsored} = 0;
                $self->{isUrl} = 1;
            }
            elsif ($tagname eq 'div' && $self->{isUrl} eq 1 && $attr->{class} =~ /a-section/)
            {
                $self->{isUrl} = 2;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class}  =~ /color-secondary/)
            {
                $self->{isTitle} = 0;
            }
            elsif ($self->{isSponsored} eq 1)
            {
                return;
            }
            elsif (($tagname eq 'li') && $attr->{id} && ($attr->{id} =~ /result_[0-9]+/ ))
            {
                $self->{isUrl} = 1 ;
                $self->{isAuthor} = 0 ;
            }
            elsif (($tagname eq 'div') && $attr->{"data-cel-widget"} && ($attr->{"data-cel-widget"} =~ /result_[0-9]+/ ))
            {
                $self->{isUrl} = 1 ;
                $self->{isAuthor} = 0 ;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class} =~ /price-instructions/)
            {
                $self->{isPlatform} = 1 if ($self->{searchType} eq 'games');
            }
            elsif ( ($tagname eq 'a') && $attr->{class} && ($attr->{class}=~ m/a-link-normal/) && ($attr->{class}=~ m/a-text-bold/) && ($self->{isPlatform}) )
            {
                $self->{isPlatform} = 2;
            }
            elsif ($tagname eq 'span' && $attr->{id} && $attr->{id} =~ /amazons-choice/)
            {
                $self->{isTitle} = 0;
            }
            # Capture URL of item
            elsif ($self->{isUrl} eq 2 && $tagname eq 'a' && $attr->{href} =~ /keywords/)
            {
                my $rootURL = '';
                $rootURL = 'https://'.$self->baseWWWamazonUrl if ($attr->{href} =~ m/^\//);
                $self->{url} = $rootURL.$attr->{href};
                #$self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                $self->{isUrl} = 0 ;
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'h2' && $self->{isTitle} eq 1)
            {
                $self->{isTitle} = 2;
            }
            # Identify beginning of new book (next text is title)
            elsif ($tagname eq 'h5')
            {
                $self->{isSponsored} = 1;
            }
        }
        else
        {
            if ($tagname eq 'a' && $attr->{href} && $attr->{href} =~ /esrb-teen-black-curtain/)
            {
                $self->{curInfo}->{nextUrl} = 'https://'.$self->baseWWWamazonUrl.$attr->{href};
            }
            # Detection of book themes based on best seller ranks
            elsif ($tagname eq 'ul' && $self->{isTheme} == 0 && $attr->{class} && $attr->{class} =~ m/zg_hrsr/)
            {
                $self->{isTheme} = 1 ;
            }

            # Detection of book page count
            elsif ($tagname eq 'td' && $self->{isPage} == 0 && $attr->{class} && $attr->{class} eq "bucket")
            {
                $self->{isPage} = 1 ;
            }

            # Detection of authors
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class}=~ m/author/i)
            {
                $self->{isAuthor} = 1;
                $self->{isBrand} = 0;
            }

            elsif ($tagname eq 'span' && $self->{isAuthor} eq 2 && $attr->{class} && $attr->{class} eq 'contribution')
            {
                $self->{isAuthor} = 3;
            }

            # Capture of image
            elsif ($tagname eq 'img' && $attr->{id} && ($attr->{id} =~ m/imgBlkFront/i || $attr->{id} =~ m/landingImage/i || $attr->{id} =~ m/main\-image/i))
            {
                $self->{curInfo}->{$self->{coverField}} = $attr->{src};
            }

            # Detection of item description
            elsif ($tagname eq 'div' && $attr->{id} && ($attr->{id} eq "bookDescription_feature_div"
                                                     || $attr->{id} eq "editorialReviews_feature_div"
                                                     || $attr->{id} eq "featurebullets_feature_div"
                                                     || $attr->{id} eq "productDescription_feature_div"))
            {
                $self->{isDescription} = 1 ;
            }

            # Detection of brand
            elsif ($tagname eq 'tr' && $attr->{class} && $attr->{class} =~ /po-brand/)
            {
                $self->{isField} = 1;
                $self->{field} = $self->{publisherField};
            }
            elsif ($tagname eq 'tr' && $attr->{class} && $attr->{class} =~ /po-hardware_platform/)
            {
                $self->{isField} = 1;
                $self->{field} = 'platform';
            }
            elsif ($tagname eq 'tr' && $attr->{class} && $attr->{class} =~ /po-publication_date/)
            {
                $self->{isField} = 1;
                $self->{field} = $self->{publicationField};
            }
            elsif ($tagname eq 'tr' && $attr->{class} && $attr->{class} =~ /po-genre/)
            {
                $self->{isField} = 1;
                $self->{field} = 'genre';
            }

            elsif($self->{isField} && $tagname eq 'span' && $attr->{class} && $attr->{class} =~ /po-break-word/)
            {
                $self->{isField} = 2;
            }

            elsif ($tagname eq 'div' && $self->{isDescription} eq 1)
            {
                $self->{isDescription} = 2 ;
                $self->{curInfo}->{$self->{descriptionField}} .= "\n" if $self->{curInfo}->{$self->{descriptionField}};
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ m/productDescription/)
            {
                $self->{isDescription} = 2;
                $self->{curInfo}->{$self->{descriptionField}} .= "\n" if $self->{curInfo}->{$self->{descriptionField}};
            }
            elsif ($tagname eq 'br' && $self->{isDescription} eq 2 && $self->{curInfo}->{description})
            {
                $self->{curInfo}->{$self->{descriptionField}} .= "\n";
            }
            elsif ($tagname eq 'h3' && $self->{isDescription} eq 2 && $self->{curInfo}->{description})
            {
                $self->{curInfo}->{$self->{descriptionField}} .= "\n";
            }
            elsif ($tagname eq 'li' && $self->{isDescription} eq 2 && $self->{curInfo}->{description})
            {
                $self->{curInfo}->{$self->{descriptionField}} .= "\n- ";
            }

            # Detection title
            elsif ($tagname eq 'span' && $attr->{id} && ($attr->{id} =~ m/productTitle/i))
            {
                $self->{isTitle} = 1 ;
            }

            # Detection of details
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} eq 'detail-bullets_feature_div')
            {
                $self->{isDetails} = 1;
            }
            elsif ($tagname eq 'div' && $self->{isDetails} eq 1)
            {
                $self->{isDetails} += 1
                    if ($attr->{class} eq 'content' || $attr->{class} eq 'disclaim');
            }
            elsif ($tagname eq 'style' || $tagname eq 'script')
            {
                $self->{isDetails} = 0;
                $self->{isDescription} = 0;
                $self->{isCode} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ /platformInformation_feature_div/)
            {
                $self->{isDetails} = 0;
                $self->{isPublication} = 1;
            }
            elsif (($tagname eq 'li' || $tagname eq 'tr') && $self->{isDetails} eq 2)
            {
                $self->{curInfo}->{characteristics} .= "\n"
                    if ($self->{curInfo}->{characteristics} && $self->{curInfo}->{characteristics} !~ m/\n$/);
            }
            elsif ($tagname eq 'td' && $self->{isDetails} eq 2 && $attr->{class} =~ m/value/i)
            {
                $self->{curInfo}->{characteristics} .= " : ";
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ m/productDetails/)
            {
                $self->{isDetails} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} eq 'feature-bullets')
            {
                $self->{isDetails} = 1;
            }
            elsif ($tagname eq 'span' && $self->{isDetails} eq 1 && $attr->{class} eq 'a-list-item')
            {
                $self->{isDetails} = 3;
            }
            elsif ($tagname eq 'li' && $self->{isDetails} eq 3 )
            {
                $self->{isDetails} = 2;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~  m/^averageCustomerReviews/)
            {
                $self->{isEdition} = 0;
                $self->{isBrand} = 0;
                $self->{isRating} = 1;
                $self->{isPublication} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ m/globalStore/ )
            {
                $self->{isDescription} = 0 ;
                $self->{isPublication} = 0;
            }
            elsif ($tagname eq 'script' && $self->{isDescription} eq 2)
            {
                $self->{isDescription} = 1;
            }
            elsif ($tagname eq 'span' && $self->{isDescription} eq 2)
            {
                $self->{curInfo}->{$self->{descriptionField}} .= " " if $self->{curInfo}->{$self->{descriptionField}};
            }
            elsif ($tagname eq 'br' && $self->{isDescription} eq 2)
            {
                $self->{curInfo}->{$self->{descriptionField}} .= "\n" if $self->{curInfo}->{$self->{descriptionField}};
            }
            elsif ($tagname eq 'a' && $attr->{href} && $attr->{href} =~ m/zg_hrsr/)
            {
                $self->{isTheme} = 2;
            }
            # data in caroussel
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class} =~ m/details-publisher/)
            {
                $self->{isEditor} = 1;
            }
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class} =~ m/details-isbn13/)
            {
                $self->{isISBN} = 1;
            }
            elsif (($tagname eq 'span' || $tagname eq 'a') && $attr->{class} && $attr->{class} =~ m/details-series/)
            {
                $self->{isSerie} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ m/seriesBulletWidget/)
            {
                $self->{isSerie} = 2;
            }
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class} =~ m/details-(publication_date|release-date)/)
            {
                $self->{isPublication} = 1;
            }
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class} =~ m/details-dimensions/)
            {
                $self->{isSize} = 1;
            }
            elsif ($tagname eq 'span' && $attr->{class} && $attr->{class} =~ m/language/)
            {
                $self->{isLanguage} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ /_feature_div/)
            {
                $self->{isDetails} = 0;
                $self->{isDescription} = 0;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;

        if ($self->{parsingList})
        {
            # Identify end of authors
            if ($self->{isAuthor} eq 2 && $tagname eq 'div')
            {
                $self->{isAuthor} = 0;
            }
        }
        else
        {
            # Finishing themes analysis
            if (($self->{isTheme} != 0) && ($tagname eq 'li'))
            {
                $self->{isTheme} = 1 ;
            }

            # Finishing publication analysis
            elsif (($self->{isPublication} != 0) && ($tagname eq 'li' || $tagname eq 'h1'))
            {
                $self->{isPublication} = 0 ;
            }
            # Table of characteristics
            elsif ($self->{isDetails} eq 2 && $tagname eq 'ul')
            {
                $self->{isDetails} = 0;
            }
            elsif ($self->{isDescription} eq 1 && $tagname eq 'script')
            {
                $self->{isDescription} = 2;
            }
            elsif ($self->{isDescription} eq 1 && $tagname eq 'span')
            {
                $self->{isDescription} = 2;
            }
            elsif ($self->{isCode} && ($tagname eq 'style' || $tagname eq 'script'))
            {
                $self->{isCode} = 0;
            }
            elsif ($tagname eq 'ul' && $self->{isDescription} eq 2)
            {
                $self->{curInfo}->{$self->{descriptionField}} .= "\n";
            }
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;
        # Remove blanks before and after string
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;
        $origtext =~ s/\n//g;
        return if ($self->{isEnd} || $origtext eq '' || $self->{isCode});

        if ($self->{parsingList})
        {
            if ($origtext =~ /$self->{translations}->{sponsored}/ && $self->{searchType} ne 'gadgets' && $self->{getSponsored} ne 1)
            {
                $self->{isSponsored} = 1;
                $self->{isTitle} = 0;
            }
            elsif ($self->{isUrl} eq 2)
            {
                $self->{brandName} = $origtext;
            }
            elsif ($self->{isTitle} eq 2 && $origtext ne 'Choix' && $origtext ne 'Results')
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{url};
                if (0 && $self->{brandName})
                {
                    $origtext = $self->{brandName}." ".$origtext;
                    $self->{brandName} = "";
                }
                $self->{itemsList}[$self->{itemIdx}]->{$self->{titleField}} = $origtext;
                $self->{itemsList}[$self->{itemIdx}]->{authors} = '';
                $self->{isTitle} = 0 ;
                $self->{isEdition} = 1;
                $self->{isAuthor} = 0;
            }
            elsif ($self->{isTitle} eq 3)
            {
                $self->{itemsList}[$self->{itemIdx}]->{$self->{titleField}} .= " ".$origtext;
                $self->{isTitle} = 0;
            }
            elsif (($self->{isEdition} || $self->{isAuthor} eq 1) &&
                    ($origtext eq '|' || $origtext =~ /^ *($self->{translations}->{by}|by)$/i))
            {
                $self->{isAuthor} = 2;
                $self->{isEdition} = 0;
            }
            elsif ($self->{isPublication} && $origtext !~ /$self->{translations}->{by}/i)
            {
                $self->{itemsList}[$self->{itemIdx}]->{$self->{publicationField}} = $self->decodeDate($origtext);
                $self->{isAuthor} = 1;
                $self->{isPublication} = 0;
            }

            # Capture of authors
            elsif ($self->{isAuthor} == 2)
            {
                return if ($origtext =~ /($self->{translations}->{by}|by)$/i);
                if ($origtext eq '|')
                {
                    $self->{isPublication} = 1;
                    $self->{isAuthor} = 0;
                }
                elsif ($self->{itemsList}[$self->{itemIdx}]->{authors} eq '')
                {
                    $self->{itemsList}[$self->{itemIdx}]->{authors} = $origtext;
                }
                else
                {
                    $self->{itemsList}[$self->{itemIdx}]->{authors} .= " " . $origtext;
                }
            }
            elsif ($self->{isPlatform} eq 2 && $self->{itemIdx} ne -1)
            {
                if ($origtext =~ /(Prime Video|Audio CD|Vinyl|Softcover|Hardcover)/)
                {
                    $self->{itemIdx}--;
                }
                else
                {
                    $self->{itemsList}[$self->{itemIdx}]->{platform} = $origtext; #$self->transformPlatform($origtext);
                }
                $self->{isPlatform} = 0; # platform found
            }
            elsif ($origtext =~ /^$self->{translations}->{end}/)
            {
                $self->{isEnd} = 1;
            }
        }
        else
        {
            # Capture of title
            if ($self->{isTitle} eq 1 && ! $self->{curInfo}->{$self->{titleField}})
            {
                $self->{isTitle} = 0 ;
                $self->{curInfo}->{$self->{titleField}} = $origtext;
                my $volume = $self->{curInfo}->{$self->{titleField}};
                $volume =~ s/(.*) *\((.*), *(T|[Vv]olume|[Vv]ol|[Tt]ome|n°|Book)[ \.]?(\d+)\).*/$2 \#$4/;
                $volume =~ s/(.*) -? ?(T|[Vv]olume|[Vv]ol|[Tt]ome|n°|Book)[ \.]?(\d+).*/$1 $3/;
                $volume =~ s/(.*) \#(\d+).*/$1 $2/;
                $volume =~ s/(.*) (\d+): .*$/$1 $2/;
                $volume =~ s/(.*) \(?(\d+)\)?$/$2/;
                $self->{curInfo}->{$self->{seriesField}} = $1 if $2;
                $self->{curInfo}->{volume} = $volume if ($volume =~ /^\d+$/);
                $self->{isEdition} = 1;
            }
            elsif ($self->{isEdition} && $origtext =~ /$($self->{translations}->{by})/i)
            {
                $self->{isEdition} = 0;
                $self->{isPublication} = 1;
                if ($origtext =~ m/$self->{translations}->{brand}\s*:\s*(.*)/)
                {
                    $self->{curInfo}->{$self->{publisherField}} = $1;
                    $self->{curInfo}->{brand} = $1;
                }
                else
                {
                    $self->{curInfo}->{edition} = $origtext;
                }
            }

            # Capture of page number
            elsif ($origtext  =~ / $self->{translations}->{pages}$/)
            {
                $origtext =~ s/[^0-9]*([0-9]+) $self->{translations}->{pages}/$1/;
                $self->{curInfo}->{$self->{nbpagesField}} = $origtext;
                $self->{isPage} = 0 ;
            }

            # Capture of authors
            elsif ($self->{isAuthor} == 1 && $origtext =~ /^(?:(?!Ajax).)*$/)
            {
                # Lower case for author names, except for first letters
                $origtext =~ s/([[:alpha:]]+)/ucfirst(lc $1)/egi;
                $self->{author} = $origtext;
                $self->{isAuthor} = 2;
            }
            elsif ($self->{isAuthor} == 3)
            {
                if ($origtext =~ m/$self->{translations}->{author}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if $self->{curInfo}->{$self->{authorField}};
                    $self->{curInfo}->{$self->{authorField}} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{translator}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if $self->{curInfo}->{translator};
                    $self->{curInfo}->{translator} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{artist}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if $self->{curInfo}->{$self->{illustratorField}};
                    $self->{curInfo}->{$self->{illustratorField}} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{publisher}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if $self->{curInfo}->{$self->{publisherField}};
                    $self->{curInfo}->{$self->{publisherField}} .= $self->{author};
                }
                else
                {
                    # affichage du rôle
                    $origtext =~ s/,$//;
                    $origtext =~ s/,/ &/g;
                    $self->{author} .= " ".$origtext;
                    $self->{author} =~ s/, *$//;
                    $self->{author} = ", ".$self->{author}
                        if ($self->{curInfo}->{authors} && $self->{curInfo}->{authors} ne '');
                    $self->{curInfo}->{authors} .= $self->{author};
                }
                $self->{isAuthor} = 0 ;
            }
            elsif ($self->{isPublication} && $origtext =~ /$self->{translations}->{platform}/)
            {
                $self->{isPlatform} = 1 if ($self->{searchType} eq 'games');
            }
            elsif ($self->{isPlatform})
            {
                $self->{curInfo}->{platform} = $origtext;
                $self->{isPlatform} = 0;
            }
            # Capture of editor and publication date
            elsif ($origtext =~ /^\(*$self->{translations}->{publisher}/ && ! $self->{curInfo}->{$self->{publisherField}})
            {
                if ($origtext =~ m/ *: *(.*)/)
                {
                    $self->{curInfo}->{$self->{publisherField}} = $1;
                }
                else
                {
                    $self->{isEditor} = 1;
                }
            }
            elsif ($origtext =~ /^\(*$self->{translations}->{publication}/)
            {
                $self->{isPublication} = 1;
            }
            elsif ($self->{isEditor} == 1 || $self->{isPublication} == 1)
            {
                my $myDate;
                if ($self->{isEditor} && $origtext ne '&')
                {
                    my @array = split('\(',$origtext);
                    $self->{isEditor} = 0;
                    $array[0] =~ s/\;.*//g;
                    $self->{curInfo}->{$self->{publisherField}} = $array[0] if (! $self->{curInfo}->{$self->{publisherField}});
                    $self->{isField} = 0 ;
                    return if ($#array eq 0);
                    $myDate = $array[$#array];
                }
                else
                {
                    $self->{isPublication} = 0;
                    $myDate = $origtext;
                    $myDate =~ s/.*–\s+//; # beware : not the usual minus caracter
                    return if (! ($myDate =~ /\d\d\d\d/));
                }
                return if ($self->{curInfo}->{$self->{publicationField}});
                # le champ contenant l'éditeur et la date de parution peut contenir plusieurs parenthèses
                # on suppose que la dernière contient la date
                $self->{curInfo}->{$self->{publicationField}} = $self->decodeDate($myDate);
            }

            # Capture of language
            elsif (($self->{isLanguage} == 0) && index($origtext,$self->{translations}->{language}) eq 0)
            {
                $self->{isLanguage} = 1 ;
            }
            elsif ($self->{isLanguage} == 1)
            {
                $self->{curInfo}->{language} = $origtext;
                $self->{isLanguage} = 0 ;
            }

            # Capture of ISBN
            elsif (($self->{isISBN} == 0) && index($origtext,$self->{translations}->{isbn}) eq 0)
            {
                $self->{isISBN} = 1 ;
            }
            elsif ($self->{isISBN} == 1)
            {
                $origtext =~ s|-||gi;
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }
            elsif ($self->{isSerie} == 1 && ! $self->{curInfo}->{$self->{seriesField}})
            {
                $self->{curInfo}->{$self->{seriesField}} = $origtext;
                $self->{isSerie} = 0 ;
            }
            elsif ($self->{isSerie} == 2)
            {
                if ($origtext =~ /(\d+)[^0-9]+(\d+).*:.*(.*)/)
                {
                    $self->{curInfo}->{$self->{seriesField}} = $3;
                    $self->{curInfo}->{volume} = $1;
                }
                $self->{isSerie} = 3 ;
            }

            # Capture of book dimensions
            elsif (($self->{isSize} == 0) && index($origtext,$self->{translations}->{dimensions}) > -1)
            {
                $self->{isSize} = 1 ;
            }
            elsif ($self->{isSize} == 1)
            {
                $self->{curInfo}->{format} = $origtext;
                $self->{isSize} = 0 ;
            }

            # Capture of themes
            elsif ($self->{isTheme} == 2 && $origtext ne 'in')
            {
                $self->{isTheme} = 1 ;
                foreach my $genre(@{$self->{curInfo}->{genre}})
                {
                    return if ($origtext eq @{$genre}[0]);
                }
                push @{$self->{curInfo}->{genre}}, [$origtext];
            }

            # Capture of series
            elsif (($self->{isSerie} == 0) && index($origtext,$self->{translations}->{series}) eq 0)
            {
                $self->{isSerie} = 1 ;
            }

            elsif ($origtext =~ /^$self->{translations}->{product}/)
            {
                $self->{isDetails} = 2;
            }
            elsif ($origtext eq $self->{translations}->{end})
            {
                $self->{isDetails} = 0;
            }
            # Capture of description
            elsif ($self->{isDescription} == 2)
            {
                return if $origtext =~ m/^($self->{translations}->{skip})/;
                $self->{curInfo}->{$self->{descriptionField}} .= $origtext;
                $self->{curInfo}->{brand} = $origtext if $self->{isBrand};
                $self->{isBrand} = 0;
                $self->{isBrand} = 1 if $origtext eq $self->{translations}->{brand};
            }

            # Capture of brand
            elsif ($self->{curInfo}->{$self->{titleField}} && ! $self->{curInfo}->{brand} && $origtext =~ /$($self->{translations}->{by})/i)
            {
                $self->{isBrand} = 1;
                $self->{isEdition} = 0;
            }
            elsif ($self->{isBrand})
            {
                $self->{curInfo}->{brand} = $origtext;
                $self->{isBrand} = 0;
            }
            elsif ($self->{isRating})
            {
                $origtext =~ s/,/./;
                $self->{curInfo}->{ratingpress} = $origtext * 2;
                $self->{isRating} = 0;
            }
            elsif ($self->{isField} eq 2)
            {
                $origtext =~ s/\.+$//;
                if ($self->{field} eq 'genre')
                {
                    push @{$self->{curInfo}->{genre}}, [$origtext];
                }
                elsif ($self->{field} eq $self->{publicationField})
                {
                    $self->{curInfo}->{$self->{field}} = $self->decodeDate($origtext);
                }
                else
                {
                    $self->{curInfo}->{$self->{field}} = $origtext;
                }
                $self->{isField} = 0;
            }

            # Capture of details
            if ($self->{isDetails} eq 2)
            {
                $origtext =~ s/  */ /g;
                $self->{curInfo}->{characteristics} .= $origtext." ";
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
            edition => 0,
        };

        $self->{titleField} = 'title';

        $self->initFieldNames();

        $self->initTranslations();

        return $self;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
    }

    sub getSearchFieldsArray
    {
        my $self = shift;
        return $self->{searchFieldsArray};
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        # minimum initialization
        $self->{isUrl} = 0;
        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isPage} = 0;
        $self->{isEditor} = 0;
        $self->{isISBN} = 0;
        $self->{isSerie} = 0;
        $self->{isSize} = 0;
        $self->{isDescription} = 0;
        $self->{isLanguage} = 0 ;
        $self->{isTheme} = 0 ;
        $self->{isPublication} = 0 ;
        $self->{isDetails} = 0;
        $self->{isSponsored} = 0;
        $self->{isBrand} = 0;
        $self->{isRating} = 0;
        $self->{isCode} = 0;
        $self->{isField} = 0;
        $self->{isPlatform} = 0;
        $self->{isEnd} = 0;

        $self->initTranslations();

        if ($self->{parsingList})
        {
            # Remove other commercial offers
            $html =~ s|END SPONSORED LINKS SCRIPT.*||s;
            # End of authors listing detection
        }
        else
        {
            $html =~ s|<BR[ /]*>|<br>|gi;
            $html =~ s|<P>|<br>|gi;
            $html =~ s|<I>|<br>* |gi;
            $html =~ s|</I>||gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
            $html =~ s|&#146;|'|gi;

            $self->{curInfo}->{characteristics} = "";
            $self->{curInfo}->{ean} = $self->{title}
                if ($self->{searchType} eq 'gadgets' && ! ($self->{searchField} eq 'title'));
        }
        return $html;
    }

    sub setSponsored
    {
        my ($self, $word) = @_;

        $self->{getSponsored} = $self->{searchType} eq 'gadgets' ? 1 : 0 ;
        if ($word =~ /sponsored%3A/)
        {
            $self->{getSponsored} = 1 if ($word =~ /sponsored%3Ay/);
            $self->{getSponsored} = 0 if ($word =~ /sponsored%3An/);
            $word =~ s/\+* *sponsored%3A[^ ]*//;
        }
        return $word;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $word = $self->setSponsored($word);
        my $itemType = 'stripbooks';
        $itemType = 'electronics' if ($self->{searchType} eq 'gadgets');
        $itemType = 'videogames'  if ($self->{searchType} eq 'games');
        return 'https://' . $self->baseWWWamazonUrl . '/s/ref=nb_sb_noss_1?url=search-alias='.$itemType.'&field-keywords=' . "$word";
    }

    sub getAuthor
    {
        return 'Varkolak - Kerenoc';
    }

    sub getCharset
    {
        my $self = shift;
        return "UTF-8";
    }

    sub getEanField
    {
        my $self = shift;

        my $field = (ref($self) =~ /gadgets/) ? 'ean' : 'isbn';
        return $field;
    }

    sub initTranslations
    {
        my $self = shift;

        my $lang = $self->getLang;

        if ($lang eq 'FR')
        {
            $self->{translations} = {
                publisher     => "(Editeur|Fabricant|Marque)",
                publication   => "(Date de publication|Date de sortie)",
                language      => "Langue",
                isbn          => "ISBN-13",
                dimensions    => "Dimensions du produit",
                series        => "Collection",
                pages         => "pages",
                by            => "(de|par)",
                product       => "(Informations sur le produit|Description du produit|Description du fabricant|Détails sur le produit)",
                brand         => "Marque",
                details       => "Descriptif technique",
                additional    => "Informations complémentaires",
                sponsored     => "Sponsorisé",
                description   => "Description",
                author        => "Auteur",
                translator    => "Traduction",
                artist        => "Illustration",
                platform      => "Plate-forme",
                skip          => "(En lire plus|Voir plus de d)",
                end           => "(Votre avis|Questions et r|Produits li|Commentaires clients|Utilisez moins de mots)"
            };
        }
        elsif ($lang eq 'PT')
        {
            $self->{translations} = {
                publisher     => "(Editora|Edição)",
                publication   => "(Data de publicação|Data de lançamento)",
                language      => "Idioma",
                isbn          => "ISBN-13",
                dimensions    => "Dimensões do produto",
                series        => "Coleção",
                pages         => "páginas",
                by            => "por",
                product       => "(Informações do produto|Descrição do produto)",
                brand         => "Marca",
                details       => "(Descrição técnica|Detalhes do produto)",
                additional    => "Informações complementares",
                sponsored     => "Patrocinados",
                description   => "Descrição",
                author        => "Autor",
                translator    => "Tradutor",
                artist        => "Ilustrador",
                platform      => "Plataforma",
                skip          => "Leia mais",
                end           => "Sua opinião",
            };
        }
        elsif ($lang eq 'DE')
        {
            $self->{translations} = {
                publisher     => "Verlag",
                publication   => "(Erscheinungsdatum|Erscheinungstermin)",
                language      => "Sprache",
                isbn          => "ISBN",
                dimensions    => "e und/oder Gewicht",
                series        => "Series",
                pages         => "Seiten",
                by            => "von",
                product       => "(Produktinformation|Produktbeschreibungen)",
                brand         => "Marke",
                details       => "Technische Details",
                additional    => "Zusätzliche Produktinformationen",
                sponsored     => "Gesponsert",
                description   => "Produktbeschreibungen",
                author        => "Autor",
                translator    => "bersetzer",  # Übersetzer
                artist        => "Illustrator",
                platform      => "(Platform|Plattform)",
                skip          => "Read more",
                end           => "(Feedback|Kundenfragen|Kundenrezensionen)"
            };
        }
        elsif ($lang eq 'PL')
        {
            $self->{translations} = {
                publisher     => "(Wydawca)",
                publication   => "(Data publikacji)",
                language      => "Język",
                isbn          => "ISBN-13",
                dimensions    => "Wymiary",
                series        => "Coleção",
                pages         => "Długość wersji drukowanej",
                by            => "por",
                product       => "(Informacje o tym produkcie|Informacje o produkcie)",
                brand         => "Marka",
                details       => "(Szczegóły produktu|Szczegóły techniczne)",
                additional    => "Informações complementares",
                sponsored     => "Sponsorowane",
                description   => "Opis",
                author        => "Autor",
                translator    => "Tłumacz",
                artist        => "Ilustrator",
                platform      => "Platforma",
                skip          => "Leia mais",
                end           => "Opinie o produkcie",
            };
        }
        elsif ($lang eq 'JA')
        {
            $self->{translations} = {
                publisher     => "(Publisher|Manufacturer)",
                publication   => "(Release Date|Date First Available|発売日)",
                language      => "Language",
                isbn          => "ISBN",
                dimensions    => "Product Dimensions",
                series        => "Series",
                pages         => "pages",
                by            => "by",
                product       => "(登録情報|商品の説明|Product [Dd]escription|Product information|Product details)",
                brand         => "Brand",
                details       => "Technical Details",
                additional    => "Additional Information",
                end           => "Feedback",
                sponsored     => "Sponsored",
                description   => "Description",
                author        => "Author",
                translator    => "Translator",
                artist        => "Illustrator",
                platform      => "プラットフォーム",
                skip          => "Read more",
                end           => "(Frequently bought|Sponsored products|Customers who|Customer question|Customer reviews|What other items)",
            };
        }
        else
        {
            $self->{translations} = {
                publisher     => "(Publisher|Manufacturer)",
                publication   => "(Release [dD]ate|Date First Available)",
                language      => "Language",
                isbn          => "ISBN",
                dimensions    => "Product Dimensions",
                series        => "Series",
                pages         => "pages",
                by            => "by",
                product       => "(Product information|Product details|Product [Dd]escription|About the product)",
                brand         => "Brand",
                details       => "Technical Details",
                additional    => "Additional Information",
                sponsored     => "Sponsored",
                description   => "Description",
                author        => "Author",
                translator    => "Translator",
                artist        => "Illustrator",
                platform      => "Platform",
                skip          => "(Read more|Learn more)",
                end           => "(Frequently bought|Sponsored products|Customers who|Customer question|Customer reviews|What other items|Feedback|Related searches)",
            };
        }
    }
}

1;
