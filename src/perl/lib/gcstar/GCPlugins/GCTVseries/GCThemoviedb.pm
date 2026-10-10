package GCPlugins::GCTVseries::GCthemoviedb;

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

use GCPlugins::GCTVseries::GCTVseriesCommon;

{
    package GCPlugins::GCTVseries::GCPluginThemoviedb;

    use base 'GCPlugins::GCTVseries::GCTVseriesPluginsBase';

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
                $self->{itemsList}[$self->{itemIdx}]->{title} = $item->{name};
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
                    $self->{itemsList}[$self->{itemIdx}]->{url} = $apiRoot."/tv/".$json->{id}."/season/".$item->{season_number}.$self->{apiKey};
                    $item->{air_date} =~ s/-/\//g;
                    $self->{itemsList}[$self->{itemIdx}]->{firstaired} = $item->{air_date};
                    $self->{itemsList}[$self->{itemIdx}]->{season} = $item->{season_number};
                }
                $self->{serie_name} = $json->{name};
                $self->{serie_time} = $json->{episode_run_time}[0];
                foreach my $genre ( @{$json->{genres}} )
                {
                    push @{$self->{serie_genre}}, [$genre->{name}];
                }
                foreach my $country (@{$json->{origin_country}} )
                {
                    $self->{serie_country} .= $country.", ";
                }
                $self->{serie_country} =~ s/, $//;
                $self->{serie_id} = $json->{id};
                # trigger loading the credit page
                $self->{nextUrl} = $apiRoot."/tv/".$self->{serie_id}."/credits".$self->{apiKey};
            }
            foreach my $actor ( @{$json->{cast}} )
            {
                push @{$self->{data}->{actors}}, [$actor->{name}, $actor->{character}];
            }
        }
        else
        {
            $self->{curInfo}->{time} = $self->{serie_time};
            $self->{curInfo}->{genre} = $self->{serie_genre};
            $self->{curInfo}->{series} = $self->{serie_name};
            $self->{curInfo}->{title} = $self->{serie_name}." - ".$json->{name};
            $self->{curInfo}->{country} = $self->{serie_country};
            $self->{curInfo}->{webPage} = "https://www.themoviedb.org/tv/".$self->{serie_id}."/season/".$json->{season_number}.$self->{apiKey};
            $self->{curInfo}->{image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$json->{poster_path};
            $self->{curInfo}->{season} = $json->{season_number};
            my ($year, $month, $day) = split m|-|, $json->{air_date};
            $self->{curInfo}->{firstaired} = "$day/$month/$year";
            $self->{curInfo}->{actors} = $self->{data}->{actors};
            $self->{curInfo}->{synopsis} = $json->{overview};
            $self->{curInfo}->{audio} = '';
            foreach my $lang ( @{$json->{spoken_languages}} )
            {
                   $self->{curInfo}->{audio} .= $lang->{name}.', ';
            }
            foreach my $episode ( @{$json->{episodes}} )
            {
                push @{$self->{curInfo}->{episodes}}, [$episode->{episode_number}, $episode->{name}];
            }

            foreach my $crew ( @{$json->{crew}} )
            {
                $self->{curInfo}->{director} .=  $crew->{name}.", "
                    if ($crew->{job} eq 'Director');
            }
            $self->{curInfo}->{director} =~ s/, $//;
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
        return 2;
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1)
        {
            $self->{hasField} = {
                title => 1,
                firstaired => 1,
            };
        }
        else
        {
            $self->{hasField} = {
                series => 1,
                season => 1,
                firstaired => 1,
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
