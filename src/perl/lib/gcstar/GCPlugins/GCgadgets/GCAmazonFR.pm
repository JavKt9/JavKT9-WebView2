package GCPlugins::GCgadgets::GCAmazonFR;

###################################################
#
#  Copyright 2005-2009 Tian
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

use GCPlugins::GCbooks::GCAmazon;

{
    package GCPlugins::GCgadgets::GCPluginAmazonFR;
    
    use base qw(GCPlugins::GCbooks::GCPluginAmazon);

    sub baseWWWamazonUrl
    {
		return "www.amazon.fr";    
    }
    
    sub getName
    {
        return "Amazon (FR)";
    }
    
    sub getLang
    {
        return 'FR';
    }

    sub getEanField
    {
        return 'ean';
    }

    sub getSearchFieldsArray
    {
        return ['title', 'ean'];
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{searchType} = 'gadgets';
        
        $self->{translations} = {
            publisher     => "Editeur",
            publication   => "Audible.com Release Date",
            language      => "Langue",
            isbn          => "ISBN-13",
            dimensions    => "Dimensions du produit:",
            series        => "Collection",
            pages         => "pages",
            by            => "de",
            product       => "Informations sur le produit",
            details       => "Descriptif technique",
            additional    => "Informations compl",
            end           => "Votre avis",
            sponsored     => "Sponsorisé",
            description   => "Description",
            author        => "Auteur",
            translator    => "Traduction",
            artist        => "Illustration"
        };
    }
}

1;
