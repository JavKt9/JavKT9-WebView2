package GCPlugins::GCfilms::GCMovieMeter;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2007 Petr Gajdusek (Pajdus) <gajdusek.petr@centrum.cz>
#  Copyright 2007 Mattias de Hollander (MaTiZ) <mdehollander@gmail.com>
#  Copyright 2016-2018 Kerenoc
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

use GCPlugins::GCfilms::GCfilmsCommon;

{
    # Replace SiteTemplate with your exporter name
    # It must be the same name as the one used for file and main package name
    package GCPlugins::GCfilms::GCPluginMovieMeter;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);

    # getSearchUrl
    # Used to get the URL that to be used to perform searches.
    # $word is the query
    # Returns the full URL.
    sub getSearchUrl
    {
        my ($self, $word) = @_;
        my $url;

        # Your code here

        #my $response =
          $self->{ua}->post("http://www.moviemeter.nl/film/search", [ 'search[title]' => $word ]);
        #$url = return "http://www.moviemeter.nl/film/searchresults/";
        $url = return "http://www.moviemeter.nl/site/search?q=".$word;

        return $url;
    }

    # getItemUrl
    # Used to get the full URL of a movie page.
    # Useful when url on results pages are relative.
    # $url is the URL as found with a search.
    # Returns the absolute URL.
    sub getItemUrl
    {
        my ($self, $url) = @_;

        return 'http://www.moviemeter.nl' if (! $url);
        return $url if (! ($url =~ m/^\//));
        return 'http://www.moviemeter.nl'.$url;
    }

    # getCharset
    # Used to convert charset in web pages.
    # Returns the charset as specified in pages.
    sub getCharset
    {
        my $self = shift;

        #return "WINDOWS-1250";
        #return "UTF-8"; # page header say encoding is UTF-8 but that doesn't seem to be true
        return "ISO-8859-1";

    }

    # getName
    # Used to display plugin name in GUI.
    # Returns the plugin name.
    sub getName
    {
        return "MovieMeter.nl";
    }

    # getAuthor
    # Used to display the plugin author in GUI.
    # Returns the plugin author name.
    sub getAuthor
    {
        return 'MaTiZ - Kerenoc';
    }

    # getLang
    # Used to fill in plugin list with user language plugins
    # Return the language used for this site (2 letters code).
    sub getLang
    {
        return 'NL';
    }

    # hasSearchYear
    # Used to hide year column in search results
    # Return 0 to hide column, 1 to show it.
    sub hasSearchYear
    {
        return 1;
    }

    # hasSearchDirector
    # Used to hide director column in search results
    # Return 0 to hide column, 1 to show it.
    sub hasSearchDirector
    {
        return 0;
    }

    # hasSearchActors
    # Used to hide actors column in search results
    # Return 0 to hide column, 1 to show it.
    sub hasSearchActors
    {
        return 0;
    }

    # getExtra
    # Used if the plugin wants an extra column to be displayed in search results
    # Return the column title or empty string to hide the column.
    sub getExtra
    {
        return 'Original Title';
        #return '';
    }

    # changeUrl
    # Can be used to change URL if movie URL and the one used to
    # extract information are different.
    # Return the modified URL.
    sub changeUrl
    {
        my ($self, $url) = @_;

        return $url;
    }

    # start
    # Called each time a new HTML tag begins.
    # $tagname is the tag name.
    # $attr is reference to an associative array of tag attributes.
    # $attrseq is an array reference containing all the attributes name.
    # $origtext is the tag text as found in source file
    # Returns nothing
    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;
        if ($self->{parsingList})
        {

            # Your code for processing search results here
            if ($tagname eq "a")
            {
                if ($attr->{href} =~ m/\/film\/[0-9]+/)
                {
                    my $url = $attr->{href};
                    $self->{isMovie} = 1;
                    $self->{isInfo}  = 1;
                    $self->{itemIdx}++;
                    $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                }
            }
            elsif ($tagname eq "div")
            {
                if ($attr->{class} =~ /filmresults/)
                {
                    $self->{isYear} = 1;
                }
            }
            elsif ($tagname eq "span")
            {
                if ($attr->{class} =~ /subtext/)
                {
                    $self->{altTitle} = 1;
                }
            }
        }
        else
        {
            # Your code for processing movie information here
            if ($tagname eq "h1")
            {
                $self->{insideName} = 1;
            }
            elsif ($tagname eq "img")
            {
                if ($attr->{class} =~ m/poster/i)
                {
                    $self->{curInfo}->{image} = $attr->{src};
                }
            }
            elsif ($attr->{itemprop} eq 'director')
            {
                $self->{insideDirector} = 1;
            }
            elsif ($attr->{itemprop} eq 'description')
            {
                $self->{insideDescription} = 1;
            }
            elsif ($attr->{itemprop} eq 'ratingValue')
            {
                $self->{insideRating} = 1;
            }
            elsif ($tagname eq 'p' && $self->{insideCountry} eq 1)
            {
                $self->{insideCountry} = 2;
            }
        }
    }

    # end
    # Called each time a HTML tag ends.
    # $tagname is the tag name.
    sub end
    {
        my ($self, $tagname) = @_;
        $self->{inside}->{$tagname}--;

        if ($self->{parsingList})
        {
            # Your code for processing search results here

        }
        else
        {
            # Your code for processing movie information here

            # optional
            if ($tagname eq "a" && $self->{insideDirector})
            {
                $self->{insideActors} = 1;
                $self->{insideDirector} = 0;
            }
            elsif ($tagname eq "p")
            {
                $self->{insideDescription} = 0;
                $self->{insideActors} = 0;
            }
            elsif ($tagname eq "span" && $self->{insideName})
            {
                $self->{isYear} = 1;
                $self->{insideName} = 0;
            }
        }
    }

    # text
    # Called each time some plain text (between tags) is processed.
    # $origtext is the read text.
    sub text
    {
        my ($self, $origtext) = @_;
        return if length($origtext) < 2;

        if ($self->{parsingList})
        {
            # Your code for processing search results here
            if ($self->{isMovie})
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{"title"} = $origtext;
                $self->{isMovie}                                  = 0;
                $self->{isInfo}                                   = 1;
                return;
            }
            elsif ($self->{isYear})
            {
                # Remove brackets from year: from (2002) to 2002
                $origtext =~ s/(\)|\()//g;
                # Remove leading or trailing whitespace
                $origtext =~ s/^\s+|\s+$//g;
                $self->{itemsList}[ $self->{itemIdx} ]->{"date"} = "01/01/".$origtext;
                $self->{isYear} = 0;
            }
            elsif ($self->{altTitle})
            {
                $origtext =~ /Alternatieve titel:\s(.*)/;
                $self->{itemsList}[ $self->{itemIdx} ]->{"extra"} =
                  $self->{itemsList}[ $self->{itemIdx} ]->{"title"};
                $self->{itemsList}[ $self->{itemIdx} ]->{"title"} = $1;
                $self->{altTitle} = 0;
            }

        }
        else
        {
            # Your code for processing movie information here
            if ($self->{insideName})
            {
                # First try to use the search results information, otherwise
                # parse the movie information
                my $title = $self->{itemsList}[ $self->{wantedIdx} ]->{"title"};
                if ($title)
                {
                    $self->{curInfo}->{title} = $title;
                    $self->{curInfo}->{date}  = $self->{itemsList}[ $self->{wantedIdx} ]->{"date"};
                    $self->{curInfo}->{original} =
                      $self->{itemsList}[ $self->{wantedIdx} ]->{"extra"};
                }
            }
            elsif ($self->{isYear})
            {
                # Split Little Miss Sunshine (2006) into title and year
                if ($origtext =~ m/\(.*\)/)
                {
                    $origtext =~ s/[\(\)\t\n]//g;
                    $self->{curInfo}->{date}  = "01/01/".$origtext;
                }
                $self->{isYear} = 0;
            }
            elsif ($self->{insideCountry} eq 2)
            {
                $origtext =~ s/[\t\n]*//g;
                $origtext =~ s/\//,/g;
                $self->{curInfo}->{country} = $origtext;
                $self->{insideCountry} = 0;
                $self->{insideGenres} = 1;
            }
            elsif ($self->{insideGenres})
            {
                $origtext =~ s/[\t\n]*//g;
                $origtext =~ s/\//,/g;
                $self->{curInfo}->{genre} = $origtext;
                $self->{insideGenres} = 0;
                $self->{insideTime} = 1;
            }
            elsif ($self->{insideTime})
            {
                $origtext =~ s/[\t\n]*//g;
                $origtext =~ s/ *minuten.*//;
                $self->{curInfo}->{time} = $origtext;
                $self->{insideTime} = 0;

            }
            elsif ($self->{insideActors})
            {
               if ($origtext =~ s/[\n\t\s]met\s//)
               {
                    $origtext =~ s/ en /, /;
                    $origtext =~ s/[\n\t]//g;
                    foreach my $actor (split(" *, *", $origtext))
                    {
                        push @{$self->{curInfo}->{actors}}, [$actor]
                            if $self->{actorsCounter} < $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS;
                        $self->{actorsCounter}++;
                    }
                }
            }
            elsif ($self->{insideDirector})
            {
                if (exists $self->{curInfo}->{director})
                {
                    $self->{curInfo}->{director} =
                        $self->{curInfo}->{director} . ", " . $origtext;
                }
                else
                {
                    $self->{curInfo}->{director} = $origtext;
                }
            }
            elsif ($self->{insideDescription})
            {
                $origtext =~ s/[\n\t]//g;
                $self->{curInfo}->{synopsis} .= " ".$origtext;
            }
            elsif ($self->{insideRating})
            {
                # Use a dot instead of a comma as decimal seperator
                $origtext =~ s/,/./;
                # Scale rating to a maximum of 10
                # and round to integer
                $self->{curInfo}->{ratingpress} = int($origtext * 2 + 0.5);
                $self->{insideRating} = 0;
                $self->{insideCountry} = 1;
            }
        }
    }

    # new
    # Constructor.
    # Returns object reference.
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();

        # $self->{ua}->cookie_jar(HTTP::Cookies->new); # not needed?

        # Do your init stuff here
        bless($self, $class);

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            actors   => 0,
        };

        $self->{isInfo}  = 0;
        $self->{isMovie} = 0;

        return $self;
    }

    # preProcess
    # Called before each page is processed. You can use it to do some substitutions.
    # $html is the page content.
    # Returns modified version of page content.
    sub preProcess
    {
        my ($self, $html) = @_;

        # replace <BR> and <P> tags with \n (also, </BR>,</P>, <P/>, <BR/> )
        #$html =~ s/\<(\/)?(BR|P)(\s*\/)?\>/\n/mgi;
    
        $self->{insideDescription} = 0;
        $self->{insideActors} = 0;
        $self->{insideDirector} = 0;
        $self->{insideRating} = 0;
        $self->{insideName} = 0;
        $self->{insideTime} = 0;
        $self->{insideCountry} = 0;
        $self->{insideGenres} = 0;
        $self->{isYear} = 0;
        
        return $html;
    }

}

1;
