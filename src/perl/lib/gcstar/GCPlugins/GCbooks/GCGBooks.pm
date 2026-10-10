package GCPlugins::GCbooks::GCGBooks;

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
use utf8;

#Simple Google Books API plugin -  2016 by MW
#PREQUISITES: LWP::Simple (Should be in most Perl distributions)
#             JSON (should be installed in cpan or your OS package)

use GCPlugins::GCbooks::GCbooksCommon;

my $JSONResultsStructure = "";

{
    package GCPlugins::GCbooks::GCPluginGBooks;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);
    use JSON qw( decode_json );
    use Encode;
    use URI::Escape;
    
    
    #starts with HTML tag starting. We don't want it in GBooks
    sub start
    {
                #print "start\n";
    }

    #starts at end of HTML tag. We don't want it in GBooks, it's JSON, not HTML
    sub end
    {
                #print "end\n";
    }

    #Here should be all fields filled. In JSON, we will use another routine.
    sub text
    {
     
    }

    #initialize
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title => 1,
            authors => 1,
            publication => 0,
            format => 0,
            edition => 1,
        };

        $JSONResultsStructure="";

        return $self;
    }

    #It has access to the full downloaded content. It is executed before 
    # processing tags. We will hook json parsing here and save it in 
    #this object.
    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{parsingEnded} = 0;
        $self->{insideResults} = 0;

        #Here we have decoded json
        $JSONResultsStructure = decode_json($html);
        #IF we;re parsing a list, populate it
        if ($self->{parsingList})
        {
                        for (@{$JSONResultsStructure->{items}})
                        {
                                if (defined $_->{volumeInfo})
                                {
                                        $self->{itemIdx}++;
                                        
                                        if (defined $_->{volumeInfo}->{subtitle})
                                        {
                                                $self->{itemsList}[$self->{itemIdx}]->{title}=$_->{volumeInfo}->{title}." ".$_->{volumeInfo}->{subtitle};
                                        }
                                        else
                                        {
                                                $self->{itemsList}[$self->{itemIdx}]->{title}=$_->{volumeInfo}->{title};
                                        }
                                        
                                        if (defined $_->{volumeInfo}->{authors})
                                        {
                                                my $a=0;        
                                                my $authors1="";
                                                while (defined $_->{volumeInfo}->{authors}[$a])
                                                {
                                                        $authors1 = $authors1 . ", " .$_->{volumeInfo}->{authors}[$a];
                                                        $a++;
                                                }
                                                substr($authors1,0,2)=""; #todo optimize.
                                                $self->{itemsList}[$self->{itemIdx}]->{authors}=$authors1;
                                        }

                                        $self->{itemsList}[$self->{itemIdx}]->{edition}=$_->{volumeInfo}->{publishedDate};
                                #        $self->{itemsList}[$self->{itemIdx}]->{url}=$_->{volumeInfo}->{infoLink};
                                
                                        #temporary introduce JSON of the book as URL to get it in the future.
                                        $self->{itemsList}[$self->{itemIdx}]->{url}="https://www.googleapis.com/books/v1/volumes/".$_->{id};

                                }
                        }
                }
                else
                {
                        #we've landed here with a nice JSON with single entry of the 
                        #book but with no author info. Let's parse it.
                        $_=$JSONResultsStructure;
                        
                        if (defined $_->{volumeInfo})
                        {
                                
                                if (defined $_->{volumeInfo}->{subtitle}) #title-subtitle
                                {
                                        $self->{curInfo}->{title}=$_->{volumeInfo}->{title}." ".$_->{volumeInfo}->{subtitle};
                                }
                                else
                                {
                                        $self->{curInfo}->{title}=$_->{volumeInfo}->{title}; #title
                                }
                                $self->{curInfo}->{web}=$_->{volumeInfo}->{previewLink}; #url
                                if (defined $_->{volumeInfo}->{authors}) #authors
                                {
                                        my $a=0;        
                                        my $authors1="";
                                        while (defined $_->{volumeInfo}->{authors}[$a])
                                        {
                                                $authors1 = $authors1 . ", " .$_->{volumeInfo}->{authors}[$a];
                                                $a++;
                                        }
                                        substr($authors1,0,2)=""; #todo optimize.
                                        $self->{curInfo}->{authors}=$authors1;
                                }
                                
                                if (defined $_->{volumeInfo}->{publishedDate}) #year
                                {
                                    my ($year, $month, $day) = split m/-/, $_->{volumeInfo}->{publishedDate};
                                    $self->{curInfo}->{publication} = "01/01/$year";
                                    $self->{curInfo}->{publication} = "$day/$month/$year" if ($day && $month)
                                }
                                
                                if (defined $_->{volumeInfo}->{imageLinks}->{medium})
                                {
                                    $self->{curInfo}->{cover} = $_->{volumeInfo}->{imageLinks}->{medium};
                                }
                                
                                if (defined $_->{volumeInfo}->{language}) #language
                                {
                                        $self->{curInfo}->{language}=uc($_->{volumeInfo}->{language});
                                }
                                
                                if (defined $_->{volumeInfo}->{pageCount}) #page count
                                {
                                        $self->{curInfo}->{pages}=uc($_->{volumeInfo}->{pageCount});
                                }
                                
                                my $i=0;
                                while (defined $_->{volumeInfo}->{industryIdentifiers}[$i]) #isbn
                                {                                
                                        if ($_->{volumeInfo}->{industryIdentifiers}[$i]->{type} eq "ISBN_10")
                                        {
                                                $self->{curInfo}->{isbn}=uc($_->{volumeInfo}->{industryIdentifiers}[$i]->{identifier});
                                                last;
                                        }         
                                        if ($_->{volumeInfo}->{industryIdentifiers}[$i]->{type} eq "ISBN_13")
                                        {
                                                $self->{curInfo}->{isbn}=uc($_->{volumeInfo}->{industryIdentifiers}[$i]->{identifier});
                                        }         
                                        $i++;
                                }
                                
                                if (defined $_->{volumeInfo}->{publisher}) #publisher
                                {
                                        $self->{curInfo}->{publisher}=$_->{volumeInfo}->{publisher};
                                }
                                
                                if (defined $_->{volumeInfo}->{authors} )
                                {
                                        #decode authors
                                    my $a=0;        
                                    my $authors1="";
                                    while (defined $_->{volumeInfo}->{authors}[$a])
                                    {
                                            $authors1 = $authors1 . ", " .$_->{volumeInfo}->{authors}[$a];
                                            $a++;
                                    }
                                    substr($authors1,0,2)=""; #todo optimize.
                                    $self->{curInfo}->{authors}=$authors1;
                                }
                                
                                if (defined $_->{volumeInfo}->{categories}) #genre
                                {
                                        my $a = 0;
                                        my $genre = "";
                                        while (defined $_->{volumeInfo}->{categories}[$a])
                                        {
                                                $genre = $genre . ", " .$_->{volumeInfo}->{categories}[$a];
                                                $a++;
                                        }
                                        $genre =~ s/^, //;
                                        $self->{curInfo}->{genre} = $genre;
                                }
                                #The only thing left is series. This is not present in any 
                                #JSON. It has to be carefully extracted from HTML.
                                my $htm2 = $self->loadPage($self->{curInfo}->{web}, 0, 0);
                                $htm2 =~ m|q\=bibliogroup:%22([^&]*)%22.*|;
                                my $ser = Encode::decode('utf8',uri_unescape($1));
                                $ser =~ s/\+/ /g; #TODO - how about diacritized characters here?
                                $self->{curInfo}->{serie}=$ser;
                        }
                }
        return $html;
    }

    #GetSearchURL
    #Returns the URL of search page. Page is loaded and preprocessed.
    sub getSearchUrl
    {
        my ($self, $word) = @_;
        my $what;
        if ($self->{searchField} eq 'isbn')
          {
            $what = "isbn:";
          }
        else
          {
            $what = "intitle:";
          }
        return "https://www.googleapis.com/books/v1/volumes?q=".$what.$word."&maxResults=40";
    }

    #Returns valid url for item from url got from other sources
    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url if $url;
        return 'http://books.google.com'
    }

    sub getName
    {
        return "Google Books";
    }

    #Should be 8859-2, or diacritized characters will appear as question marks
    sub getCharset
    {
        my $self = shift;
        #return "UTF-8";
        return "ISO-8859-2";
    }

    sub getAuthor
    {
        return 'MW';
    }

    sub getLang
    {
        return 'EN';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }

}

1;
