package GCPlugins::GCgadgets::GCUPCitemDB;

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

{
    package GCPlugins::GCgadgets::GCPluginUPCitemDB;
    
    use base qw(GCPluginParser);

    use JSON qw( decode_json );
 
    sub getName
    {
        return "UPC item DB";
    }
    
    sub getEanField
    {
        return 'ean';
    }

    sub getLang
    {
        return 'EN';
    }

    sub getSearchFieldsArray
    {
    	my $self = shift;
    	
        return ['ean'];
    }

    sub getCharset
    {
        my $self = shift;
        
        return "ISO-8859-2";
        return "UTF-8";
    }

    sub getAuthor
    {
        return 'Kerenoc';
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return 'https://api.upcitemdb.com/prod/trial/lookup?upc='.$word;
    }

    sub getItemUrl
    {
        my ($self, $word) = @_;

        return 'local://'.$word;
    }

    #initialize
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title => 1,
            ean => 1,
        };

        $self->{result} = '';
        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{parsingEnded} = 0;
        $self->{insideResults} = 0;

        #IF we;re parsing a list, populate it
        if ($self->{parsingList})
        {
            #Here we have decoded json
            $self->{result} = decode_json($html);
            for my $item (@{$self->{result}->{items}})
            {
            	$self->{itemIdx}++;
            	$self->{itemsList}[$self->{itemIdx}]->{title} = $item->{title};
            	$self->{itemsList}[$self->{itemIdx}]->{ean} = $item->{ean};
            	$self->{itemsList}[$self->{itemIdx}]->{url} = $self->{itemIdx};
            }
        }
        else
        {
        	# JSON already parsed
        	return if (! $html =~ m|local://(\d+)|);
        	$html =~ s|.*//||;
        	my $info = $self->{result}->{items}[$html];
            $self->{curInfo}->{ean} = $info->{ean};
            $self->{curInfo}->{title} = $info->{title};
            $self->{curInfo}->{brand} = $info->{brand};
            $self->{curInfo}->{description} = $info->{description};
            $self->{curInfo}->{dimensions} = $info->{dimension};
            $self->{curInfo}->{cover} = $info->{images}[0] if ($info->{images});       	
            $self->{curInfo}->{web} = 'https://www.upcitemdb.com/upc/'.$info->{ean};
        }
    }
}

1;
