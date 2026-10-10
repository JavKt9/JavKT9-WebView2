package GCPlugins::GCboardgames::GCtrictrac;

###################################################
#
#  Copyright 2005-2016 Christian Jodar
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

use GCPlugins::GCboardgames::GCboardgamesCommon;

{
    package GCPlugins::GCboardgames::GCPlugintrictrac;

    use base qw(GCPlugins::GCboardgames::GCboardgamesPluginsBase);
 
    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
	
        $self->{inside}->{$tagname}++;

        if ($self->{parsingEnded})
        {
            return;
        }
        

        if ($self->{parsingList})
        {
            # Parse the search results here

            # Check if we are currently parsing an item page, not a search results page (ie - exact match has taken us straight to the page)
            # Do this by checking if there is a heading on the page
            if (($tagname eq "font") && ($attr->{style} =~ /FONT-SIZE: 20px/))
            {
                # Stop parsing results, switch to item parsing
                $self->{parsingEnded} = 1;
                $self->{itemIdx} = 0;
                $self->{itemsList}[0]->{url} = $self->{loadedUrl};
            }
            elsif (($tagname eq "div") && ($attr->{class} eq "item"))
            {
                $self->{isBoardgame} = 1;
            }
            elsif (($tagname eq "a") && ($attr->{itemprop} eq "name") && ($self->{isBoardgame} eq 1))
            {
                # Add to search results
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} =  $attr->{href}."/details";
                $self->{itemsList}[$self->{itemIdx}]->{name} = $attr->{title};
            }
        }
        else
        {
            # Parse the items page here. Basically we do this by seaching for tags which match certain criteria, then preparing to grab
            # the text inside these tags

            if (($tagname eq "img") && ($attr->{id} eq "img-game"))
            {
                $self->{curInfo}->{name} = $attr->{alt};
                $self->{curInfo}->{boxpic} = $attr->{src};
                $self->{curInfo}->{boxpic} =~ s/https/http/g;
            }
            elsif (($tagname eq "i") && ($attr->{class} =~ m/ion-clipboard/))
            {
                $self->{isInfo} = 1;
            }
            elsif ($tagname eq "h6")
            {
                $self->{isInfo2} = 1;
            }
            elsif (($tagname eq "a") && ($self->{insideDesigner} eq 1))
            {
                # Append text (and trailing ,) to existing designer field
                $self->{curInfo}->{designedby} .= $attr->{title} .", ";
            }
            elsif (($tagname eq "a") && ($self->{insideIllustrator} eq 1))
            {
                # Append text (and trailing ,) to existing designer field
                $self->{curInfo}->{illustratedby} .= $attr->{title} .", ";
            }
            elsif (($tagname eq "a") && ($self->{insidePublishers} eq 1))
            {
                # Append text (and trailing ,) to existing designer field
                $self->{curInfo}->{publishedby} .= $attr->{title} .", ";
            }
            elsif (($tagname eq "a") && ($attr->{class} =~ m/thumbnail/))
            {
                $self->{insidePictures} = 1;
            }
            elsif (($tagname eq "div") && ($self->{isInfo}))
            {
                $self->{isInfo} = 0;
            }
            elsif (($tagname eq "i") && ($attr->{class} =~ /ion-speakerphone/))
            {
                $self->{insideDescription} = 1;
            }
            elsif ($tagname eq 'p' && $self->{insideDescription} eq 1 && $attr->{class} eq 'readmore')
            {
                $self->{insideDescription} = 2;
            }
            elsif (($tagname eq 'a') && ($attr->{class} =~ m/radius green/))
            { 
                # Extensions
		my $page = $self->loadPage($attr->{href});
                $page = substr($page, index($page,"Ses extensions") );
                $page = substr($page, 0, index($page, 'class="section"'));
	        $page =~ s/&#039;/'/g;
                $page =~ s/&amp;/&/g;
                my $end = 0;
                my $searched = "";
                my $found = index($page,'<div class="item"');
		while ($found > 0)
		{
		    $end = index($page,">",$found);
                    $searched = substr($page, $found, index($page,">",$found));
                    if (!($searched =~ /background/))
                    {
                        $found = index($page,'<a class="header"', $found + 1);
                        $searched = substr($page, $found, index($page,">",$found));
                        $searched =~ /href="(.*?)\s+title="(.*?)">/s ;
                        $self->{curInfo}->{expandedby} .= $2 .',';
                    }
                    $found = index($page,'<div class="item"', $found+1);
		}
            }   
            elsif (($tagname eq "img") && ($self->{insidePictures} eq 1))
            {
                   return if ($self->{indexPicture} > 4);
                   my $pictureName = "photo".$self->{indexPicture};
                   $self->{curInfo}->{$pictureName} = $attr->{src};
                   $self->{indexPicture}++;
            } 
            elsif ($tagname eq 'i' && $attr->{class} =~ m/ion-ios-people-outline/)
            {
                $self->{insidePlayers} = 1;
            }         
            elsif ($tagname eq 'i' && $attr->{class} =~ m/ion-ios-timer-outline/)
            {
                $self->{insidePlayingTime} = 1;
            }         
            elsif ($tagname eq 'i' && $attr->{class} =~ m/ion-ios-body-outline/)
            {
                $self->{insideAges} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;	
        $self->{inside}->{$tagname}--;
        if ($tagname eq "tr")
        {
            # Use regex to strip final , off end of line
            $self->{curInfo}->{designedby} =~ s/(, )$//;
            $self->{curInfo}->{illustratedby} =~ s/(, )$//;
            $self->{curInfo}->{publishedby} =~ s/(, )$//;
            $self->{insideDesigner} = 0;
            $self->{insideIllustrator} = 0;
            $self->{insidePublishers} = 0;
            $self->{insideReleased} = 0;
        }
        elsif (($tagname eq "div") && ($self->{isBoardgame} eq 1))
        {
            $self->{isBoardgame} = 0;
        }
        elsif (($tagname eq "p") && ($self->{insideDescription} eq 2))
        {
            $self->{insideDescription} = 0;
        }
                       
 
    }

    sub text
    {
        my ($self, $origtext) = @_;

        return if (length($origtext) < 2);
        
        $origtext =~ s/&#34;/"/g;
        $origtext =~ s/&#179;/3/g;
        $origtext =~ s/\n//g;
        $origtext =~ s/^\s\{2,//;
        #French accents substitution
        #$origtext =~ s/&agrave;/é/;
        #$origtext =~ s/&eacute;/è/;
        
        return if ($self->{parsingEnded});
        
        if (!$self->{parsingList})
        {
            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en fin de chaine
            $origtext =~ s/\s+$//;

            return if ($origtext eq '');
            # fetching information from page 
            if ($self->{insidePlayers} eq 1)
            {
                $self->{curInfo}->{players} = $origtext;
                $self->{insidePlayers} = 0;
            }
            elsif ($self->{insideAges} eq 1)
            {
                $self->{curInfo}->{suggestedage} = $origtext;
                $self->{insideAges} = 0;
            }
            elsif ($self->{insidePlayingTime} eq 1)
            {
                $self->{curInfo}->{playingtime} = $origtext;
                $self->{insidePlayingTime} = 0;
            }   
            elsif ($self->{insideReleased} eq 1)
            {
                $self->{curInfo}->{released} = $origtext;
            }                        
            elsif (($self->{isInfo} eq 1 ) && !($origtext eq "et") && !($origtext eq ","))
            {
               if ($origtext =~ /Auteurs/)
               {
                  $self->{insideDesigner} = 1;
               }
               elsif ($origtext =~ /Illustrateurs/)
               {
                  $self->{insideIllustrator} = 1;
               }
               elsif ($origtext =~ /diteurs/)
               {
                  $self->{insidePublishers} = 1;
               }
               elsif ($origtext =~ m/e de publication/)
               {
                  $self->{insideReleased} = 1;
               }
            }
            elsif ($self->{insideDescription} eq 2)
            {
                $self->{curInfo}->{description} .= $origtext." ";
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
            name => 1,
            released => 1,
        };


        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;
        
        $self->{parsingEnded} = 0;
        $self->{isBoardgame} = 0;
        $self->{isDate} = 0;
        $self->{isInfo} = 0;
        $self->{isInfo2} = 0;
        $self->{insideDesigner} = 0;
        $self->{insideIllustrator} = 0;
        $self->{insidePublishers} = 0;
        $self->{insidePlayers} = 0;
        $self->{insideAges} = 0;
        $self->{insidePlayingTime} = 0;
        $self->{insideDescription} = 0;
        $self->{insidePictures} = 0;
        $self->{curName} = undef;
        $self->{curUrl} = undef;
        $self->{indexPicture} = 1;
         
        $html =~ s/"&#34;/'"/g;
        $html =~ s/&#34;"/"'/g;
        $html =~ s|</a></b><br>|</a><br>|;

        $html =~ s|\x{92}|'|gi;
        $html =~ s|&#146;|'|gi;
        $html =~ s|&#149;|*|gi;
        $html =~ s|&#133;|...|gi;
        $html =~ s|\x{85}|...|gi;
        $html =~ s|\x{8C}|OE|gi;
        $html =~ s|\x{9C}|oe|gi;

        return $html;
    }

    sub getSearchUrl
    {
    	my ($self, $word) = @_;
	  
        # Url returned below is the for the search page, where $word is replaced by the search  
        return "https://www.trictrac.net/recherche?search=$word";
	    return "https://www.trictrac.net/recherche?type=boardgames&page=1&limit=32&display=default&search=$word";
    }
    
    sub getItemUrl
    {
        my ($self, $url) = @_;
		
        return $url if (($url =~ /^http:/) || ($url =~ /^https:/));
        if ($url =~ /^\//)
        {
            return "http://trictrac.net".$url;
        }
        else
        {
            return "http://trictrac.net/".$url;
        }
    }

    sub getName
    {
        return "Tric Trac";
    }
    
    sub getAuthor
    {
        return 'Florent - Kerenoc';
    }
    
    sub getLang
    {
        return 'FR';
    }
    
    
}

1;
