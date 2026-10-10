package GCPlugins::GCfilms::GCFilmAffinityES;

###################################################
#
#  Copyright 2005-2007 Tian
#  Edited 2009 by FiXx
#  Copyright 2016-2018 Kerenoc
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

    package GCPlugins::GCfilms::GCPluginFilmAffinityES;

    use base qw(GCPlugins::GCfilms::GCPluginFilmAffinityCommon);

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            director => 1,
            actors   => 1,
        };
        
        $self->{urlRoot} = 'http://www.filmaffinity.com/es/';
        $self->{lang} = 'es';
        $self->{patternOriginal} = qr/tulo original/i;
        $self->{patternDate} = qr/^año$/i;
        $self->{patternTime} = qr/^durac/i;
        $self->{patternDirector} = qr/^direc/i;
        $self->{patternActors} = qr/^reparto/i;
        $self->{patternGenre} = qr/g.*nero/i;
        $self->{patternSynopsis} = qr/sinopsis/i;
        $self->{patternSearch} = qr/^Búsqueda\s+de /;
        $self->{patternLists} = qr/Añadir a listas/;

        return $self;
    }

    sub getName
    {
        return "Film affinity (ES)";
    }

    sub getAuthor
    {
        return 'Tian - PIN - FiXx - Kerenoc';
    }

    sub getLang
    {
        return 'ES';
    }
}

1;
