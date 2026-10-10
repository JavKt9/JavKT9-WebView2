package GCPlugins::GCfilms::GCAmazonUK;

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
    package GCPlugins::GCfilms::GCPluginAmazonUK;
    
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

        $self->{suffix} = 'co.uk';

        $self->initTranslations;
        
        return $self;
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{translations} = {
            audio         => "(Language|Dubbed)",
            description   => "Product description",
            site          => "Amazon.co.uk",
            distribution  => "Starring",
            minutes       => "minutes",
            in            => "in",
            actors        => "Actors",
            director      => "Directors?",
            date          => "Release date",
            duration      => "(Running time|Run time)",
            subtitles     => "Subtitles",             
            video         => "Format",         
            sponsored     => "Sponsored",
            stars         => "out of 5 stars",
            genre         => "Genre",
            age           => "Rated",
            ratedG        => "(Universal|Suitable for all)",
            ratedPG       => "Parental Guidance",     # to be checked
            ratedPG13     => "Parental Guidance 13",
            ratedR        => "Restricted", 
        };
    }
    
    sub getName
    {
        return "Amazon (UK)";
    }

    sub getLang
    {
        return 'EN';
    }
}

1;
