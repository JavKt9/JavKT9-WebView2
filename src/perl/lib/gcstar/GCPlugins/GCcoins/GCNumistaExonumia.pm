package GCPlugins::GCcoins::GCNumistaExonumia;

###################################################
#
#  Copyright 2005-2010 Tian
#  Copyright 2014-2021 MesBedes
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
use utf8;  # pour dire que le source est en utf8
use GCPlugins::GCcoins::GCcoinsCommon;
#use open qw(:std :utf8); # pour dire que les entrées et sorties sont par défaut en utf8

{
    package GCPlugins::GCcoins::GCPluginNumistaExonumia;

    use base qw(GCPlugins::GCcoins::GCPluginNumista);
    use URI::Escape;

    sub getSearchType
    {
        return "exonumia";
    }

    # getName
    sub getName
    {
        return "Exonumia (FR)";
    }
}

1;
