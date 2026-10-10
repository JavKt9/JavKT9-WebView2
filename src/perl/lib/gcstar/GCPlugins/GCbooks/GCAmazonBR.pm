package GCPlugins::GCbooks::GCAmazonBR;

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
    package GCPlugins::GCbooks::GCPluginAmazonBR;
    
    use base qw(GCPlugins::GCbooks::GCPluginAmazon);

    sub baseWWWamazonUrl
    {
		return "www.amazon.com.br";    
    }
    
    sub getName
    {
        return "Amazon (BR)";
    }
    
    sub getLang
    {
        return 'PT';
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{translations} = {
            publisher     => "(Editora|Edição)",
            publication   => "Data de publicação :",
            language      => "Idioma :",
            isbn          => "ISBN-13",
            dimensions    => "Dimensões do produto:",
            series        => "Coleção",
            pages         => "páginas",
            by            => "por",
            product       => "Informações do produto",
            details       => "Descrição técnica",
            additional    => "Informações complementares",
            end           => "Sua opinião",
            sponsored     => "Patrocinados",
            description   => "Descrição",
            author        => "Autor",
            translator    => "Tradutor",
            artist        => "Ilustrador"
        };
    }
}

1;
