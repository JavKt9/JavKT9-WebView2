package GCPlugins::GCgames::GCgamesAmazonCommon;

###################################################
#
#  Copyright 2005-2010 Tian
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

use GCPlugins::GCgames::GCgamesCommon;
use GCPlugins::GCstar::GCAmazonCommon;

{
    package GCPlugins::GCgames::GCgamesAmazonPluginsBase;

    use base ('GCPlugins::GCgames::GCgamesPluginsBase', 'GCPlugins::GCstar::GCPluginAmazonCommon');
    
    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
	
        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'a' && $attr->{class} =~ m/a-link-normal a-text-normal/)
            {
            	if ($self->{isSponsored} eq 1)
            	{ 
            		$self->{isSponsored} = 2;
            		return;
            	}
            	elsif ($self->{isSponsored} eq 2)
            	{
            		$self->{isSponsored} = 0;
            	}
            	return if ($attr->{href} =~ m,/gp/slredirect,);
                $self->{itemIdx}++;
                $attr->{href} = 'http://www.amazon.'.$self->{suffix}.$attr->{href}
                    if ($attr->{href} =~/^\//);
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
                
                #$self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                #$self->{itemsList}[$self->{itemIdx}]->{name} = $attr->{title};
                $self->{isGame} = 1;
                $self->{isName} = 1;
                $self->{isPlatform} = 1;
            }
            elsif ( ($tagname eq 'h1') && ($attr->{class} eq 'headerblocktitle') && ($self->{isGame} ne 2) )
            {
                $self->{isGame} = 1 ;
                $self->{isUrl} = 1 ;
            }
            elsif ( ($tagname eq 'td') && ($attr->{class} eq 'imageColumn') && ($self->{isGame} ne 2) )
            {
                $self->{isGame} = 1 ;
                $self->{isUrl} = 1 ;
            }
            elsif ( ($tagname eq 'span') && ($attr->{class} =~ m/a-size-medium a-color-base/) && ($self->{isGame} eq 1) )
            {
                $self->{isName} = 1 ;
            }
            elsif ( ($tagname eq 'a') && ($attr->{class}=~ m/a-link-normal a-text-bold/) && ($self->{isPlatform}) )
            {
                $self->{isPlatform} = 2;
            }
            elsif ( ($tagname eq 'span') && ($attr->{class} eq 'avail') )
            {
                $self->{isGame} = 0 ;
            }
            elsif ( ($tagname eq 'div') && ($attr->{class} eq 'usedPrice') )
            {
                $self->{isGame} = 0 ;
            }
            elsif ( ($tagname eq 'input') && ($attr->{name} eq 'sdp-sai-asin') )
            {
                $self->{isCodeEAN} = 1 ;
            }
            elsif ( ($tagname eq 'a') && ($self->{isCodeEAN}))
            {
                $self->{SaveUrl} = $attr->{href};
                $self->{isCodeEAN} = 0 ;
            }
        }
        elsif ($self->{parsingTips})
        {
        }
        else
        {
            if ($tagname eq 'span' && $attr->{id} eq 'productTitle')
            {
                $self->{isName} = 1;
            }
            elsif ($tagname eq 'img' && $attr->{id} eq 'landingImage')
            {
                $self->{curInfo}->{boxpic} = $attr->{src};
            }
            elsif ( ($tagname eq 'meta') && ($attr->{name} eq 'keywords') )
            {
                my ($name, $editor, @genre) = split(/,/,$attr->{content});
                $self->{curInfo}->{name} = $name;
                $self->{curInfo}->{editor} = $editor;
                my $element;
                foreach $element (@genre)
                {
                   $element =~ s/^\s+//;
                   if ( !($element =~ m/console/i) && !($element =~ m/cartouche/i) && !($element =~ m/video games/i) && !($element =~ /([0-9])/))
                   {
                      $self->{curInfo}->{genre} .= $element;
                      $self->{curInfo}->{genre} .= ",";
                   }
                }

                # Sur Amazon.com et amazon.co.jp je n ai pas reussi a trouver un critere pertinent pour la recherche des genres
                if (($self->{suffix} eq 'com') || ($self->{suffix} eq 'co.jp') )
                {
                   $self->{curInfo}->{genre} = '';
                }

                if ($self->{ean} ne '')
                {
                   $self->{curInfo}->{ean} = $self->{ean};
                }
            }
            elsif ($tagname eq 'tpfdateparution')
            {
                $self->{isDate} = 1 ;
            }
            elsif ($tagname eq 'tpfplateforme')
            {
                $self->{isPlatform} = 1 ;
            }
            elsif ($tagname eq 'tpfcouverture')
            {
                $self->{curInfo}->{boxpic} = $self->extractImage($attr);
            }
            elsif ($tagname eq 'tpfscreenshot1')
            {
                $self->{curInfo}->{screenshot1} = $self->extractImage($attr);
            }
            elsif ($tagname eq 'tpfscreenshot2')
            {
                $self->{curInfo}->{screenshot2} = $self->extractImage($attr);
            }
            elsif (($tagname eq 'tpfdescription') )
            {
                $self->{isDesc} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'feature-bullets')
            {
                $self->{isDesc} = 1;	
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ m/addOnItem/)
            {
                $self->{isDesc} = 0;                
            }
            elsif ( ($tagname eq 'div') && ($attr->{class} eq 'bucket') && ($self->{isDesc} eq 1))
            {
                $self->{isDesc} = 0;
            }
            elsif ($tagname eq 'i' && $attr->{class} =~ m/a-icon-star/ && $self->{isRating} eq 0)
            {
                $self->{isRating} = 1;
            }
            elsif ($attr->{id} eq 'bylineInfo')
            {
                $self->{isEditor} = 1;
            }
            elsif ($tagname eq 'script' || $tagname eq 'style')
            { 
            	$self->{isScriptOrStyle} = 1;
            }
        }
    }

    sub end
    {
	    my ($self, $tagname) = @_;
		
        $self->{inside}->{$tagname}--;
        if (($tagname eq 'tpfdescription') )
        {
            $self->{isDesc} = 0;
        }
        elsif ($tagname eq 'script' || $tagname eq 'style')
        {
        	$self->{isScriptOrStyle} = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^\s*//;
        $origtext =~ s/\s*$//;
        $origtext =~ s/\n*$//s;
        
        if ($self->{parsingList})
        {
            if ($self->{isPlatform} eq 2 && ! $self->{isSponsored})
            {
                $self->{itemsList}[$self->{itemIdx}]->{platform} = $self->transformPlatform($origtext);
                $self->{isPlatform} = 0; # platform found
            }
            elsif ($self->{isName} && ! $self->{isSponsored})
            {
                $self->{itemsList}[$self->{itemIdx}]->{name} = $origtext;
                $self->{isName} = 0;
            }
            elsif ($origtext eq $self->{translations}->{sponsored})           
            {
            	$self->{isSponsored} = 1;
            }
        }
        elsif ($self->{parsingTips})
        {
        }
        else
        {
            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en fin de chaine
            $origtext =~ s/\s+$//;
            $origtext =~ s/\n//g;
            return if ($origtext eq '');
            return if ($self->{isScriptOrStyle});

            if ($self->{isName})
            {
               $self->{curInfo}->{name} = $origtext; 
               $self->{isName} = 0;
            }
            elsif ($self->{isDate} && $origtext =~ m/\d/)
            {
                $origtext = GCUtils::strToTime($origtext,"%e %B %Y", $self->getLang());  # FR DE
                $origtext = GCUtils::strToTime($origtext,"%Y/%m/%d", $self->getLang());  # JA
                $origtext = GCUtils::strToTime($origtext,"%e %b %Y", $self->getLang());  # UK
                $origtext = GCUtils::strToTime($origtext,"%b %e %Y", $self->getLang());  # CA
                                                
                $self->{curInfo}->{released} = $origtext if (! $self->{curInfo}->{released});
                $self->{isDate} = 0;
            }
            elsif ($self->{isPlatform}) 
            {
                $self->{curInfo}->{platform} = $self->transformPlatform($origtext);
                $self->{isPlatform} = 0;
            }
            elsif ($self->{isDesc})
            {
            	if ($origtext =~ m/^(Frequently bought|Sponsored products|Customers who|Customer question|Customer reviews|What other items)/i)
            	{
            		$self->{isDesc} = 0;
            	}
            	else
            	{
                    $self->{curInfo}->{description} .= $origtext ."\n" 
                        if $origtext ne 'View larger' && $origtext ne 'Read more' && $origtext ne 'See more';
            	}
            }
            elsif ($self->{isEditor})
            {
            	$origtext =~ s/^by\s*//;
                $self->{curInfo}->{editor} = $origtext;
                $self->{isEditor} = 0;
            }
            elsif ($self->{isRating} eq 1)
            {
                $origtext =~ s/\s.*//;
                $origtext =~ s/,/./;
                $self->{curInfo}->{ratingpress} = $origtext;
                $self->{isRating} = 2;
            }
            elsif ($origtext =~ m/^(Product information|Product description)/)
            { 
            	$self->{isDesc} = 1;
            }
        }
    } 

    sub transformPlatform
    {
        my ($self, $platform) = @_;
        
        $platform =~ s/^([\w ]*)\W{2}.*$/$1/ms;
        $platform =~ s/SONY //i;
        if ($platform =~ m/windows/i)
        {
           $platform = 'PC';
        }
        return $platform;
    }

    sub getTipsUrl
    {
        my $self = shift;
        
        return;
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            name => 1,
            platform => 1
        };
        
        return $self;
    }
    
    sub preProcess
    {
        my ($self, $html) = @_;

        $self->initVariables;

        if ($self->{parsingList})
        {
            $html =~ s/.*s-search-results"/<span /s;
            $html =~ s/<div class="s-result-list-placeholder.*//s;
        }
        else
        {
        	$html =~ s/.*<div id="titleLayer"/<div /s;
            $html =~ s/Product [dD]escription/><tpfdescription>/;
            $html =~ s/About the product/><tpfdescription>/;
            # Le descriptif pouvant contenir des balises html je le repere maintenant
            my $found = index($html,"<tpfdescription>");
            if ( $found >= 0 )
            {
               my $html2 = substr($html, $found,length($html)- $found);
               #my $foundEnd = index($html,'<style type="text/css">', $found);
               my $foundEnd = index($html,'<div id="sponsoredProduct', $found);
               my $foundEnd1 = index($html,'<div id="sponsoredProduct', $found);
               my $foundProduct = index($html,'<div id="product-details', $found);
               #$html2 = substr($html, $found, $foundEnd-$found) if ($foundEnd > 0);

               $html2 =~ s|</li>||gi;
               $html2 =~ s|<p>|\n\n|gi;
               $html2 =~ s|</p>||gi;
               $html2 =~ s|<ul>|\n|gi;
               $html2 =~ s|</ul>|\n\n|gi;
               $html2 =~ s|<strong>||gi;
               $html2 =~ s|</strong>||gi;
               $html2 =~ s|<em>||gi;
               $html2 =~ s|</em>||gi;
               $html2 =~ s|\n\s*\n[\s\n]*|\n\n|g;

               $html = substr($html, 0, $found) . $html2."<\/tpfdescription>";
            }

            $html =~ s/Release [dD]ate[^<]*</<tpfdateparution></gi;
            $html =~ s/<b>Platform:<\/b> &nbsp;</<tpfplateforme><\/tpfplateforme></gi;
            $html =~ s/<b>Platform:<\/b>/<tpfplateforme><\/tpfplateforme>/gi;
            $html =~ s/\s*Platform\s*:\s*/<tpfplateforme><\/tpfplateforme>/gi;
            $html =~ s/registerImage\("original_image",/<\/script><tpfcouverture src=/gi;
            $html =~ s/registerImage\("alt_image_1",/<\/script><tpfscreenshot1 src=/gi;
            $html =~ s/registerImage\("alt_image_2",/<\/script><tpfscreenshot2 src=/gi;
            $html =~ s|<b>||gi;
            $html =~ s|</b>||gi;
            $html =~ s|<i>||gi;
            $html =~ s|</i>||gi;
            $html =~ s|<li>|\n|gi;
            $html =~ s|<br>|\n|gi;
            $html =~ s|<br />|\n|gi;
            $html =~ s|\x{92}|'|gi;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#156;|oe|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
        }
        return $html;
    }

    sub initTranslations
    {
        my $self = shift;

        $self->{translations} = {
            publisher     => "Publisher",
            publication   => "Release date",
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

    sub initVariables
    {
        my $self = shift;
        
        $self->{isCodeEAN} = 0;
        $self->{SaveUrl} = '';
        $self->{isName} = 0;
        $self->{isGame} = 0;
        $self->{isUrl} = 0;
        $self->{isPlatform} = 0;
        $self->{isDate} = 0;
        $self->{isDesc} = 0;
        $self->{isRating} = 0;
        $self->{isSponsored} = 0;
        $self->{isScript} = 0;
        $self->{ean} = '';
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return 'http://www.amazon.' . $self->{suffix} . '/gp/search/?redirect=true&search-alias=videogames&keywords=' .$word;
    }
    
    sub getItemUrl
    {
		my ($self, $url) = @_;
		
		return $url if $url;
        return 'http://www.amazon.' . $self->{suffix};
    }

    sub getName
    {
        return 'Amazon';
    }
    
    sub getAuthor
    {
        return 'TPF';
    }
    
    sub getLang
    {
        return 'FR';
    }

    sub getCharset
    {
        my $self = shift;
    
        return "ISO-8859-1";
    }

    sub getSearchFieldsArray
    {
        return ['ean', 'name'];
    }
    
    sub getEanField
    {
        return 'ean';
    } 
}

1;
