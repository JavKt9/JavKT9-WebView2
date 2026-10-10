package GCPlugins::GCTVseries::GCBeyazPerde;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2010-2016 Zombiepig
#  Copyright 2020-2024 Kerenoc
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

use GCPlugins::GCTVseries::GCTVseriesCommon;
use GCPlugins::GCfilms::GCBeyazPerde;

{
    package GCPlugins::GCTVseries::GCPluginBeyazPerde;

    use base 'GCPlugins::GCfilms::GCPluginBeyazPerde';
    use base 'GCPlugins::GCTVseries::GCTVseriesPluginsBase';

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        GCPlugins::GCTVseries::GCTVseriesPluginsBase::initFieldNames($self);

        return $self;
    }

    sub getName
    {
        return "Beyaz Perde (TR)";
    }

    sub siteLanguage
    {
        my $self = shift;

        return 'fr-FR';
    }

    sub getLang
    {
        return 'TR';
    }

    sub getNumberPasses
    {
        my $self = shift;

        # two pass to choose a serie then a season
        # initial implementation : one pass (code shared with film plugin)
        return 2;
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1)
        {
            $self->{hasField} = {
                title      => 1,
                firstaired => 1
            };
        }
        elsif ($self->{pass} == 2)
        {
            $self->{hasField} = {
                title      => 1,
                season     => 1,
                firstaired => 1
            };
        }
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return "https://www.beyazperde.com/aramak/series/?q=$word";
    }
}

1;
