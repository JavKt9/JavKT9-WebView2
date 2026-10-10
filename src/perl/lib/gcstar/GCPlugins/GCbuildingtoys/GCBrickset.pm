package GCPlugins::GCbuildingtoys::GCBrickset;

###################################################
#
#  Copyright 2005-2016 Tian
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

use XML::Simple;
use GCPlugins::GCPluginsBase;

{
    package GCPlugins::GCbuildingtoys::GCPluginBrickset;

    use base qw(GCPluginParser);
    
    my %fieldMapping = (
        setid => 'internalId',
        brickseturl => 'web',
        number => 'reference',
        name => 'name',
	usdateaddedtosah => 'released',
        theme => 'theme',
        pieces => 'nbpieces',
        imageurl => 'mainpic',
        minifigs => 'nbfigs',
        description => 'description',
    );

#Cookie:
#setsListFormat=CSV; setsPageLength=200; setsSortOrder=YearFromDesc;


    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;
        if ($tagname eq 'sets')
        {
            $self->{itemIdx}++ if $self->{parsingList};
         }
        else
        {
            $self->{currentAttr} = $fieldMapping{$tagname};
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;
		
        $self->{inside}->{$tagname}--;
        $self->{currentAttr} = '';
    }

    sub text
    {
        my ($self, $origtext) = @_;

        if ($self->{parsingList})
        {
            $self->{itemsList}[$self->{itemIdx}]->{$self->{currentAttr}} = $origtext
                if $self->{currentAttr};
            if ($self->{currentAttr} eq 'internalId')
            {
                $self->{itemsList}[$self->{itemIdx}]->{url} = 'https://brickset.com/api/v2.asmx/getSet?apiKey=UthW-nzee-P8f6&userHash=&setID='.$origtext;
            }
        }
        else
        {
            $self->{curInfo}->{$self->{currentAttr}} = $origtext
                if $self->{currentAttr};
            if ($self->{currentAttr} eq 'web')
            {
                #Store the lego ID in a fake parameter to retrieve it later to display the webpage
                $self->{curInfo}->{web} = $origtext.'?internalID='.$self->{curInfo}->{internalId};
            }
	    elsif ($self->{currentAttr} eq 'released')
	    {
		$self->{curInfo}->{$self->{currentAttr}} = GCUtils::strToTime($origtext, "%Y-%m-%d");
	    }
        }
    } 

    sub getAdditionalImages
    {
        my $self = shift;
        my $url = 'https://brickset.com/api/v2.asmx/getAdditionalImages?apiKey=UthW-nzee-P8f6&setID='.$self->{curInfo}->{internalId};
        $self->{parsingTips} = 1;
        my $xml = $self->loadPage($url, 0, 1);
        my $xs = XML::Simple->new;
        my $addImages = $xs->XMLin($xml,
                                   SuppressEmpty => '',
                                   ForceArray => 1);
	my $currentBox = $self->{curInfo}->{mainpic};
	delete $self->{curInfo}->{mainpic};
        for my $img(@{$addImages->{additionalImages}})
        {
	    if (! exists $self->{curInfo}->{mainpic})
	    {
		$self->{curInfo}->{mainpic} = $img->{imageURL}->[0];
		$img->{imageURL}->[0] = $currentBox;
	    }
	    push @{$self->{curInfo}->{images}}, $img->{imageURL};
        }
    }

    sub getSearchFieldsArray
    {
        return ['reference', 'name'];
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            reference => 1,
            name => 1,
            mainpic => 1,
            nbpieces => 1,
            theme => 1,
            released => 1
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;
        if ($self->{parsingList})
        {
        }
        else
        {
            $html =~ s|&lt;li&gt;|- |gm;
            $html =~ s|&lt;p&gt;||gm;
            $html =~ s|&lt;/p&gt;|\n|gm;
            $html =~ s|&lt;ul&gt;||gm;
            $html =~ s|&lt;/ul&gt;|\n|gm;
            $html =~ s|&lt;/li&gt;|\n|gm;
            $html =~ s|\t*||gm;
            $html =~ s|&reg;||gm;
            $html =~ s|&trade;||gm;
            $html =~ s|&#39;|'|gm;
            $html =~ s|&rsquo;|'|gm;
            $html =~ s|&amp;|&|gm;
            $html =~ s|&lt;i&gt;||gm;
            $html =~ s|&lt;/i&gt;||gm;
            $self->{curInfo}->{brand} = 'LEGO';
        }
        return $html;
    }
        
    sub getItemInfo
    {
        my $self = shift;

        $self->SUPER::getItemInfo;
        $self->getAdditionalImages;
        
        return $self->{curInfo};
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        $word =~ s/\+/ /g;
        return 'https://brickset.com/api/v2.asmx/getSets?apiKey=UthW-nzee-P8f6&userHash=&theme=&subtheme=&year=&owned=&wanted=&orderby=YearFromDESC&pageSize=200&pageNumber=&userName=&setNumber=&query='.$word;
	
        #return 'http://brickset.com/sets?query='.$word;
    }
    
    sub getItemUrl
    {
        my ($self, $url) = @_;

        if ($url)
        {
            if ($url =~ /internalID=(\d*)/)
            {
                return 'https://brickset.com/api/v2.asmx/getSet?apiKey=UthW-nzee-P8f6&userHash=&setID='.$1;
            }
        }
        else
        {
            return 'http://brickset.com/';
        }

        return $url if $url;
        return 'http://brickset.com/';
    }

    sub getName
    {
        return 'Brickset';
    }
    
    sub getAuthor
    {
        return 'Tian';
    }
    
    sub getLang
    {
        return 'EN';
    }

    sub isPreferred
    {
        return 1;
    }
}

1;
