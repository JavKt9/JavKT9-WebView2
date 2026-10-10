{
    package GCLang::ZH_CN::GCModels::GCpostcards;

    use utf8;
###################################################
#
#  Copyright 2005-2021 Lao-collectibles
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

        CollectionDescription => 'Postcards collection',
        Items => {0 => 'Postcard',
                  1 => 'Postcard',
                  X => 'Postcards',
                  I1 => 'one postcard',
                  D1 => ' the postcard',
                  DX => 'the postcards',
                  DD1 => 'from the postcard ',
                  M1 => 'this postcard',
                  #C1 => '',
                  #DA1 => '',
                  #DAX => '',
                  #T => '',
                  #GEN => ''
        },
        NewItem => 'New postcard',
        
        General => 'General',
                    Flag => 'Country flag',
                    Legend => 'Legend',
                    Country => 'Country',
                    Front => 'Front postcard',
                    Back => 'Back postcard',
                    Type => 'Type',
                            BW => 'Black & white',
                            BWColorized => 'Black & white colorized',
                            BWMultiviews => 'Black & white multiviews',
                            BWMultiviewsColorized => 'Black & white multiviews colorized',
                            Color => 'Color',
                            ColorMultiviews => 'Color multiviews',
                            BWPhoto => 'Black & white photo card',
                            BWColorizedPhoto => 'Black & white colorized photo',
                            BWMultiviewsPhoto => 'Black & white multiviews photo',
                            BWColorizedMultiviewsPhoto => 'Black & white colorized multiviews photo',
                            ColorPhoto => 'Color photo',
                            MultiviewsColorPhoto => 'Multiviews color photo',
                            MailArt => 'Mail Art',
                            Collage => 'Collage',
                            Undefined => 'Not defined',
                            
                    Period => 'Period',
                            Precursor => 'Precursor',
                            Old => 'Old',
                            SemiModern => 'Semi-modern',
                            Modern => 'Modern',
                            Contemporary => 'Contemporary',
                            
                    Format => 'Format',
                            Horizontal => 'Horizontal',
                            Vertical => 'Vertical',
                            Triangular => 'Triangular',
                            Circular => 'Circular',
                            Oval=> 'Oval',
                            Other => 'Other',
                            
         "Specifications" => 'Specifications',
                    Condition => 'Condition',
                        New => 'New',
                        Excellent => 'Excellent',
                        VeryGood => 'Very good',
                        Good => 'Good',
                        Average => 'Average',
                        Mediocre => 'Mediocre',
                        Bad => 'Bad condition',
                        ToBeReplaced => 'To be replaced as soon as possible',
                        
                    Dimensions => 'Dimensions',
                    Numbering => 'Numbering',
                    Editor => 'Editor',
                    PrintedNumber => 'Number of printed cards',
                    Traveled => 'Has traveled',
                    Cancellation => 'Interesting cancellation',
                    Photographer => 'Photographer',
                    Observations => 'Observations',
                    
         CollectionManagement => 'Collection Management',
                    Owned => 'Owned',
                    ToSearch => 'Search for it',
                    Origin => 'Origin',
                        Shop => 'Shop',
                        Bid => 'Bid',
                        CartophilicEvent => 'Cartophilic event',
                        Delcampe => 'Delcampe',
                        Ebay => 'Ebay',
                        Internet => 'Internet',
                        Exchange => 'Exchange',
                        Donation => 'Donation',
                        Forgotten => 'I don\'t remember',
                    OrderDate => 'Order date',
                    ReceiptDate => 'Receipt date',
                    PurchasePrice => 'Purchase price (£/$) (excluding delivery charges)',
                    EstimatedPrice => 'Estimated value (£/$) (average of Internet sales)',
                    Remarks => 'Remarks',
         Metadata => 'Metadata',
                    Location => 'City - Place',
                    Region => 'Region',
                    Word01 => 'Keyword 01',
                    Word02 => 'Keyword 02',
                    Word03 => 'Keyword 03',
                    Word04 => 'Keyword 04',

     );
}

1;
