package GCPlugins::GCstar::GCThemoviedbCommon;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2010-2016 Zombiepig
#  Copyright 2020-2026 Kerenoc
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

use GCPlugins::GCPluginsBase;

{
    package GCPlugins::GCstar::GCThemoviedbCommon;

    use base 'GCPlugins::GCPluginsBase';

    use JSON qw( decode_json );
    use GCUtils;

    my $apiRoot = "https://api.themoviedb.org/3";
    my $apiKey = "";

    sub parse
    {
        my ($self, $page) = @_;

        if ($page =~ /^local:/)
        {
            # add episode info to serie info
            $self->{curInfo} = { %{$self->{data}}, %{$self->{itemsList}[$self->{wantedIdx}]} };
            return;
        }

        my $json = decode_json($page);
        if ($self->{parsingList} && $self->{pass} eq 1)
        {
            foreach my $serie ( @{$json->{results}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{$self->{titleField}} = $serie->{name};
                $self->{itemsList}[$self->{itemIdx}]->{nextUrl} = "$apiRoot/tv/$serie->{id}?$apiKey&$self->{language}";
                $serie->{first_air_date} =~ s/-/\//g;
                $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $serie->{first_air_date};
            }
        }
        elsif ($self->{loadedUrl} =~ m/credits/)
        {
            # save recurrent actors of serie
            foreach my $actor ( @{$json->{cast}} )
            {
                push @{$self->{data}->{actors}}, [$actor->{name}, $actor->{character}];
            }
            foreach my $crew ( @{$json->{crew}} )
            {
                $self->{data}->{director} .=  $crew->{name}.", "
                    if ($crew->{job} eq 'Director');
            }
            $self->{data}->{director} =~ s/, $//;
            ($self->{curInfo}->{nextUrl} = $self->{loadedUrl}) =~ s|credits|content_ratings|;
        }
        elsif ($self->{loadedUrl} =~ m/content_ratings/)
        {
            my $fullLang = $GCOptions::options->getFullLang();
            (my $lang = $fullLang) =~ s/\..*//;
            (my $country = $lang) =~ s/.*_//;
            $lang =~ s/_.*//;
            # find the country rating, othewise default to US rating if available
            my ($result) = grep { $_->{iso_3166_1} eq $country } @{$json->{results}};
            my ($resultUS) = grep { $_->{iso_3166_1} eq 'US' } @{$json->{results}};
            my $resultDefault =  @{$json->{results}}[0];
            $self->{data}->{age} = GCUtils::ageContentRating($result->{rating},$country, $self->{searchType})
                if ($result && $country);
            $self->{data}->{age} = GCUtils::ageContentRating($resultUS->{rating},'US', $self->{searchType})
                 if ($resultUS && ! $self->{data}->{age} && $country ne 'US');
             $self->{data}->{age} = GCUtils::ageContentRating($resultDefault->{rating},$resultDefault->{iso_3166_1}, $self->{searchType})
                 if ($resultDefault && ! $self->{data}->{age});
            $self->{curInfo} = { %{$self->{data}} };
        }
        elsif ($self->{loadedUrl} =~ /season/)
        {
            $self->{data}->{director} =~ s/, $//;
            $self->{data}->{image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$json->{poster_path};
            $self->{data}->{season} = $json->{season_number};
            $self->{data}->{webPage} = "https://www.themoviedb.org/tv/$self->{data}->{id}/season/$self->{data}->{season}"
                    ."?$self->{language}";
            my ($year, $month, $day) = split m|-|, $json->{first_air_date}; # S
            ($year, $month, $day) = split m|-|, $json->{air_date} if  ($self->{searchType} eq 'tvepisodes');
            $self->{data}->{firstaired} = "$day/$month/$year";
            $self->{data}->{synopsis} = $json->{overview}."\n\n" if $json->{overview};
            $self->{data}->{time} = $json->{episode_run_time}; # S
            foreach my $lang ( @{$json->{spoken_languages}} )
            {
                $self->{data}->{audio} .= $lang->{name}.', ';
            }
            if ($self->{searchType} eq 'tvepisodes' && $self->{pass})
            {
                foreach my $episode ( @{$json->{episodes}} )
                {
                    my $episodeInfo = {};

                    $episodeInfo->{name} = $episode->{name};
                    $episodeInfo->{series} = $self->{data}->{name};
                    $episodeInfo->{url} = "local://".$self->{loadedUrl};
                    my ($year, $month, $day) = split m|-|, $episode->{air_date};
                    $episodeInfo->{firstaired} = "$day/$month/$year";
                    $episodeInfo->{season} = $episode->{season_number};
                    $episodeInfo->{episode} = $episode->{episode_number};
                    $episodeInfo->{time} = $episode->{runtime};
                    $episodeInfo->{synopsis} = $episode->{overview};
                    $episodeInfo->{image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$episode->{still_path}
                        if $episode->{still_path};

                    for my $crew ( @{$episode->{crew}} )
                    {
                        $episodeInfo->{director} .= $crew->{name}.", "
                            if $crew->{job} eq 'Director'
                               && ! ($episodeInfo->{director} =~ m/$crew->{name}/);
                    }
                    $episodeInfo->{director} =~ s/, $//;
                    map { push @{$episodeInfo->{actors}}, $_ } @{$self->{data}->{actors}} ;
                    for my $actor ( @{$episode->{guest_stars}} )
                    {
                        push @{$episodeInfo->{actors}}, [$actor->{name}, $actor->{character}];
                    }
                    $self->{itemIdx}++;
                    $self->{itemsList}[$self->{itemIdx}] = $episodeInfo;
                }
            }
            elsif ($self->{searchType} eq 'tvseries')
            {
                $self->{data}->{season_synopsis} = "";
                foreach my $episode ( @{$json->{episodes}} )
                {
                    push @{$self->{data}->{episodes}}, [$episode->{episode_number}, $episode->{name}];
                    $self->{data}->{season_synopsis} .= $episode->{episode_number}." : ".$episode->{name}. " (".$episode->{runtime}."')";
                    $self->{data}->{season_synopsis} .= "\n    ".$episode->{overview}."\n\n";
                }
                $self->{data}->{series} = $json->{name}
                    if (! $self->{data}->{series} && ! $json->{season_number});
                $self->{data}->{title} = $self->{data}->{name}." - ".$json->{name};
                $self->{data}->{name} = $json->{name}." - ".$json->{seasons}[0]->{name};
                my ($year, $month, $day) = split m|-|, $json->{air_date};
                $self->{data}->{firstaired} = "$day/$month/$year";
                $self->{data}->{synopsis} .= $self->{data}->{season_synopsis};
            }
            if (! $self->{data}->{series})
            {
                $self->{curInfo}->{nextUrl} = "$apiRoot/tv/$self->{data}->{id}?$apiKey&append_to_response=release_dates&$self->{language}";
            }
            else
            {
                $self->{curInfo}->{nextUrl} = "$apiRoot/tv/$self->{data}->{id}/credits?$apiKey&$self->{language}";
            }
        }
        else
        {
            if ($self->{pass} eq 2)
            {
                foreach my $season ( @{$json->{seasons}} )
                {
                    $self->{itemIdx}++;
                    $self->{itemsList}[$self->{itemIdx}]->{series} = $json->{name};
                    my $urlField = ($self->{searchType} eq 'tvseries') ? 'url' : 'nextUrl';
                    $self->{itemsList}[$self->{itemIdx}]->{$urlField} = "$apiRoot/tv/$json->{id}/season/$season->{season_number}?$apiKey&$self->{language}";
                    $season->{air_date} =~ s/-/\//g;
                    $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $season->{air_date};
                    $self->{itemsList}[$self->{itemIdx}]->{season} = $season->{season_number};
                }
            }
            $self->{data}->{name} = $json->{name};
            $self->{data}->{series} = $json->{name};
            $self->{data}->{original} = $json->{original_name};
            $self->{data}->{time} = $json->{episode_run_time}[0];

            $self->{data}->{synopsis} = $json->{overview}."\n\n".$self->{data}->{synopsis};
            foreach my $genre ( @{$json->{genres}} )
            {
                $self->{data}->{genre} .= $genre->{name}.", "
                    if ($self->{data}->{genre} !~ m/$genre->{name}/);
            }
            $self->{data}->{genre} =~ s/, $//;
            foreach my $country (@{$json->{origin_country}} )
            {
                $self->{data}->{country} .= $country.", "
                    if ($self->{data}->{country} !~ m/$country/);
            }
            $self->{data}->{country} =~ s/, $//;
            $self->{data}->{id} = $json->{id};
            $self->{data}->{ratingpress} = $json->{vote_average};
            if ($json->{number_of_seasons} eq '1')
            {
                $self->{curInfo}->{nextUrl} = "$apiRoot/tv/$self->{data}->{id}/season/1?$apiKey&$self->{language}";
            }
            else
            {
                # trigger loading the credit page to get actors
                $self->{curInfo}->{nextUrl} = "$apiRoot/tv/$self->{data}->{id}/credits?$apiKey&$self->{language}";
            }
        }
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        if (!$url)
        {
            # If we're not passed a url, return a hint so that gcstar knows what type
            # of addresses this plugin handles
            $url = "https://www.themoviedb.org";
        }
        elsif (index($url, "api") < 0)
        {
            # Url isn't for the movie db api, so we need to find the movie id
            # and return a url corresponding to the api page for this movie
            print "\nPlugin TheMovieDB suspicious url :".$url;
            if ($url =~ /\/tv\/(\d+).*(language=.*)?/)
            {
                my $id = $1;
                my $language = $2 ? $2 : "language=en-EN";
                my $season = "";
                $season = $1 if ($url =~ /(\/season\/\d+)/);
                # https://www.themoviedb.org/tv/73586-yellowstone/season/4?language=fr-FR
                #https://api.themoviedb.org/3/tv/73586/season/4?api_key=REDACTED&language=fr-FR
                $url = "$apiRoot/tv/$id$season?$apiKey&append_to_response=release_dates&$language";
                if ($self->{data}->{id} != $id || $self->{language} != $language)
                {
                    # new serie
                    $self->{language} = $language;
                    $self->{data} = {};
                    $self->{data}->{id} = $id;
                }
            }
        }
        return $url;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{data} = undef if ($self->{pass} eq 1);

        return $html;
    }

    sub decodeEntitiesWanted
    {
        return 0;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $self->{language} = "language=".$self->siteLanguage();
        return "$apiRoot/search/tv?$apiKey&$self->{language}&query=$word";
    }

    sub getNumberPasses
    {
        my $self = shift;

        return(($self->{searchType} eq 'tvseries') ? 2 : 3);
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1)
        {
            $self->{hasField} = {
                $self->{titleField} => 1,
                firstaired => 1,
            };
        }
        elsif ($self->{pass} == 2)
        {
            $self->{hasField} = {
                series => 1,
                season => 1,
                firstaired => 1,
            };
        }
        else
        {
            $self->{hasField} = {
                name => 1,
                season => 1,
                episode => 1,
            };
        }
    }

    sub changeUrl
    {
        my ($self, $url) = @_;
        # Make sure the url is for the api, not the main movie page
        return $self->getItemUrl($url);
    }

    sub getName
    {
        return "The Movie DB";
    }

    sub getAuthor
    {
        return 'Zombiepig - Kerenoc';
    }

    sub siteLanguage
    {
        my $self = shift;

        return 'en-US';
    }

    sub getLang
    {
        return 'EN';
    }

    sub getCharset
    {
        my $self = shift;

        return "UTF-8";
    }
}

1;
