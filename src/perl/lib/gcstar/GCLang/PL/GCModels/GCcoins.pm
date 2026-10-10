{
    package GCLang::PL::GCModels::GCcoins;

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
    
        CollectionDescription => 'Kolekcja numizmatyczna',
        Items => sub {
          my $number = shift;
          return 'Numizmat' if $number eq '1';
          return 'Numizmaty' if $number =~ /(?<!1)[2-4]$/;
          return 'Numizmatów';
        },
        NewItem => 'Nowy numizmat',

        Name => 'Nazwa',
        Country => 'Kraj',
        Year => 'Rok',
        Calendar => 'Calendar',
        Currency => 'Waluta',
        Value => 'Nominał',
        Picture => 'Zdjęcie',
        Diameter => 'Średnica',
        Metal => 'Metal',
        Weight => 'Weight (g)',
        Depth => 'Depth (mm)',
        Edge => 'Krawędź',
        Edge1 => 'Krawędź 1',
        Edge2 => 'Krawędź 2',
        Edge3 => 'Krawędź 3',
        Edge4 => 'Krawędź 4',
        Head => 'Awers',
        Tail => 'Rewers',
        Front => 'Front',
        Back => 'Back',
        Comments => 'Komentarze',
        History => 'Historia',
        Website => 'Strona internetowa',
        Estimate => 'Wycena',
        References => 'Rekomendacje',
        Type => 'Typ',
        Coin => 'Moneta',
        Banknote => 'Banknot',

        "Anniversary coin" => 'Anniversary coin',
        "Non circulating coin" => 'Non circulating coin',
        Token => 'Token',
        
        Main => 'Główne',
        Description => 'Opis',
        Other => 'Inne informacje',
        Pictures => 'Zdjęcia',
    
        Condition => 'Stan (PCGS)',
        Grade1  => 'BS-1',
        Grade2  => 'FR-2',
        Grade3  => 'AG-3',
        Grade4  => 'G-4',
        Grade6  => 'G-6',
        Grade8  => 'VG-8',
        Grade10 => 'VG-10',
        Grade12 => 'F-12',
        Grade15 => 'F-15',
        Grade20 => 'VF-20',
        Grade25 => 'VF-25',
        Grade30 => 'VF-30',
        Grade35 => 'VF-35',
        Grade40 => 'XF-40',
        Grade45 => 'XF-45',
        Grade50 => 'AU-50',
        Grade53 => 'AU-53',
        Grade55 => 'AU-55',
        Grade58 => 'AU-58',
        Grade60 => 'MS-60',
        Grade61 => 'MS-61',
        Grade62 => 'MS-62',
        Grade63 => 'MS-63',
        Grade64 => 'MS-64',
        Grade65 => 'MS-65',
        Grade66 => 'MS-66',
        Grade67 => 'MS-67',
        Grade68 => 'MS-68',
        Grade69 => 'MS-69',
        Grade70 => 'MS-70',

        Axis => 'Axis',
        Medal => 'Medal',
        Monetary => 'Monetary (180º)',
        Turn => 'Turn',
        "Years of coinage" => 'Years of coinage',
        Quantity => 'Quantity',
        Mint => 'Mint',
        "Mint mark" => 'Mint mark',
        Mintmaster => 'Mintmaster',
        "Mintmaster mark" => 'Mintmaster mark',
        City => 'City',
        "City letter" => 'City letter',
        Series => 'Series',
        "Edge type" => 'Edge type',
        Catalogue1 => 'Catalogue1',
        Number1 => 'Number1',
        Catalogue2 => 'Catalogue2',
        Number2 => 'Number2',
        Number => 'Number',
        Form => 'Form',
        Buyed => 'Bought',
        Found => 'Found',
        Bring => 'Bring',
        Gift => 'Gift',
        Location => 'Location',
        Price => 'Price',
        
     );
}

1;
