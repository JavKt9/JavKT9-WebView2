package GCPlugins::GCbooks::GCFnacFR;

###################################################
#
#  Copyright 2005-2006 Tian
#  Copyright 2015-2026 Kerenoc
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

use GCPlugins::GCbooks::GCFnacCommon;

{
    package GCPlugins::GCbooks::GCPluginFnacES;

    use base qw(GCPlugins::GCbooks::GCPluginFnacCommon);
    
    sub initTranslations
    {
    	my $self = shift;
    	
    	$self->{rootURL} = "https://www.fnac.es";
    	
    	$self->{translations} = {
            publisher  => "Editor",
            format  => "Formato",
            serie  => "Collection",
            publication  => "Lanzamiento",
            page => "páginas",
            translator => "Traducción",
            artist => "Ilustración",
            authors => "(Autor|Sc.nario)",
        };
        $self->{categorie} = '2';
    }

    sub getName
    {
        return "Fnac (ES)";
    }

    sub getLang
    {
        return 'ES';
    }
}

1;
