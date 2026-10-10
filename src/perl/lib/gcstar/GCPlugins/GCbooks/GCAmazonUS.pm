package GCPlugins::GCbooks::GCAmazonUS;

###################################################
#
#  Copyright 2005-2009 Tian
#  Copyright 2016-2024 Kerenoc
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

use GCPlugins::GCbooks::GCbooksCommon;
use GCPlugins::GCstar::GCAmazonCommonBCGG;

{
    package GCPlugins::GCbooks::GCPluginAmazonUS;

    use base qw(GCPlugins::GCstar::GCPluginAmazonCommonBCGG);
    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    sub baseWWWamazonUrl
    {
        return "www.amazon.com";
    }

    sub getName
    {
        return "Amazon (US)";
    }

    sub getLang
    {
        return 'EN';
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $word = $self->setSponsored($word);
        return 'https://' . $self->baseWWWamazonUrl . '/s/ref=nb_sb_noss_1?url=search-alias=stripbooks&field-keywords=' . "$word";
    }
}

1;
