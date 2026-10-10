package GCPlugins::GCfilms::GCAllmovie;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2015-2016 Kerenoc
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

###################################################
#
# 2015 Changes
#
#    - adaptation to site changes
#    - casting information got from an additional web page (requires a modified GCPluginsBase)
#
###################################################

use strict;

use GCPlugins::GCfilms::GCfilmsCommon;

{

    package GCPlugins::GCfilms::GCPluginAllmovie;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);
    
    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq "div" && ($attr->{class} eq "title"))
            {
                $self->{insideMovie} = 1;
            }
            elsif ($tagname eq "a" && $self->{insideMovie} eq 1)
            {
                $self->{insideMovie} = 2;
                $self->{insideYear} = 1;
                
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
            }
            elsif ($tagname eq "div" && ($attr->{class} eq "artist"))
            {
                $self->{insideDirector} = 1;
            }
            elsif (0 eq 1 && $tagname eq "div" && ($attr->{class} eq "title"))
            {
                $self->{insideYear} = 1;
            }
            elsif ($tagname eq "a" && $self->{insideDirector} eq 1)
            {
                $self->{insideDirector} = 2;
            }
            elsif ($tagname eq "div" && $self->{insideMovie} eq 1)
            {
                $self->{insideMovie} = 2;
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
            }
            elsif ($tagname eq "title")
            {
                $self->{insideHTMLtitle} = 1;
                # trying to be kind on server which sometimes returns 500 HTTP errors 
                sleep 1;
            }
        }
        else
        {
            if (($tagname eq "h2") && ($attr->{class} eq "movie-title"))
            {
                $self->{insideTitle} = 1;
                # trying to be kind on server which sometimes returns 500 HTTP errors 
                sleep 1;
            }
            elsif ($tagname eq "span" && $self->{insideCountry} eq 1)
            {
                $self->{insideCountry} = 2;
            }
            elsif ($tagname eq "span" && $self->{insideRating} eq 1)
            {
                $self->{insideRating} = 2;
            }
            elsif ($tagname eq "div" && $attr->{itemprop} eq "ratingValue")
            {
                $self->{insideRatingPress} = 1;
            }
            elsif ($tagname eq "span" && $self->{insideTime} eq 1)
            {
                $self->{insideTime} = 2;
            }
            elsif ($tagname eq "span" && $self->{insideYearRuntime} eq 1)
            {
                $self->{insideYearRuntime} = 2;
            }
            elsif (($tagname eq "h3") && ($attr->{class} eq "movie-director"))
            {
                $self->{insideDirector} = 1;
            }
            elsif (($tagname eq "a") && $self->{insideDirector} eq 1)
            {
                $self->{insideDirector} = 2;
            }
            elsif (($tagname eq "span") && ($attr->{class} =~ m/header-movie-.*genres/))
            {
                $self->{insideGenre} = 1;
            }
            elsif (($tagname eq "a") && $self->{insideGenre} eq 1)
            {
                $self->{insideGenre} = 2;
            }
            elsif (($tagname eq "span") && ($attr->{class} eq "release-year"))
            {
                $self->{insideYear} = 1;
            }
            elsif (($tagname eq "hgroup") && ($attr->{class} eq "details"))
            {
                $self->{insideLeftSidebarTitle} = 1;
            }
            elsif (($tagname eq "div") && ($attr->{class} =~ m/(cast|crew)_name artist-name/))
            {
                $self->{insideActors} = 1;
            }
            elsif ($self->{insideActors} eq 1 && $tagname eq "div" && $attr->{class} =~ m/(cast|crew)_role/)
            {
                $self->{insideActors} = 2;
                $self->{typeCrewCast} = $attr->{class};
            }
            elsif (($tagname eq "div") && $attr->{itemprop} && ($attr->{itemprop} eq "description"))
            {
                $self->{insideSynopsis} = 1;
            }
            elsif (($tagname eq "a") && ($attr->{href} =~ m/\/cast-crew/ ))
            {
                if ($self->{firstPass} eq 1)
                {
                    # trigger the load of web page with the list of actors and roles
                    $self->{curInfo}->{nextUrl} = "http://www.allmovie.com".$attr->{href};
                    $self->{firstPass} = 0;
                }
            }
            elsif (    ($tagname eq "div") && $attr->{id}
                    && (     ($attr->{id} eq "left-sidebar-title")
                         || ($attr->{id} eq "left-sidebar-title-small"))
                  )
            {
                $self->{insideLeftSidebarTitle} = 1;
            }
            elsif ($tagname eq "a")
            {
                if ($self->{insideDirectorList})
                {
                    $self->{insideDirector} = 1;
                }
                elsif ($self->{nextIsSeries})
                {
                    $self->{insideSeries} = 1;
                    $self->{nextIsSeries} = 0;
                }
            }
            elsif (($tagname eq "img") && $attr->{class} && ($attr->{class} eq "gallery-launch"))
            {
                $self->{curInfo}->{image} ||= ($attr->{src});
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;

        if ($tagname eq "div" && $self->{insideYear})
        {
            $self->{insideYear} = 0;
        }
        elsif ($tagname eq "div" && $self->{insideSynopsis})
        {
            $self->{insideSynopsis} = 0;
        }
        elsif ($tagname eq "span" && $self->{insideGenre})
        {
            $self->{insideGenre} = 0;
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;
        return if ((length($origtext) == 0) || ($origtext eq " "));

        $origtext =~ s/&#34;/"/g;
        $origtext =~ s/&#179;/3/g;
        $origtext =~ s/&#[0-9]*;//g;
        $origtext =~ s/\n//g;
                
        # Strip leading and tailing spaces
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;

        if ($self->{parsingList})
        {
            if ($self->{insideMovie} eq 2)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $origtext;
                $self->{insideMovie} = 0;               
            }
            elsif ($self->{insideYear})
            {
                $origtext =~ s/^\s*\(*//;
                $origtext =~ s/\)*\s*$//g;
                
                $self->{itemsList}[ $self->{itemIdx} ]->{date} = $origtext
                #$self->{insideYear} = 0;
            }
            elsif ($self->{insideDirector} eq 2)
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{director} = $origtext;
                $self->{insideDirector} = 0;
            }
        }
        else
        {
            return if $origtext eq '';
            if ($self->{insideTitle})
            {
                # plugin with multiple passes : {curInfo}->{title} is set during the first pass
                if (! $self->{curInfo}->{title})
                {
                    $self->{firstPass} = 1;
                }
                $self->{curInfo}->{title} = $origtext;
                $self->{insideTitle} = 0;
            }
            elsif ($self->{insideDirector} eq 2)
            {
                $self->{curInfo}->{director} = $origtext;
                $self->{insideDirector}      = 0;
                $self->{insideDirectorList}  = 0;
            }
            elsif ($self->{insideGenre} eq 2)
            {
                my $genre = $self->capWord($origtext);
                if (! ($self->{curInfo}->{genre} =~ m/$genre/))
                {
                    $self->{curInfo}->{genre} .= $self->capWord($origtext) . ',';
                }
                $self->{insideGenre} = 1;
            }
            elsif ($self->{insideYear})
            {
                $origtext =~ s/^\(+//;
                $origtext =~ s/\)+$//g;
                $self->{curInfo}->{date} = $origtext;
                $self->{insideYear} = 0;
            }
            elsif ($self->{insideYearRuntime} eq 2)
            {
                $origtext =~ s/\(.*//g;
                $self->{curInfo}->{date} = GCUtils::strToTime($origtext, "%b %d %Y", "EN");
                        $self->{insideYearRuntime} = 0;
            }
            elsif ($self->{insideActors} eq 1)
            {
                #$self->{curInfo}->{actors} .= $origtext . ', '
                #  if ($self->{actorsCounter} < $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS);
                #$self->{actorsCounter}++;
                #$self->{insideActors} = 0;
                $self->{actor} = $origtext if (! $self->{actor});
            }
            elsif ($self->{insideActors} eq 2)
            {
                $self->{role} = $origtext;
                # GTK3 problem with actors with multiple roles (additional column inn Gtk3::SimpleList)
                # checking that the actor was not already seen
                my $actorNew = 1;
                $actorNew = 0 if ($self->{typeCrewCast} eq "crew_role" && $self->{role} ne "Actor");
                push @{$self->{curInfo}->{actors}}, [$self->{actor}] if ($actorNew);
                push @{$self->{curInfo}->{actors}->[$self->{actorsCounter}]}, $self->{role} if ($actorNew);
                $self->{actorsCounter}++;
                $self->{actor} = 0;
                $self->{role} = 0;
                $self->{insideActors} = 0;
            }
            elsif ($self->{insideSynopsis})
            {
                $self->{curInfo}->{synopsis} .= $origtext." ";
            }
            elsif ($self->{insideCountry} eq 2)
            {
                $self->{curInfo}->{country} = $origtext;
                $self->{insideCountry} = 0;
            }
            elsif ($self->{insideTime} eq 2)
            {
                $origtext =~ s/\s*min.*//;
                $self->{curInfo}->{time} = $origtext;
                $self->{insideTime} = 0;
            }
            elsif ($self->{insideRating} eq 2)
            {
                $self->{curInfo}->{age} = 1
                  if ($origtext eq 'Unrated') || ($origtext eq 'Open');
                $self->{curInfo}->{age} = 2
                  if ($origtext eq 'G') || ($origtext eq 'Approved');
                $self->{curInfo}->{age} = 5
                  if ($origtext eq 'PG') || ($origtext eq 'M') || ($origtext eq 'GP');
                $self->{curInfo}->{age} = 13 if $origtext eq 'PG13';
                $self->{curInfo}->{age} = 17 if $origtext eq 'R';
                $self->{curInfo}->{age} = 18
                  if ($origtext eq 'NC17') || ($origtext eq 'X');
                $self->{insideRating} = 0;
            }
            elsif ($self->{insideRatingPress})
            {
                $origtext =~ s/\s//g;
                $self->{curInfo}->{ratingpress} = 0 + $origtext if ! $self->{curInfo}->{ratingpress};
                $self->{insideRatingPress} = 0;
            }
            elsif ($origtext =~ /Is part of the series:$/)
            {
                $self->{nextIsSeries} = 1;
            }

            elsif ($self->{insideOtherTitles})
            {
                $self->{tempOriginal} = $origtext;
                $self->{tempOriginal} =~ s/\s*$//;
                $self->{tempOriginal} =~ s/^\s*//;

                $self->{curInfo}->{original} .= $self->{tempOriginal} . ', ';
                $self->{insideOtherTitles} = 0;

            }
            elsif ($self->{insideSeries})
            {
                $self->{curInfo}->{serie} = $origtext;
                $self->{curInfo}->{serie} =~ s/( \[.*\])//;
                $self->{insideSeries} = 0;
            }
            # be careful to keep this test at the end
            elsif ($self->{insideLeftSidebarTitle})
            {
                if ($origtext eq "Genres")
                {
                    $self->{insideGenreList}        = 1;
                }
                elsif ($origtext =~ m/Release Date/)
                {
                    $self->{insideYearRuntime} = 1;
                }
                elsif ($origtext =~ m/Countries/)
                {
                    $self->{insideCountry} = 1;
                }
                elsif ($origtext =~ m/Run Time/)
                {
                    $self->{insideTime} = 1;
                }
                elsif ($origtext =~ m/MPAA Rating/)
                {
                    $self->{insideRating} = 1;
                }
            }
        }
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        $self->{hasField} = {
            title    => 1,
            date     => 1,
            director => 1,
            actors   => 0,
        };

        $self->{curName} = undef;
        $self->{curUrl}  = undef;

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $html =~ s/"&#34;/'"/g;
        $html =~ s/&#34;"/"'/g;
        $html =~ s|</a></b><br>|</a><br>|;
        
        $self->{actorsCounter} = 0;
        my @tagsName = ('Actors', 'Country', 'Director', 'GenreList', 'HTMLtitle', 'Movie', 
                        'Rating', 'RatingPress', 'Series', 'Synopsis', 'Time', 'YearRuntime', 'Year');
        foreach my $tagName (@tagsName)
        {
            $self->{'inside'.$tagName} = 0;
        }

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        my $wordFiltered = $word;

        # Allmovie doesn't return correct results if searching with a prefix like 'the'
        $wordFiltered =~ s/^(the|a)?[+\s]+[^ a-zA-Z0-9]*\s*//i;
        # return ('http://allmovie.com/search/all', ['q' => $wordFiltered,'submit' => 'SEARCH']);
        return ('http://allmovie.com/search/all/' . $wordFiltered);

    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url if $url =~ /^https?:/;
        return "http://allmovie.com" . $url;
    }

    sub getName
    {
        return "Allmovie";
    }

    sub getAuthor
    {
        return 'Zombiepig - Kerenoc';
    }

    sub getLang
    {
        return 'EN';
    }

}

1;
