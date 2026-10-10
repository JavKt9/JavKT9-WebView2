{
    package GCLang::SR::GCModels::GCbuildingtoys;

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
    
        CollectionDescription => 'Building toys collection',
        Items => {0 => 'Sets',
                  1 => 'Set',
                  X => 'Sets',
                  lowercase1 => 'set',
                  lowercaseX => 'sets'
                  },
        NewItem => 'New set',
    
        SetDescription => 'Set description',
            Id => 'Id',
            Reference => 'Reference',
            Name => 'Name',
            MainPic => 'Main picture',
            Brand => 'Brand',
            Theme => 'Theme',
            Released => 'Release Date',            
            NumberPieces => 'Number of pieces',
            NumberMiniFigs => 'Number of minifigures',
            Description => 'Description',
            Url => 'Web page',

        Details => 'Details',
            Box => 'Box',
            Sealed => 'Sealed',
            Manual => 'Instructions manual',
            NbOwned => 'Number owned',
            Instructions => 'Electronic instructions',
            Comments => 'Comments',
            PaidPrice => 'Price paid',
            EstimatedPrice => 'Current estimate',

        Pictures => 'Pictures',
            Images => 'Images',
            
        Minifigures => 'Minifigures',
            MinifiguresPics => 'Pictures of minifigures',
      );
}

1;
