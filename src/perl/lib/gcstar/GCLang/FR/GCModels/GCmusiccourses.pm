{
    package GCLang::FR::GCModels::GCmusiccourses;

    use utf8;
###################################################
#
#  Copyright 2012 Nicolas Lesage
#
#  This file can be used as part of GCstar.
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
    
        CollectionDescription => 'Collection de cours musicaux',
        Items => {0 => 'Cours musical',
                  1 => 'Cours musical',
                  X => 'Cours musicaux',
                  I1 => 'Un cours musical',
                  D1 => 'Le cours musical',
                  DX => 'Les cours musicaux',
                  DD1 => 'Du cours musical',
                  M1 => 'Ce cours musical',
                  C1 => ' cours musical',
                  DA1 => 'e cours musical',
                  DAX => 'e cours musicaux'},
        NewItem => 'Nouveau cours musical',
		
###################################################
#
#		TAGS
#      
###################################################

		Artists => "Artistes",
		Artist => "Artiste",
		Audio1 => "Audio n°1",
		Audio2 => "Audio n°2",
		Audio3 => "Audio n°3",
		Audio4 => "Audio n°4",
		Audio5 => "Audio n°5",
		Audio6 => "Audio n°6",
		Audio7 => "Audio n°7",
		Audio8 => "Audio n°8",
		Audio9 => "Audio n°9",
		AudioMissing => "Audio manquante",
        Comment => 'Commentaires',
		Date => 'Date de sortie',
        Director => 'Réalisateur',
        Directors => 'Réalisateurs',
		Doc1 => "Document n°1",
		Doc2 => "Document n°2",
		Doc3 => "Document n°3",
		Doc4 => "Document n°4",
		Doc5 => "Document n°5",
		Doc6 => "Document n°6",
		Doc7 => "Document n°7",
		Doc8 => "Document n°8",
		Doc9 => "Document n°9",
		DocMissing => "Documentation manquante",
		Exercise => "Exercice",
		Exercises => "Exercices",
		Format => "Format",
        Genre => 'Genre',
        Genres => 'Genres',
        Id => 'Id',
		Identifier => 'Id Editeur',
        Image => 'Couverture',
        Instrument => 'Instrument',
        Instruments => 'Instruments',
		ISBN10 => 'ISBN10',
		ISBN13 => 'ISBN13',
		Key => "Tonalité",
		Keys => "Tonalités",
		LabelDVD => 'N° DVD',
		Level => "Niveau",
		Levels => "Niveaux",
		Name => "Désignation",
		Path => "Chemin",
        Performer => 'Instructeur',
        Performers => 'Instructeurs',
        Publisher => 'Editeur',
        Publishers => 'Editeurs',
        Seen => 'Film déjà vu',
        Series => 'Série',
        Song => 'Chanson',
        Songs => 'Chansons',
        SourceUrl => 'Source',
        Synopsis => 'Synopsis',
		Tab1 => "Tablature n°1",
		Tab2 => "Tablature n°2",
		Tab3 => "Tablature n°3",
		Tab4 => "Tablature n°4",
		Tab5 => "Tablature n°5",
		Tab6 => "Tablature n°6",
		Tab7 => "Tablature n°7",
		Tab8 => "Tablature n°8",
		Tab9 => "Tablature n°9",
		TabMissing => "Tablatures manquantes",
		Technique => "Technique",
		Techniques => "Techniques",
		Time => 'Durée',
        Title => 'Titre',
		Tuning => "Accordage",
		Tunings => "Accordages",
		UPC => 'UPC',
        Url => 'Page web',
		Video1 => "Vidéo n°1",
		Video2 => "Vidéo n°2",
		Video3 => "Vidéo n°3",
		Video4 => "Vidéo n°4",
		Video5 => "Vidéo n°5",
		Video6 => "Vidéo n°6",
		Video7 => "Vidéo n°7",
		Video8 => "Vidéo n°8",
		Video9 => "Vidéo n°9",
		videoMissing => "Vidéo manquante",
		Volume => 'Volume',

###################################################
#
#		VALUES
#      
###################################################

        SeenYes => 'Vu',
        SeenNo => 'Non vu',

        MissingYes => 'Absent',
        MissingNo => 'Présent',
		
		
###################################################
#
#		GROUPS
#      
###################################################


        Main => 'Principaux éléments',
        Identification => 'Identification ',
        Details => 'Détails ',
        Video => 'Vidéo ',
        Audio => 'Audio ',
        Doc => 'Documentation ',
        Tab => 'Tablatures ',
        Review => 'Revue ',

				
###################################################
#
#		FILTERS
#      
###################################################

        FilterSeenNo => 'Films _non vus',
        FilterSeenYes => 'Films _déjà vus',

     );
}

1;
