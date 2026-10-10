{
    package GCLang::FR::GCModels::GCpostcards;

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

        CollectionDescription => 'Collection de cartes postales',
        Items => {0 => 'Carte',
                  1 => 'Carte',
                  X => 'Cartes',
                  I1 => 'Une carte',
                  D1 => 'La carte',
                  DX => 'Les cartes',
                  DD1 => 'De la carte',
                  M1 => 'Cette carte',
                  C1 => 'e carte',
                  DA1 => 'e carte',
                  DAX => 'e cartes',
                  T => 'tes',
                  GEN => 'e'},
        NewItem => 'Nouvelle carte postale',

		General => 'Généralités',
					Flag => 'Drapeau',
					Legend => 'Légende',
					Country => 'Pays', 
					Front => 'Recto',
					Back => 'Verso',
					Type => 'Type',
                            BW => 'Noir & blanc',
                            BWColorized => 'Noir & blanc colorisée',
                            BWMultiviews => 'Noir & blanc multivues',
                            BWMultiviewsColorized => 'Noir & blanc multivues colorisée',
                            Color => 'Couleur',
                            ColorMultiviews => 'Couleur multivues',
                            BWPhoto => 'Photo noir & blanc',
                            BWColorizedPhoto => 'Photo noir & blanc colorisée',
                            BWMultiviewsPhoto => 'Photo noir& blanc multivues',
                            BWColorizedMultiviewsPhoto => 'Photo noir & blanc multivues colorisée',
                            ColorPhoto => 'Photo couleur',
                            MultiviewsColorPhoto => 'Photo couleur multivues',
                            MailArt => 'Mail art',
                            Collage => 'Collage',
                            Undefined => 'Non définie',
                            
                    Period => 'Époque',
                            Precursor => 'Précurseur',
                            Old => 'Ancienne',
                            SemiModern => 'Semi-moderne',
                            Modern => 'Moderne',
                            Contemporary => 'Contemporaine',
                            
                    Format => 'Format',
                            Horizontal => 'Horizontale',
                            Vertical => 'Verticale',
                            Triangular => 'Triangulaire',
                            Circular => 'Circulaire',
                            Oval=> 'Ovale',
                            Other => 'Autre',
                            
        Specifications => 'Caractéristiques',
                    Condition => 'État',
                        New => 'Neuf',
                        Excellent => 'Excellent',
                        VeryGood => 'Très bon',
                        Good => 'Bon',
                        Average => 'Moyen',
                        Mediocre => 'Médiocre',
                        Bad => 'Mauvais',
                        ToBeReplaced => 'Á remplacer dès que possible',
                        
                    Dimensions => 'Dimensions',
                    Numbering => 'Numérotation',
                            
                    Editor => 'Éditeur',
                    PrintedNumber => 'Tirage',
                            
                    Traveled => 'A voyagée',
                    Cancellation => 'Oblitération intéressante',
                    Photographer=> 'Photographe',
                    
                    Observations => 'Observations',
                    
        CollectionManagement => 'Gestion de la collection',
                    Owned => 'Possédée',
                    ToSearch => 'A rechercher',
                    Origin => 'Origine',
                        Shop => 'Boutique',
                        Bid => 'Enchères',
                        CartophilicEvent => 'Salon cartophile',
                        Delcampe => 'Delcampe',
                        Ebay => 'Ebay',
                        Internet => 'Internet',
                        Exchange => 'Échange',
                        Donation => 'Don',
                        Forgotten => 'Je ne sais plus',
                    OrderDate => 'Date de commande',
                    ReceiptDate => 'Date de réception',
                    PurchasePrice => 'Prix d\'achat (€) (hors frais de livraison)',
                    EstimatedPrice => 'Valeur estimée (€) (moyenne des ventes sur internet)',
                    Remarks => 'Remarques',
        Metadata => 'Métadonnées',
                    Location => 'Localité - Endroit',
                    Region => 'Région',
                    Word01 => 'Mot clé 01',
                    Word02 => 'Mot clé 02',
                    Word03 => 'Mot clé 03',
                    Word04 => 'Mot clé 04',
                    
        Storage => 'Rangement',
                    Building => 'Bâtiment',
                    Room => 'Pièce',
                    Furniture => 'Meuble',
                    Level => 'Niveau',
                    Container => 'Contenant',
                    Index => 'Index,'
       
     );
}

1;
