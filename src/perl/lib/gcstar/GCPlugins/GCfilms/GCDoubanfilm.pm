package GCPlugins::GCfilms::GCDoubanfilm;

###################################################
#
#  Copyright 2005-2010 Bai Wensimi
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

use GCPlugins::GCfilms::GCfilmsCommon;

{
    package GCPlugins::GCfilms::GCPluginDoubanfilm;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    use LWP::Simple qw($ua);
    use JSON qw( decode_json );

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title    => 1,
			director => 1,
            date     => 1,
            country   => 1,
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        my $json = decode_json($html);
        
        if ($self->{parsingList})
        {
            foreach my $item ( @{$json->{subjects}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{title} = $item->{title};
                $self->{itemsList}[$self->{itemIdx}]->{url} = "https://api.douban.com/v2/movie/subject/".$item->{id};             
                $self->{itemsList}[$self->{itemIdx}]->{date} = $item->{year};   
                $self->{itemsList}[$self->{itemIdx}]->{director} = $item->{directors}[0]->{name};                  
            }
        } 
        else 
        {
            $self->{curInfo}->{webPage} = $json->{alt};
            $self->{curInfo}->{image} = $json->{images}->{large};
            $self->{curInfo}->{original} = $json->{original_title};
            $self->{curInfo}->{title} = $json->{title};
            $self->{curInfo}->{date} = $json->{year};
            $self->{curInfo}->{genres} = '';
            foreach my $actor ( @{$json->{casts}} )
            {
                   push @{$self->{curInfo}->{actors}}, [$actor->{name}];
            }
            foreach my $genre ( @{$json->{genres}} )
            {
                   push @{$self->{curInfo}->{genre}}, [$genre];
            }
            $self->{curInfo}->{country} = $json->{countries}[0];
        }

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
	if ($self->{searchField} eq 'imdb')
        {
           return "http://api.douban.com/movie/subject/imdb/" .$word;
        }
        else
        {
           return "http://api.douban.com/v2/movie/search?q=" .$word;
        }
    }
    
    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
    }	
    
    sub changeUrl
    {
        my ($self, $url) = @_;
        # Make sure the url is for the api, not the main movie page
        return $self->getItemUrl($url);
    }

    sub getNumberPasses
    {
        return 1;
    }

    sub getName
    {
        return "豆瓣 - Douban";
    }
    

    sub testURL
    {
        my ($self, $url) = @_;
        $url =~ /[\?&]lid=([0-9]+)*/;
        my $id = $1;
        return ($id == $self->siteLanguageCode());
    }

    sub getReturnedFields
    {
        my $self = shift;

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            director => 1,
            country  => 1,
        };

    }
    
    sub getAuthor
    {
        return 'BW';
    }
    
    sub getLang
    {
        return 'ZH';
    }
    
    sub isPreferred
    {
        return 1;
    }
    
    sub getSearchCharset
    {
        my $self = shift;
        
        # Need urls to be double character encoded
        return "UTF-8";
    }
	    sub getSearchFieldsArray
    {
        return ['imdb', 'title'];
    }

    sub getCharset
    {
        my $self = shift;
    
        return "UTF-8";
    }

    sub decodeEntitiesWanted
    {
        return 0;
    } 

    sub siteLanguage
    {
        my $self = shift;
        
        return 'ZH';
    }
    
}

1;
