package GCPlugins::GCfilms::GCAmazonFR;

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
    package GCPlugins::GCfilms::GCPluginAmazonFR;

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

        $self->{suffix} = 'fr';

        $self->initTranslations;
        
        return $self;
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{translations} = {
            audio         => "Audio",
            description   => "Description du produit",
            site          => "Amazon.fr",
            distribution  => "Distribution",
            minutes       => "minutes",
            in            => "dans",
            actors        => "Acteurs",
            director      => "R.alisateurs?",
            date          => "Date de sortie",
            duration      => "Dur.e",
            subtitles     => "Sous-titres",             
            video         => "Format",         
            sponsored     => "Sponsoris",
            stars         => "[^ ]*toiles",
            genre         => "Genre",
            age           => "Class.",
            ratedG        => "(Tout public|Tous publics)",
            ratedPG       => "Accord des parents",     # to be checked
            ratedPG13     => "Accord des parents 13",  # to be checked
            ratedR        => "Classé X",               # to be checked
        };
    }
    
    sub getName
    {
        return "Amazon (FR)";
    }

    sub getLang
    {
        return 'FR';
    }
}

1;
