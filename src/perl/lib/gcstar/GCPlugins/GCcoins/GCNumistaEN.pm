package GCPlugins::GCcoins::GCNumistaEN;

###################################################
#
#  Copyright 2005-2010 Tian
#  Copyright 2014-2021 MesBedes
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
use utf8;  # pour dire que le source est en utf8
use GCPlugins::GCcoins::GCcoinsCommon;
#use open qw(:std :utf8); # pour dire que les entrées et sorties sont par défaut en utf8

{
    package GCPlugins::GCcoins::GCPluginNumistaEN;

    use base qw(GCPlugins::GCcoins::GCPluginNumista);
    use URI::Escape;

    # getName
    sub getName
    {
        return "Numista (EN)";
    }
    sub initTranslations
    {
        my $self = shift;

        $self->{translations} = {
            Country    => "Issuer",
            Autorit    => "Autorit",
            King       => "(King|Queen)",
            Period     => "Period",
            Type       => "Type",
            Calend     => "Calendar",
            Value      => "Value",
            Currency   => "Currency",
            Metal      => "Composition",
            Weight     => "Weight",
            Diameter   => "Diameter",
            Depth      => "Thickness",
            Form       => "Shape",
            Technique  => "Technique",
            Axis       => "Orientation",
            Demon      => "Demonetized",
            Ref        => "References",
            #              TODO : au 31/07/2021, il y a une ligne Numéro en plus
            Num        => "Number",
            #              TODO : au 25/07/2020, il y a confusion avec le mot "Date" sans S dans le tableau des tirages
            #              en cas d'année unique, par exemple les commémoratives (cf rattrapage)
            Year       => "Years?",

            Commemo    => "Commemorative issue",
            Avers      => "Obverse",
            Revers     => "Reverse",
            Tranche    => "Edge",
            Atelier    => "Mint",
            Comment    => "Comments",
            Voir       => "(SeeAlso|Get this coin)",
            EndRevers  => "Manage", # zone Gestion de ma collection
            EndAvers   => "Manage", # zone Gestion de ma collection

            coin       => "Standard circulation coin",
            token      => "(Token|Utility item|Bullion)",
            medal      => "Medal",
            an_coin    => "Circulating commemorative",
            nc_coin    => "(Non-circulating coin|Collector coin)",
            pattern    => "Patterns", # pattern strike
            fantasy    => "Fantasy",

            translation => "Translation",
            engraver    => "Engraver",
            lettering   => "Lettering",
            lPeriod     => "Period",                # label used for display
            lCommemo    => "Commemorative issue",  # label used for display
            lAutorit    => "Autority",              # label used for display

            # for output
            number     => "Number",
            references => "References",
        }
    }

    sub getLang
    {
        return 'EN';
    }
}

1;
