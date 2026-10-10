package GCPlugins::GCgames::GCAmazonQC;

###################################################
#
#  Copyright 2005-2009 Tian
#  Copyright 2017-2022 Kerenoc
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

use GCPlugins::GCgames::GCgamesCommon;
use GCPlugins::GCstar::GCAmazonCommonBCGG;

{
    package GCPlugins::GCgames::GCPluginAmazonQC;

    use base qw(GCPlugins::GCstar::GCPluginAmazonCommonBCGG);
    use base qw(GCPlugins::GCgames::GCgamesPluginsBase);

    sub baseWWWamazonUrl
    {
        return "www.amazon.ca";
    }

    sub getName
    {
        return "Amazon (QC)";
    }

    sub getLang
    {
        return 'FR';
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        
        # load home page first to set cookies
        my $html = $self->loadPage('https://www.amazon.ca');        
        $word = $self->setSponsored($word);
        return 'https://' . $self->baseWWWamazonUrl . '/s?k='.$word.'&i=videogames&__mk_fr_CA=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=2CJV095JLIFQ1&sprefix='.$word.'%2Cvideogames%2C144&ref=nb_sb_noss_2';
   }
}

1;
