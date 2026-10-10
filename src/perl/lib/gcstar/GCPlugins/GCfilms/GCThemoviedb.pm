package GCPlugins::GCfilms::GCthemoviedb;

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


use GCPlugins::GCfilms::GCfilmsCommon;

{
    package GCPlugins::GCfilms::GCPluginThemoviedb;

    use base 'GCPlugins::GCfilms::GCfilmsPluginsBase';

    use JSON qw( decode_json );

    my $apiRoot = "https://api.themoviedb.org/3";
    my $apiKey = "";

    sub parse
    {
        my ($self, $page) = @_;

        my $json = decode_json($page);

        if ($self->{parsingList})
        {
            foreach my $item ( @{$json->{results}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{title} = $item->{title};
                $self->{itemsList}[$self->{itemIdx}]->{url} = $apiRoot."/movie/".$item->{id}.$apiKey
                    ."&append_to_response=release_dates"
                    ."&language=".$self->siteLanguage();
                $item->{release_date} =~ s/-/\//g;
                $self->{itemsList}[$self->{itemIdx}]->{date} = $item->{release_date};
            }
        }
        else
        {
            if (defined $json->{title})
            {
                $self->{curInfo}->{webPage} = "https://www.themoviedb.org/movie/".$json->{id};
                $self->{curInfo}->{image} = "https://image.tmdb.org/t/p/w440_and_h660_face".$json->{poster_path};
                $self->{curInfo}->{original} = $json->{original_title};
                $self->{curInfo}->{title} = $json->{title};
                my ($year, $month, $day) = split m|-|, $json->{release_date};
                $self->{curInfo}->{date} = "$day/$month/$year";
                $self->{curInfo}->{genre} = [];
                $self->{curInfo}->{time} = $json->{runtime};
                $self->{curInfo}->{ratingpress} = $json->{vote_average};
                $self->{curInfo}->{synopsis} = $json->{overview};
                foreach my $genre ( @{$json->{genres}} )
                {
                       push @{$self->{curInfo}->{genre}}, [$genre->{name}];
                }
                foreach my $country ( @{$json->{production_countries}} )
                {
                       push @{$self->{curInfo}->{country}}, [$country->{name}];
                }
                $self->{curInfo}->{audio} = '';
                foreach my $lang ( @{$json->{spoken_languages}} )
                {
                       $self->{curInfo}->{audio} .= $lang->{name}.', ';
                }
                # trigger loading the credit page
                $self->{curInfo}->{nextUrl} = $apiRoot."/movie/".$json->{id}."/credits".$apiKey;
            }
            foreach my $actor ( @{$json->{cast}} )
            {
                push @{$self->{curInfo}->{actors}}, [$actor->{name}];
                push @{$self->{curInfo}->{actors}->[$self->{actorsCounter}]}, $actor->{character}
                    if (defined $actor->{character});
                $self->{actorsCounter}++;
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
            date     => 1,
            director => 0,
            actors   => 0,
        };

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
                $url = "http://api.themoviedb.org/2.1/Movie.getInfo/".$self->siteLanguage()."/xml/9fc8c3894a459cac8c75e3284b712dfc/"
                  . reverse($id);
            }
        }
        return $url;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{actorsCounter} = 0;

        return $html;
    }

    sub decodeEntitiesWanted
    {
        return 0;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return "https://api.themoviedb.org/3/search/movie".$apiKey."&query=$word";
    }

    sub changeUrl
    {
        my ($self, $url) = @_;
        # Make sure the url is for the api, not the main movie page
        return $self->getItemUrl($url);
    }

    sub siteLanguage
    {
        my $self = shift;

        return 'en-US';
    }

    sub getName
    {
        return "The Movie DB";
    }

    sub getAuthor
    {
        return 'Zombiepig - Kerenoc';
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

    sub isPreferred
    {
        return 0;
    }

}

1;
