package GCPlugins::GCbooks::GCAmazon;

###################################################
#
#  Copyright 2005-2009 Tian
#  Copyright 2016-2019 Kerenoc
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
use GCPlugins::GCstar::GCAmazonCommon;

{
    package GCPlugins::GCbooks::GCPluginAmazon;
    
    # used for Books and Gadgets

    use base ('GCPlugins::GCbooks::GCbooksPluginsBase', 'GCPlugins::GCstar::GCPluginAmazonCommon');
    use XML::Simple;
    use LWP::Simple qw($ua);
    use Encode;
    use HTML::Entities;
    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class}  eq 's-item-container')
            {
                $self->{isSponsored} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{class}  =~ /s-result-list/)
            {
                $self->{isSponsored} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{class}  =~ /sg-col-inner/)
            {
                $self->{isSponsored} = 0;            	
            }
            elsif (($tagname eq 'li') && ($attr->{id} =~ /result_[0-9]+/ ))
            {
                $self->{isUrl} = 1 ;
                $self->{isAuthor} = 0 ;
            }
            elsif ($tagname eq 'div')
            {
                if ($attr->{'data-asin'})
                {
                    $self->{isUrl} = 1 ;
                    $self->{isAuthor} = 0 ;
                }
            }
            elsif ($self->{isSponsored} eq 1)
            {
                return;
            }
            # Capture URL of book
            elsif ($self->{isUrl} && $tagname eq 'a' && $attr->{href} =~ /keyword/)
            {
            	return if ($self->{isSponsored});
            	$self->{isSponsored} = 0;
                my $rootURL = '';
                $rootURL = 'http://'.$self->baseWWWamazonUrl if ($attr->{href} =~ m/^\//);
                $self->{url} = $rootURL.$attr->{href};
                #$self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                $self->{isUrl} = 0 ;
                $self->{isTitle} = 1 ;
            }

            # Identify beginning of new book (next text is title)
            elsif ($tagname eq 'h5')
            {
                $self->{isSponsored} = 1;
            }
        }
        else
        {
            # Detection of book themes
            if ($self->{isTheme} == 0 && $tagname eq 'li' && $attr->{class} eq "zg_hrsr_item")
            {
                $self->{isTheme} = 1 ;
            }

            # Detection of book page count
            elsif ($self->{isPage} == 0 && $tagname eq 'td' && $attr->{class} eq "bucket")
            {
                $self->{isPage} = 1 ;
            }

            # Detection of authors
            elsif ($tagname eq 'span' && $attr->{class} =~ m/author/i)
            {
                $self->{isAuthor} = 1;
                $self->{isBrand} = 0;
            }

            elsif ($tagname eq 'span' && $self->{isAuthor} eq 2 && $attr->{class} eq 'contribution')
            {
                $self->{isAuthor} = 3;
            }

            # Capture of image
            elsif ($tagname eq 'img' && ($attr->{id} =~ m/imgBlkFront/i || $attr->{id} =~ m/landingImage/i || $attr->{id} =~ m/main\-image/i))
            {
                $self->{curInfo}->{cover} = $attr->{src};
                $self->{curInfo}->{image} = $attr->{src};
            }

            # Detection of book description
            elsif ($self->{isDescription} == 0 && $tagname eq 'script' && $attr->{id} eq "bookDesc_override_CSS")
            {
                $self->{isDescription} = 1 ;
            }
            elsif (($self->{isDescription} == 1) && ($tagname eq 'div'))
            {
                $self->{isDescription} = 2 ;
	        }
	        elsif ($tagname eq 'div' && $attr->{id} eq 'productDescription')
	        {
	        	$self->{isDescription} = 2;
	        }
	        elsif ($self->{isDescription} eq 2 && $tagname eq 'br')
	        {
	        	$self->{curInfo}->{description} .= "\n";
	        }
	        
            # Detection title
            elsif (($tagname eq 'span') && ($attr->{id} =~ m/productTitle/i))
            {
                $self->{isTitle} = 1 ;
            }
            
            # Detection of details
            elsif ($tagname eq 'div' && $attr->{id} eq 'detail-bullets_feature_div')
            {
            	$self->{isDetails} = 1;
            }
            elsif ($self->{isDetails} eq 1 && $tagname eq 'div')
            {
                $self->{isDetails} += 1
                    if ($attr->{class} eq 'content' || $attr->{class} eq 'disclaim');
            }
            elsif ($tagname eq 'style' || 0 && ($self->{isDetails} eq 2 && $tagname eq 'div'))
            {
            	$self->{isDetails} = 0;
            }
            elsif ($self->{isDetails} eq 2 && $tagname eq 'li') 
            {
                $self->{curInfo}->{characteristics} .= "\n";
            }
            elsif ($self->{isDetails} eq 2 && $tagname eq 'td' && $attr->{class} eq 'value') 
            {
                $self->{curInfo}->{characteristics} .= " : ";
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'feature-bullets')
           	{
            	$self->{isDetails} = 1;
            } 
            elsif ($self->{isDetails} eq 1 && $tagname eq 'span' && $attr->{class} eq 'a-list-item')
            {
				$self->{isDetails} = 3;
            } 
            elsif ($self->{isDetails} eq 3 && $tagname eq 'li')
            {
            	$self->{isDetails} = 2;
            }
            elsif ($self->{isEdition} && $tagname eq 'div' && $attr->{id} =~  m/averageCustomerReviews/)
            { 
            	$self->{isEdition} = 0;
            	$self->{isRating} = 0;
            	# TODO : add rating for Amazon books
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
                $self->{isTheme} = 0 ;
            }

            # Finishing description analysis
            elsif (($self->{isDescription} != 0) && ($tagname eq 'div'))
            {
                $self->{isDescription} = 0 ;
            }

            # Finishing publication analysis
            elsif (($self->{isPublication} != 0) && ($tagname eq 'li'))
            {
                $self->{isPublication} = 0 ;
            }
            # Table of characteristics
            elsif ($self->{isDetails} eq 2 && $tagname eq 'tr') 
            {
                $self->{curInfo}->{characteristics} .= "\n";
            }
            elsif ($self->{isDetails} eq 2 && $tagname eq 'ul')
            {
            	$self->{isDetails} = 0;
            }
            # Finishing product details
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;
        # Remove blanks before and after string
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;
        $origtext =~ s/\n//g;
        return if ($origtext eq '');

        if ($self->{parsingList})
        {
            if ($origtext =~ /$self->{translations}->{sponsored}/)
            {
            	$self->{isSponsored} = 1 ;
            	$self->{isTitle} = 0;
            }
           
            elsif ($self->{isTitle} eq 1)
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{url};
                $self->{itemsList}[$self->{itemIdx}]->{title} = $origtext;
                $self->{isTitle} = 0 ;
                $self->{isPublication} = 1;
                $self->{isAuthor} = 0;
            }
            elsif (($self->{isPublication} || $self->{isAuthor}) && $origtext eq $self->{translations}->{by})
            {
                $self->{isPublication} = 0;
                $self->{isAuthor} = 2;
            	
            }
	        elsif ($self->{isPublication})
	        {
                $self->{itemsList}[$self->{itemIdx}]->{publication} = $self->decodeDate($origtext);
                $self->{isAuthor} = 1;
                $self->{isPublication} = 0;
	        }
	
	        # Capture of authors
	        elsif ($self->{isAuthor} == 2)
	        {
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
	    }
        else
        {
            # Capture of title
            if ($self->{isTitle} == 1)
            {
                $self->{isTitle} = 0 ;
                $self->{curInfo}->{title} = $origtext;
                $self->{isEdition} = 1;
            }
            elsif ($self->{isEdition} && index($origtext,$self->{translations}->{by}) ne 0)
            {
            	$self->{isEdition} = 0;
            	$self->{curInfo}->{edition} = $origtext;
            	$self->{isPublication} = 1;
            }
            
            # Capture of page number
            elsif ($origtext  =~ / $self->{translations}->{pages}$/)
            {
                $origtext =~ s/[^0-9]*([0-9]+) $self->{translations}->{pages}/$1/;
                $self->{curInfo}->{pages} = $origtext;
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
                        if ($self->{curInfo}->{authors} ne '');
                    $self->{curInfo}->{authors} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{translator}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if ($self->{curInfo}->{translator} ne '');
                    $self->{curInfo}->{translator} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{artist}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if ($self->{curInfo}->{artist} ne '');
                    $self->{curInfo}->{artist} .= $self->{author};
                }
                elsif ($origtext =~ m/$self->{translations}->{publisher}/i)
                {
                    $self->{author} = ", ".$self->{author}
                        if ($self->{curInfo}->{publisher} ne '');
                    $self->{curInfo}->{publisher} .= $self->{author};
                }
                else
                {
                    # affichage du rôle
                    $origtext =~ s/,$//;
                    $origtext =~ s/,/ &/g;
                    $self->{author} .= " ".$origtext;
                    $self->{author} =~ s/, *$//;
                    $self->{author} = ", ".$self->{author}
                        if ($self->{curInfo}->{authors} ne '');
                    $self->{curInfo}->{authors} .= $self->{author};
                }
                $self->{isAuthor} = 0 ;
            }

            # Capture of editor and publication date
            elsif ($origtext =~ /^\(*$self->{translations}->{publisher}.*:/)
            {
                $self->{isEditor} = 1 ;
            }
            elsif ($origtext =~ /^\(*$self->{translations}->{publication}/)
            {
                $self->{isPublication} = 1 ;
            }
            elsif ($self->{isEditor} == 1 || $self->{isPublication} == 1)
            {
                my $myDate;
                if ($self->{isEditor} && $origtext ne '&')
                {
                	my @array = split('\(',$origtext);
                	$self->{isEditor} = 0 ;
                    $array[0] =~ s/\;.*//g;
                    $self->{curInfo}->{publisher} = $array[0] if (! $self->{curInfo}->{publisher});
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
                return if ($self->{curInfo}->{publication});
                # le champ contenant l'éditeur et la date de parution peut contenir plusieurs parenthèses
                # on suppose que la dernière contient la date
                $self->{curInfo}->{publication} = $self->decodeDate($myDate);
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

            # Capture of brand
            elsif ($self->{curInfo}->{title} && ! $self->{curInfo}->{brand} && index($origtext,$self->{translations}->{by}) eq 0)
            {
            	$self->{isBrand} = 1;
            	$self->{isEdition} = 0;
            }
            elsif ($self->{isBrand})
            {
            	$self->{curInfo}->{brand} = $origtext;
            	$self->{isBrand} = 0;
            }
            
            # Capture of ISBN
            elsif (($self->{isISBN} == 0) && index($origtext,$self->{translations}->{isbn}) eq 0)
            {
                $self->{isISBN} =1 ;
            }
            elsif ($self->{isISBN} == 1)
            {
                $origtext =~ s|-||gi;
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }

            # Capture of series
            elsif (($self->{isSerie} == 0) && index($origtext,$self->{translations}->{series}) eq 0)
            {
                $self->{isSerie} =1 ;
            }
            elsif ($self->{isSerie} == 1)
            {
                $self->{curInfo}->{serie} = $origtext;
                $self->{isSerie} = 0 ;
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

            # Detection of themes
            elsif (($origtext eq '>' || $origtext =~ /#\d/) && $self->{isTheme} == 1)
            {
                $self->{isTheme} = 2 ;
            }

            # Capture of themes
            elsif ($self->{isTheme} == 2 && $origtext ne 'in')
            {

                if ($self->{curInfo}->{genre} eq '')
                {
                   $self->{curInfo}->{genre} = $origtext;
                }
                else
                {
                    $self->{curInfo}->{genre} .= ", " . $origtext
                        if (! ($self->{curInfo}->{genre} =~ /$origtext/));
                }
                $self->{isTheme} = 1 ;
            }

	        # Capture of description
	        elsif ($self->{isDescription} == 2)
	        {
                if ($self->{curInfo}->{description} eq '')
                {
                   $self->{curInfo}->{description} = $origtext;
                }
		        else
		        {
		           $self->{curInfo}->{description} .= " ".$origtext;
		        }
            }
            
            elsif ($origtext =~ /^$self->{translations}->{product}/)
            {
                $self->{isDetails} = 2;   	
            }
            elsif ($origtext eq $self->{translations}->{end})
            {
                $self->{isDetails} = 0;
            }

            # Capture of details
            elsif ($self->{isDetails} eq 2)
            {
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

        $self->initTranslations();

        return $self;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
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

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return 'http://' . $self->baseWWWamazonUrl . '/s/ref=nb_sb_noss_1?url=search-alias=stripbooks&field-keywords=' . "$word";
    }

    sub baseWWWamazonUrl
    {
        return "www.amazon.com";
    }

    sub getName
    {
        return "Amazon (US)";
    }

    sub getAuthor
    {
        return 'Varkolak - Kerenoc';
    }

    sub getLang
    {
        return 'EN';
    }

    sub getCharset
    {
        my $self = shift;
        return "ISO-8859-15";
    }

    sub getSearchFieldsArray
    {
        # TODO: Kerenoc: check if 'isbn' needs to be first to enable EAN/Scanner search
        return ['title', 'authors', 'isbn'];
    }

    sub getEanField
    {
        return 'isbn';
    }

    sub initTranslations
    {
        my $self = shift;

        $self->{translations} = {
            publisher     => "Publisher",
            publication   => "Audible.com Release Date",
            language      => "Language:",
            isbn          => "isbn",
            dimensions    => "Product Dimensions",
            series        => "Series",
            pages         => "pages",
            by            => "by",
            product       => "(Product information|Product details)",
            details       => "Technical Details",
            additional    => "Additional Information",
            end           => "Feedback",
            sponsored     => "Sponsored",
            description   => "Description",
            author        => "Author",
            translator    => "Translator",
            artist        => "Illustrator"
        };
    }
}
1;
