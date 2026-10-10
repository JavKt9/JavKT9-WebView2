{
    package GCLang::FR::GCModels::GCbuildingtoys;

    use utf8;
###################################################
#
#  Copyright 2005-2010 Christian Jodar
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
    use base 'Exporter';

    our @EXPORT = qw(%lang);

    our %lang = (
    
        CollectionDescription => 'Collection de jouets de construction',
        Items => {0 => 'Ensemble',
                  1 => 'Ensemble',
                  X => 'Ensembles',
                  I1 => 'Un ensemble',
                  D1 => 'L\'ensemble',
                  DX => 'Les ensembles',
                  DD1 => 'De l\'ensemble',
                  M1 => 'Cet ensemble',
                  C1 => ' ensemble',
                  DA1 => '\'ensemble',
                  DAX => '\'ensembles',
                  T => 's',
                  GEN => ''},
        NewItem => 'Nouvel ensemble',
    
        SetDescription => 'Description',
            Id => 'Identifiant',
            Reference => 'Référence',
            Name => 'Nom',
            MainPic => 'Image principale',
            Brand => 'Marque',
            Theme => 'Thème',
            Released => 'Date de sortie',            
            NumberPieces => 'Nombre de pièces',
            NumberMiniFigs => 'Nombre de figurines',
            Description => 'Description',
            Url => 'Page web',

        Details => 'Détails',
            Box => 'Boîte',
            Manual => 'Notice',
            Sealed => 'Scellée',
            NbOwned => 'Exemplaires',
            Instructions => 'Fichier notice',
            Comments => 'Commentaires',
            PaidPrice => 'Prix',
            EstimatedPrice => 'Estimation',

        Pictures => 'Images',
            Images => 'Images',
            
        Minifigures => 'Figurines',
            MinifiguresPics => 'Images des figurines',
      );
}

1;
