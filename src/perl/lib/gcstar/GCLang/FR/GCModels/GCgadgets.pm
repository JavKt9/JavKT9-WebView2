{
    package GCLang::FR::GCModels::GCgadgets;

    use utf8;
###################################################
#
#  Copyright 2018 Kerenoc
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
    
        CollectionDescription => 'Collection de gadgets',
        Items => {0 => 'Gadget',
                  1 => 'Gadget',
                  X => 'Gadgets',
                  I1 => 'Un gadget',
                  D1 => 'Le gadget',
                  DX => 'Les gadgets',
                  DD1 => 'Du gadget',
                  M1 => 'Ce gadget',
                  C1 => ' gadget',
                  DA1 => 'e gadget',
                  DAX => 'e gadgets',
                  T => 's',
                  GEN => ''},
        NewItem => 'Nouveau gadget',
    
        EAN => 'EAN',
        UPC => 'UPC',
        Title => 'Nom',
        Characteristics => 'Caractéristiques',
        Description => 'Description',
        Notes => 'Notes',
        Quantity => 'Quantité',
        PurchaseDate => 'Date d\'achat',
        Price => 'Prix',
        Brand => 'Marque',
        Origin => 'Origine',
        Location => 'Emplacement',
        Image => 'Image',
        Genres => 'Genres',
        Url => 'Page web',

        General => 'Fiche',
        Details => 'Détails',

        ReadNo => 'Non lu',
        ReadYes => 'Lu',
     );
}

1;
