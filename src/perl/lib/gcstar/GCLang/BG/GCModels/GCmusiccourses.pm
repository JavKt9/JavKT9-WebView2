{
    package GCLang::BG::GCModels::GCmusiccourses;

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
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
###################################################
    
    use strict;
    use base 'Exporter';

    our @EXPORT = qw(%lang);

    our %lang = (
    
        CollectionDescription => 'Music courses collection',
        Items => {0 => 'Music course',
                  1 => 'Music course',
                  X => 'Music courses',
                  lowercase1 => 'music course',
                  lowercaseX => 'music courses'
                 },
        NewItem => 'New music course',
		
###################################################
#
#		TAGS
#      
###################################################

		Artists => "Artists",
		Artist => "Artist",
		Audio1 => "Audio #1",
		Audio2 => "Audio #2",
		Audio3 => "Audio #3",
		Audio4 => "Audio #4",
		Audio5 => "Audio #5",
		Audio6 => "Audio #6",
		Audio7 => "Audio #7",
		Audio8 => "Audio #8",
		Audio9 => "Audio #9",
		AudioMissing => "Missing audio",
        Comment => 'Comments',
		Date => 'Publication date',
        Director => 'Director',
        Directors => 'Directors',
		Doc1 => "Document #1",
		Doc2 => "Document #2",
		Doc3 => "Document #3",
		Doc4 => "Document #4",
		Doc5 => "Document #5",
		Doc6 => "Document #6",
		Doc7 => "Document #7",
		Doc8 => "Document #8",
		Doc9 => "Document #9",
		DocMissing => "Missing documentation",
		Exercise => "Exercise",
		Exercises => "Exercises",
		Format => "Format",
        Genre => 'Genre',
        Genres => 'Genres',
        Id => 'Id',
		Identifier => 'Publisher Id',
        Image => 'Front cover',
        Instrument => 'Instrument',
        Instruments => 'Instruments',
		ISBN10 => 'ISBN10',
		ISBN13 => 'ISBN13',
		Key => "Key",
		Keys => "Keys",
		LabelDVD => 'DVD Number',
		Level => "Level",
		Levels => "Levels",
		Name => "Name",
		Path => "Path",
        Performer => 'Performer',
        Performers => 'Performer',
        Publisher => 'Publisher',
        Publishers => 'Publishers',
        Seen => 'Viewed',
        Series => 'Series',
        Song => 'Song',
        Songs => 'Songs',
        SourceUrl => 'Source',
        Synopsis => 'Synopsis',
		Tab1 => "Tab #1",
		Tab2 => "Tab #2",
		Tab3 => "Tab #3",
		Tab4 => "Tab #4",
		Tab5 => "Tab #5",
		Tab6 => "Tab #6",
		Tab7 => "Tab #7",
		Tab8 => "Tab #8",
		Tab9 => "Tab #9",
		TabMissing => "Missing tabs",
		Technique => "Technique",
		Techniques => "Techniques",
		Time => 'Length',
        Title => 'Title',
		Tuning => "Tuning",
		Tunings => "Tunings",
		UPC => 'UPC',
        Url => 'Web page',
		Video1 => "Video #1",
		Video2 => "Video #2",
		Video3 => "Video #3",
		Video4 => "Video #4",
		Video5 => "Video #5",
		Video6 => "Video #6",
		Video7 => "Video #7",
		Video8 => "Video #8",
		Video9 => "Video #9",
		videoMissing => "Missing video",
		Volume => 'Volume',

###################################################
#
#		VALUES
#      
###################################################

        SeenYes => 'Viewed',
        SeenNo => 'Not viewed',

        MissingYes => 'Missing',
        MissingNo => 'Present',
		
		
###################################################
#
#		GROUPS
#      
###################################################


        Main => 'Main',
        Identification => 'Identification ',
        Details => 'Details ',
        Video => 'Video ',
        Audio => 'Audio ',
        Doc => 'Documentation ',
        Tab => 'Tablatures ',
        Review => 'Review ',

				
###################################################
#
#		FILTERS
#      
###################################################

        FilterSeenNo => '_Not Yet Viewed',
        FilterSeenYes => '_Already Viewed',

     );
}

1;
