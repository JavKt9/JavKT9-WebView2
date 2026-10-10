package GCPlugins::GCTVepisodes::GCthemoviedbES;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2010-2016 Zombiepig
#  Copyright 2020-2021 Kerenoc
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

use GCPlugins::GCTVepisodes::GCTVepisodesCommon;

{

    package GCPlugins::GCTVepisodes::GCPluginThemoviedbES;

    use base qw(GCPlugins::GCTVepisodes::GCPluginThemoviedb);

    sub getName
    {
        return "The Movie DB (ES)";
    }

    sub siteLanguage
    {
        my $self = shift;

        return 'es-ES';
    }

    sub getLang
    {
        return 'ES';
    }

}

1;
