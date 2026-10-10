package GCPlugins::GCfilms::GCFilmAffinityEN;

###################################################
#
#  Copyright 2005-2007 Tian
#  Edited 2009 by FiXx
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

use GCPlugins::GCfilms::GCfilmsCommon;
use GCPlugins::GCfilms::GCFilmAffinityCommon;

{

    package GCPlugins::GCfilms::GCPluginFilmAffinityEN;

    use base qw(GCPlugins::GCfilms::GCPluginFilmAffinityCommon);

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        $self->{urlRoot} = 'http://www.filmaffinity.com/en/';
        $self->{lang} = 'en';
        $self->{patternOriginal} = qr/original title/i;
        $self->{patternDate} = qr/year/i;
        $self->{patternTime} = qr/running/i;
        $self->{patternDirector} = qr/director/i;
        $self->{patternActors} = qr/cast/i;
        $self->{patternGenre} = qr/genre/i;
        $self->{patternSynopsis} = qr/synopsis/i;
        $self->{patternSearch} = qr/^Search\s+for /;
        $self->{patternLists} = qr/Add to lists/;
                
        return $self;
    }

    sub getName
    {
        return "Film affinity (EN)";
    }

    sub getLang
    {
        return 'EN';
    }
}

1;
