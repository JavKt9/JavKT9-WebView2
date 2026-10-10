package GCPlugins::GCfilms::GCAmazonDE;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2019 Kerenoc
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

use GCPlugins::GCfilms::GCfilmsAmazonCommon;

{
    package GCPlugins::GCfilms::GCPluginAmazonDE;

    use base qw(GCPlugins::GCfilms::GCfilmsAmazonPluginsBase);
    
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title => 1,
            date => 1,
            director => 0,
            actors => 1,
        };

        $self->{suffix} = 'de';

        $self->initTranslations;
        
        return $self;
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{translations} = {
            audio         => "Sprache",
            description   => "Produktbeschreibungen",
            site          => "Amazon.de",
            distribution  => "In der Hauptrolle",
            minutes       => "Minuten",
            in            => "in",
            actors        => "Darsteller",
            director      => "Regisseur.e.",
            date          => "(Erscheinungstermin|Produktionsjahr)",
            duration      => "(Spieldauer|Laufzeit)",
            subtitles     => "Untertitel",
            video         => "Format",         
            sponsored     => "Gesponsert",
            stars         => "von 5 Sternen",
            genre         => "Genre",
            age           => "Alterseinstufung",
            ratedG        => "Freigegeben ohne Altersbesch",
            ratedPG       => "FSK 6",   # to be checked
            ratedPG13     => "FSK 12",  # to be checked
            ratedR        => "FSK 18",  # to be checked
        };
    }
    
    sub getName
    {
        return "Amazon (DE)";
    }

    sub getLang
    {
        return 'DE';
    }
}

1;
