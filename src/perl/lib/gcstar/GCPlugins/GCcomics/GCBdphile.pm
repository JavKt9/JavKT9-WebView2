package GCPlugins::GCcomics::GCBdphile;

###################################################
#
#  Copyright 2005-2007 Jonas
#  Copyright 2016-2019 Kerenoc
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

use GCPlugins::GCcomics::GCcomicsCommon;
use GCPlugins::GCbooks::GCBdphile;

{
    # Replace SiteTemplate with your exporter name
    # It must be the same name as the one used for file and main package name
    package GCPlugins::GCcomics::GCPluginBdphile;

    use base 'GCPlugins::GCbooks::GCPluginBdphile';

    # new
    # Constructor.
    # Returns object reference.
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
    	
        $self->{searchType} = 'comics';
        
        $self->{seriesField}      = 'series';
        $self->{coverField}       = 'image';
        $self->{illustratorField} = 'illustrator';
        $self->{colouristField}   = 'colourist';
        $self->{lettererField}    = 'letterer';
        $self->{publicationField} = 'publishdate';
        $self->{authorField}      = 'writer';
        $self->{descriptionField} = 'synopsis';

        # This member should be initialized as a reference
        # to a hash. Each keys is a field that could be
        # in results with value 1 or 0 if it is returned
        # or not. For the list of keys, check the model file
        # (.gcm) and search for tags <field> in
        # /collection/options/fields/results
        $self->{hasField} = {
            series => 1,
            title => 1,
            writer => 0,
            illustrator => 0,
            publisher => 0,
            publication => 1,
            format => 0,
            edition => 0,
            web => 0,
            description => 0,
            isbn => 0,
        };

        $self->{lastPass} = 0;

        $self->{searchField} = ($self->getSearchFieldsArray())[0][0]
             if (! $self->{searchField});
    }
}

1;
