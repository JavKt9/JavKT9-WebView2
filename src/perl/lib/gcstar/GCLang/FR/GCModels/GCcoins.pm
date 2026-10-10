{
    package GCLang::FR::GCModels::GCcoins;

    use utf8;
###################################################
#
#  Copyright 2005-2010 Christian Jodar, Mesbedes
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
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################

    use strict;
    use base 'Exporter';

    our @EXPORT = qw(%lang);

    our %lang = (

        CollectionDescription => 'Collection numismatique',
        Items => {0 => 'Pièce',
                  1 => 'Pièce',
                  X => 'Pièces',
                  I1 => 'Une pièce',
                  D1 => 'La pièce',
                  DX => 'Les pièces',
                  DD1 => 'De la pièce',
                  M1 => 'Cette pièce',
                  C1 => 'e pièce',
                  DA1 => 'e pièce',
                  DAX => 'e pièces',
                  T => 'tes',
                  GEN => 'e'},
        NewItem => 'Nouvelle pièce',
        Name => 'Nom de la pièce',
        Country => 'Pays',
        Year => 'Année',
        Calendar => 'Calendrier',
        Currency => 'Devise',
        Value => 'Valeur',
        Picture => 'Image principale',
        Diameter => 'Diamètre (mm)',
        Metal => 'Métal',
        Weight => 'Poids (g)',
        Depth => 'Epaisseur (mm)',
        Edge => 'Tranche',
        Edge1 => 'Tranche 1',
        Edge2 => 'Tranche 2',
        Edge3 => 'Tranche 3',
        Edge4 => 'Tranche 4',
        Head => 'Avers',
        Tail => 'Revers',
        Front => 'Avers',
        Back => 'Revers',
        Comments => 'Commentaire',
        History => 'Historique',
        Website => 'Site web',
        Estimate => 'Estimation (€)',
        References => 'Références',
        Type => 'Type',
        Coin => 'Pièce',
        Banknote => 'Billet',

        "Anniversary coin" => 'Commémorative',
        "Non circulating coin" => 'Pièce non circulante',
        Token => 'Jeton',

        Main => 'Principal',
        Description => 'Description',
        Other => 'Détails',
        Pictures => 'Pictures',

        Condition => 'Etat de conservation',
        Grade1  => 'AB-1',
        Grade2  => 'AB-2',
        Grade3  => 'AB-3',
        Grade4  => 'B-4',
        Grade6  => 'B-6',
        Grade8  => 'B-8',
        Grade10 => 'B-10',
        Grade12 => 'B-12',
        Grade15 => 'B-15',
        Grade20 => 'TB-20',
        Grade25 => 'TB-25',
        Grade30 => 'TB-30',
        Grade35 => 'TB-35',
        Grade40 => 'TTB-40',
        Grade45 => 'TTB-45',
        Grade50 => 'TTB-50',
        Grade53 => 'TTB-53',
        Grade55 => 'SUP-55',
        Grade58 => 'SUP-58',
        Grade60 => 'SPL-60',
        Grade61 => 'SPL-61',
        Grade62 => 'SPL-62',
        Grade63 => 'SPL-63',
        Grade64 => 'SPL-64',
        Grade65 => 'SPL-65',
        Grade66 => 'SPL-66',
        Grade67 => 'SPL-67',
        Grade68 => 'SPL-68',
        Grade69 => 'SPL-69',
        Grade70 => 'FDC-70',

        Axis => 'Axe',
        Medal => 'Médaille',
        Monetary => 'Monnaie (180º)',
        Turn => 'Décalée',
        "Years of coinage" => 'Années fabrication',
        Quantity => 'Quantité fabriquée',
        Mint => 'Atelier',
        "Mint mark" => 'Marque atelier',
        Mintmaster => 'Graveur',
        "Mintmaster mark" => 'Symbole graveur',
        City => 'Ville',
        "City letter" => 'Lettre',
        Series => 'Série',
        "Edge type" => 'Type de tranche',
        Catalogue1 => '1er Сatalogue',
        Number1 => '1ère Référence',
        Catalogue2 => '2ème Сatalogue',
        Number2 => '2ème Référence',
        Number => 'Numéro',
        Form => 'Forme',
        Buyed => 'Achetée',
        Found => 'Trouvée',
        Bring => 'Echangée',
        Gift => 'Donnée',
        Location => 'Emplacement',
        Price => 'Prix',
     );
}

1;
