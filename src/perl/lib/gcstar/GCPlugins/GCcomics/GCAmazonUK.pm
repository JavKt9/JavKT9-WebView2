package GCPlugins::GCcomics::GCAmazonUK;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2017-2024 Kerenoc
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

use GCPlugins::GCcomics::GCcomicsCommon;
use GCPlugins::GCstar::GCAmazonCommonBCGG;

{
    package GCPlugins::GCcomics::GCPluginAmazonUK;

    use base qw(GCPlugins::GCstar::GCPluginAmazonCommonBCGG);
    use base qw(GCPlugins::GCcomics::GCcomicsPluginsBase);

    sub baseWWWamazonUrl
    {
        return "www.amazon.co.uk";
    }

    sub getName
    {
        return "Amazon (UK)";
    }

    sub getLang
    {
        return 'EN';
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $word = $self->setSponsored($word);
        return 'https://'.$self->baseWWWamazonUrl.'/s?i=stripbooks&k='.$word.'&ref=nb_sb_noss_1&language=en_UK&url=search-alias=stripbooks';
    }
}

1;
