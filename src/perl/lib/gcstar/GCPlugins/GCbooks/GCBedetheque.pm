package GCPlugins::GCbooks::GCBedetheque;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
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
use GCPlugins::GCcomics::GCBedetheque;

{

    package GCPlugins::GCbooks::GCPluginBedetheque;

    use base qw(GCPlugins::GCcomics::GCPluginBedetheque);
    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    sub getSearchFieldsArray
    {
        return ['serie', 'authors', 'title'];
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless( $self, $class );

        $self->{ua}->default_header('Referer' => 'https://www.bedetheque.com');

        GCPlugins::GCbooks::GCbooksPluginsBase::initFieldNames($self);  

        $self->{hasField} = {
            serie => 1,
            title  => 1,
            volume => 1,
          };

        $self->{last_cover}       = "";
        $self->{site_internal_id} = "";
        $self->{serie}            = "";
        $self->{synopsis}         = "";
        $self->{current_field}    = "";

        return $self;
    }
}

1;
