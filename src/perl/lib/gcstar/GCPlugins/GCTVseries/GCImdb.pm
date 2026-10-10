package GCPlugins::GCTseries::GCImdb;

###################################################
#
#  Copyright 2022 Kerenoc
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
use GCPlugins::GCfilms::GCImdb;

{
    package GCPlugins::GCTVseries::GCPluginImdb;

    use base 'GCPlugins::GCfilms::GCPluginImdb';

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();

        bless ($self, $class);

        $self->initParams;

        return $self;
    }

    sub initParams
    {
        my $self = shift;

        $self->{pluginType} = 'series';

        $self->{pass} = 1;

        $self->{searchField} = ($self->getSearchFieldsArray())[0][0]
             if (! $self->{searchField});
    }

    sub getNumberPasses
    {
        return 2;
    }

    sub getSearchFieldsArray
    {
        return ['series'];
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1)
        {
            $self->{hasField} = {
                title => 1,
                firstaired => 1,
            };
        }
        else
        {
            $self->{hasField} = {
                series => 1,
                season => 1,
                firstaired => 1,
            };
        }
    }
}

1;
