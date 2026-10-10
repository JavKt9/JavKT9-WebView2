package GCPlugins::GCTVepisodes::GCthemoviedb;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2010-2016 Zombiepig
#  Copyright 2020-2021 Kerenoc
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

use GCPlugins::GCTVepisodes::GCTVepisodesCommon;

{
    package GCPlugins::GCTVepisodes::GCPluginThemoviedb;

    use base 'GCPlugins::GCTVepisodes::GCTVepisodesPluginsBase';

    use JSON qw( decode_json );

    my $apiRoot = "https://api.themoviedb.org/3";
    my $apiKey = "";

    sub parse
    {
        my ($self, $page) = @_;

        my $json = decode_json($page);

        if ($self->{parsingList} && $self->{pass} eq 1)
        {
            foreach my $item ( @{$json->{results}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{name} = $item->{name};
                $self->{itemsList}[$self->{itemIdx}]->{nextUrl} = $apiRoot."/tv/".$item->{id}.$self->{apiKey};
                $item->{first_air_date} =~ s/-/\//g;
                $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $item->{first_air_date};
            }
        }
        elsif ($self->{parsingList} && $self->{pass} eq 2)
        {
            if ($self->{loadedUrl} !~ m/credits/)
            {
                foreach my $item ( @{$json->{seasons}} )
                {
                    $self->{itemIdx}++;
                    $self->{itemsList}[$self->{itemIdx}]->{series} = $json->{name};
                    $self->{itemsList}[$self->{itemIdx}]->{nextUrl} = $apiRoot."/tv/".$json->{id}."/season/".$item->{season_number}.$self->{apiKey};
                    $item->{air_date} =~ s/-/\//g;
                    $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $item->{air_date};
                    $self->{itemsList}[$self->{itemIdx}]->{season} = $item->{season_number};
                }
                $self->{data}->{serie_name} = $json->{name};
                $self->{data}->{serie_time} = $json->{episode_run_time}[0];
                foreach my $genre ( @{$json->{genres}} )
                {
                    #push @{$self->{serie_genre}}, [$genre->{name}];
                    $self->{data}->{serie_genre} .= "$genre->{name}".", "
                        if ! ($self->{data}->{serie_genre} =~ m/$genre->{name}/);
                }
                $self->{data}->{serie_genre} =~ s/, $//;
                foreach my $country (@{$json->{origin_country}} )
                {
                    $self->{data}->{serie_country} .= $country.", "
                        if ! ($self->{data}->{serie_country} =~ m/$country/);
                }
                $self->{data}->{serie_country} =~ s/, $//;
                $self->{data}->{serie_id} = $json->{id};
                # trigger loading the credit page to get actors
                $self->{nextUrl} = $apiRoot."/tv/".$self->{data}->{serie_id}."/credits".$self->{apiKey};
            }

            # save recurrent actors of serie
            foreach my $actor ( @{$json->{cast}} )
            {
                push @{$self->{data}->{actors}}, [$actor->{name}, $actor->{character}];
            }
        }
        elsif ($self->{parsingList} && $self->{pass} eq 3)
        {
            foreach my $item ( @{$json->{episodes}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{name} = $item->{name};
                $self->{itemsList}[$self->{itemIdx}]->{series} = $self->{title};
                $self->{itemsList}[$self->{itemIdx}]->{url} = $self->{loadedUrl};
                $item->{air_date} =~ s/-/\//g;
                $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $item->{air_date};
                $self->{itemsList}[$self->{itemIdx}]->{season} = $item->{season_number};
                $self->{itemsList}[$self->{itemIdx}]->{episode} = $item->{episode_number};
                $self->{itemsList}[$self->{itemIdx}]->{synopsis} = $item->{overview};
                $self->{itemsList}[$self->{itemIdx}]->{image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$item->{still_path}
                    if $item->{still_path};
                for my $crew ( @{$item->{crew}} )
                {
                    $self->{itemsList}[$self->{itemIdx}]->{director} .= $crew->{name}.", "
                        if $crew->{job} eq 'Director'
                           && ! ($self->{itemsList}[$self->{itemIdx}]->{director} =~ m/$crew->{name}/);
                }
                $self->{itemsList}[$self->{itemIdx}]->{director} =~ s/, $//;
                for my $actor ( @{$item->{guest_stars}} )
                {
                    push @{$self->{itemsList}[$self->{itemIdx}]->{actors}}, [$actor->{name}, $actor->{character}];
                }
            }
            $self->{data}->{serie_image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$json->{poster_path};
        }
        else
        {
            foreach my $idx ('season', 'episode', 'name', 'director', 'image', 'synopsis', 'firstaired', 'actors', 'series')
            {
                $self->{curInfo}->{$idx} = $self->{itemsList}[$self->{wantedIdx}]->{$idx};
            }
            $self->{curInfo}->{image} = $self->{data}->{serie_image} if ! $self->{curInfo}->{image};
            $self->{curInfo}->{time} = $self->{data}->{serie_time};
            $self->{curInfo}->{genre} = $self->{data}->{serie_genre};
            $self->{curInfo}->{country} = $self->{data}->{serie_country};

            # merge series actors with episode actors without duplicates
            my %uniques;
            @uniques{@{$self->{data}->{actors}}} = @{$self->{data}->{actors}} x (1);
            for (@{$self->{curInfo}->{actors}}) {
                push @{$self->{data}->{actors}}, $_ if ! $uniques{$_};
            }

            $self->{curInfo}->{actors} = $self->{data}->{actors};
            $self->{curInfo}->{webPage} = "https://www.themoviedb.org/tv/".$self->{data}->{serie_id}."/season/".$self->{curInfo}->{season}
                ."?language=".$self->siteLanguage();
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
            firstaired     => 1
        };

        $self->{apiKey} = $apiKey."&language=".$self->siteLanguage();
        return $self;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        if (!$url)
        {
            # If we're not passed a url, return a hint so that gcstar knows what type
            # of addresses this plugin handles
            $url = "http://www.themoviedb.org";
        }
        elsif (index($url, "api") < 0)
        {
            # Url isn't for the movie db api, so we need to find the movie id
            # and return a url corresponding to the api page for this movie
            print "\nPlugin Series TheMovieDB suspicious url :".$url;
            my $found = index(reverse($url), "/");
            if ($found >= 0)
            {
                my $id = substr(reverse($url), 0, $found);
                  $url ="http://api.themoviedb.org/2.1/Movie.getInfo/en/xml/9fc8c3894a459cac8c75e3284b712dfc/"
                  . reverse($id);
            }
        }
        return $url;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        return $html;
    }

    sub decodeEntitiesWanted
    {
        return 0;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return "https://api.themoviedb.org/3/search/tv".$self->{apiKey}."&query=$word";
    }

    sub getNumberPasses
    {
        return 3;
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1)
        {
            $self->{hasField} = {
                name => 1,
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

    sub getSearchCharset
    {
        my $self = shift;

        # Need urls to be double character encoded
        return "utf8";
    }

    sub convertCharset
    {
        my ($self, $value) = @_;
        return $value;
    }

    sub getNotConverted
    {
        my $self = shift;
        return [];
    }

}

1;
