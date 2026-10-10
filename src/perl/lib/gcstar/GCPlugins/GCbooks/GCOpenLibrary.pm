package GCPlugins::GCbooks::GCOpenLibrary;

###################################################
#
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


use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginOpenLibrary;

    use base 'GCPlugins::GCbooks::GCbooksPluginsBase';

    use JSON qw( decode_json );
    use GCUtils;

    my $apiRoot = "https://openlibrary.org";
    my $coverRoot = "https://covers.openlibrary.org/b/id/";

    sub parse
    {
        my ($self, $page) = @_;

        my $json = decode_json($page);

        if ($self->{parsingList})
        {
            foreach my $item ( @{$json->{docs}} )
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{title} = $item->{title};
                $self->{itemsList}[$self->{itemIdx}]->{url} = "$apiRoot.$item->{key}.json";
                $self->{itemsList}[$self->{itemIdx}]->{edition} = $item->{first_publish_year};
                $self->{itemsList}[$self->{itemIdx}]->{cover} = "$coverRoot$item->{cover_i}-M.jpg"
                    if ($item->{cover_i});
                
                foreach my $author ( @{$item->{author_name}} )
                {
                	$self->{itemsList}[$self->{itemIdx}]->{authors} .= $author.",";
                }
                $self->{itemsList}[$self->{itemIdx}]->{authors} =~ s/,$//;
            }
        }
        else
        {
            $self->{curInfo}->{title} = $json->{title};
            $self->{curInfo}->{web} = "$apiRoot".$json->{key};
            $self->{curInfo}->{description} = ($json->{description}->{value})
                                                ? $json->{description}->{value}
                                                : $json->{description};
            $self->{curInfo}->{authors} = $self->{itemsList}[$self->{wantedIdx}]->{authors};
            $self->{curInfo}->{publication} = $self->{itemsList}[$self->{wantedIdx}]->{edition};
            $self->{curInfo}->{cover} = $self->{itemsList}[$self->{wantedIdx}]->{cover};
            $self->{curInfo}->{cover} = "https://covers.openlibrary.org/b/id/".$json->{covers}[0]."-M.jpg"
                if ($json->{covers});
            
            foreach my $subject ( @{$json->{subjects}} )
            {
            	$self->{curInfo}->{genre} .= $subject.",";
            }
            $self->{curInfo}->{genre} =~ s/,$//;
       }
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless($self, $class);

        $self->{hasField} = {
            title => 1,
            authors => 1,
            publication => 0,
            format => 0,
            edition => 1,
        };

        return $self;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

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
        return "$apiRoot/search.json?q=$word";
    }

    sub changeUrl
    {
        my ($self, $url) = @_;
        # Make sure the url is for the api
        return $self->getItemUrl($url);
    }

    sub siteLanguage
    {
        my $self = shift;

        return 'en-US';
    }

    sub getName
    {
        return "Open Library";
    }

    sub getAuthor
    {
        return 'Kerenoc';
    }

    sub getLang
    {
        return 'EN';
    }

    sub isPreferred
    {
        return 0;
    }

}

1;
