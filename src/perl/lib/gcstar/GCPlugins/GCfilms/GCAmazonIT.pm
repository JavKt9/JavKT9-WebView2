package GCPlugins::GCfilms::GCAmazonIT;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2025 Kerenoc
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
    package GCPlugins::GCfilms::GCPluginAmazonIT;

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

        $self->{suffix} = 'it';

        $self->initTranslations;

        return $self;
    }

    sub initTranslations
    {
        my $self = shift;

        $self->{translations} = {
            Audio         => "Audio",
            Description   => "Descrizione ",
            Site          => "Amazon.it",
            Distribution  => "Distribution",
            Minutes       => "minuti",
            In            => "dans",
            Actors        => "Attor",
            Director      => "Regista",
            Country       => "Paese",
            Date          => "Data d'uscita",
            Time          => "Tempo",
            Subtitles     => "Sottotitoli",
            Video         => "Formato",
            Sponsored     => "Sponsorizzato",
            Stars         => "stelle",
            Genre         => "Genere",
            Age           => "Età consigliata",
            RatedG        => "Film per tutti",
            RatedPG       => "Presenza dei genitori",  # to be translated
            RatedPG13     => "Accord des parents 13",  # to be translated
            RatedR        => "Vietato ai minori di 18 anni",
        };
    }

    sub getName
    {
        return "Amazon (IT)";
    }

    sub getLang
    {
        return 'IT';
    }
}

1;
