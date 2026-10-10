###################################################
#
#  Copyright 2023 Giacomo Montagner <https://www.fiverr.com/gimont>
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

package GCPlugins::GCgames::GCVGCollect;

use strict;
use utf8;

use GCPlugins::GCgames::GCgamesCommon;

{
    package GCPlugins::GCgames::GCPluginVGCollect;

    use base 'GCPlugins::GCgames::GCgamesPluginsBase';

    use GCUtils;

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            name     => 1,
            platform => 1,
            region   => 1,
        };

        $self->_initFieldsMapping();

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;
        $self->{'searchingResults'} = 1;
        return $html;
    }

    sub getName
    {
        return 'VGCollect';
    }

    sub getAuthor
    {
        return '@gimont';
    }

    sub getLang
    {
        return 'EN';
    }

    sub isPreferred
    {
        return 1;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $self->_loadPlatforms();
        if ($word =~ m/platform%3A(\d+)\+(.*)/)
        {
            my $platform = $1;
            my $game = $2;
            $game =~ s/\s/%20/g;
            return "https://vgcollect.com/search/advanced/".$platform."/".$game."/no-filter/ALL/ALL/ALL/ALL/ALL/no-filter/no-filter/no-filter";
        }
        return 'https://vgcollect.com/search/%22'. $word .'%22';
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
    }

    sub getCharset
    {
        my $self = shift;
        return "UTF-8";
    }

    sub _resolveFieldName
    {
        my ($self, $alias) = @_;
        my $fieldsMapping = $self->{'fieldsMapping'};
        return
            exists $fieldsMapping->{$alias} ?
            $fieldsMapping->{$alias}        :
            undef;
    }

    sub start
    {
        my ($self, $tag, $attr) = @_;

        return if ! $self->{'searchingResults'};
        if ($self->{parsingList})
        {
            if ($tag eq 'div')
            {
                # Parsing pagination
                if (exists $attr->{'class'} && $attr->{'class'} =~ 'paginate')
                {
                    $self->{'insidePagination'} = 1;
                    $self->{'grabNextPage'}     = 0;
                    $self->{'nextUrl'}          = '';
                }

                # Parsing items
                elsif (exists $attr->{'class'} && $attr->{'class'} eq 'item')
                {
                    $self->{'insideItem'}     = 1;
                    $self->{'currentItem'}    = {};
                    $self->{'currentElement'} = '';

                }
                elsif ($self->{'insideItem'})
                {
                    $self->{'insideItem'}++;
                    if (exists $attr->{'class'} && $attr->{'class'} =~ /item-(platform|name)/)
                    {
                        $self->{'currentElement'} = $1;
                    }
                }
            }
            elsif ($tag eq 'h2')
            {
                $self->{'searchingResults'} = 2;
            }
            elsif ($tag eq 'a')
            {
                # Parsing pagination
                if (exists $attr->{'class'} && $attr->{'class'} eq 'active')
                {
                    $self->{'grabNextPage'} = 1;
                }
                elsif ($self->{'grabNextPage'})
                {
                    $self->{'insidePagination'} = 0;
                    $self->{'grabNextPage'}     = 0;
                    $self->{'nextUrl'}          = $attr->{'href'}
                        unless $self->{'nextUrl'} or $attr->{'href'} !~ /http/;
                }

                # Parsing items
                elsif ($self->{'insideItem'})
                {
                    my $item = $self->{'currentItem'};
                    my $fieldName = $self->{'currentElement'};
                    if ($fieldName eq 'name')
                    {
                        $item->{'url'} = $attr->{'href'}
                            unless $item->{'url'};
                    }
                    elsif ($fieldName eq 'platform')
                    {
                        my $platformShortName = $1
                            if $attr->{'href'} =~ /([^\/]+)$/;
                        if ($platformShortName) {
                            my $platform = $self->_resolvePlatformName($platformShortName);
                            $self->_storePlatformAndRegion($item, $platform)
                                if $platform;
                        }
                    }
                }
            }
        }
        else
        {
            if ($tag eq 'h2' && exists $self->{'insideHeader'} && $self->{'insideHeader'})
            {
                $self->{'pickGameName'} = 1;
            }
            elsif ($tag eq 'div')
            {
                if (exists $attr->{'class'} && $attr->{'class'} =~ /item-header/)
                {
                    $self->{'insideHeader'} = 1;
                }
                elsif (exists $attr->{'class'} && $attr->{'class'} =~ /tab-pane/ && exists $attr->{'id'})
                {
                    $self->{'currentTab'} = $attr->{'id'};
                }
                elsif (exists $attr->{'class'} && $attr->{'class'} =~ /item-page-photos/)
                {
                    $self->{'insideImagesDiv'} = 1;
                }
                elsif (exists $self->{'insideImagesDiv'})
                {
                    $self->{'insideImagesDiv'}++;
                    if (exists $attr->{'id'} && $attr->{'id'} =~ /(item-image-(front|back|media))/)
                    {
                        $self->{'currentImage'} = $1;
                    }
                }
            }
            elsif ($tag eq 'td' && exists $self->{'currentTab'})
            {
                $self->{'currentFieldDepth'}++;
            }
            elsif ($tag eq 'img' && exists $self->{'currentImage'} && exists $attr->{'src'})
            {
                my $info  = $self->{'curInfo'};
                my $field = $self->_resolveFieldName($self->{'currentImage'});

                $info->{$field} = $attr->{'src'}
                    if $field;
            }
        }
    }

    sub _trim
    {
        my ($self, $text) = @_;
        chomp($text);
        $text =~ s/^\s+|\s+$//g;  # Remove leading and trailing whitespace
        return $text;
    }

    sub _normalizeDate
    {
        my ($self, $text) = @_;

        my (@dateElements) = split(/\s+/, lc($text));
        my $dateAsText = join(" ", @dateElements);
        my $date = GCDates::strToTime($dateAsText, "%B %e %Y", $self->getLang());

        return $date;
    }

    sub _compareItems {
        my ($self, $itemA, $itemB) = @_;

        for my $field (qw(name platform region)) {
            my $valueA = exists $itemA->{$field} ? $itemA->{$field} : '';
            my $valueB = exists $itemB->{$field} ? $itemB->{$field} : '';
            my $result = $valueA cmp $valueB;
            return $result if $result;
        }

        return 0;
    }

    sub _resolvePlatformName
    {
        my ($self, $shortName) = @_;
        return $self->{'platformMapping'}->{$shortName};
    }

    sub _storePlatformAndRegion {
        my ($self, $item, $text) = @_;

        if ($text =~ /(.+) \[(\w+)\]/)
        {
            $item->{'platform'} = $1;
            $item->{'region'}   = $2;
        }
        else
        {
            $item->{'platform'} = $text;
        }
    }

    sub text
    {
        my ($self, $text) = @_;

        $text = $self->_trim($text);
        return if ! $text || ! $self->{'searchingResults'};

        if ($self->{parsingList})
        {
            if ($self->{'insideItem'})
            {
                if ($self->{'currentElement'})
                {
                    my $item = $self->{'currentItem'};
                    my $fieldName = $self->{'currentElement'};
                    if (!exists $item->{$fieldName})
                    {
                        if ($fieldName eq 'platform' && ! exists $item->{'platform'})
                        {
                            $self->_storePlatformAndRegion($item, $text);
                        }
                        else
                        {
                            $item->{$fieldName} = $text;
                        }
                    }
                }
            }
            elsif ($self->{'searchingResults'} eq 2)
            {
                $self->{'searchingResults'} = ($text =~ m/^0 result/) ? 0 : 3;
            }
        }
        else
        {
            if (exists $self->{'pickGameName'} && $self->{'pickGameName'})
            {
                my $info = $self->{'curInfo'};
                $info->{'name'} = $text
                    if $text ne 'NA';
                delete $self->{'pickGameName'};
                delete $self->{'insideHeader'};
            }
            elsif (exists $self->{'currentFieldDepth'})
            {
                if ($self->{'currentFieldDepth'} == 1 && !exists $self->{'currentField'})
                {
                    my $field = $self->_resolveFieldName($text);

                    $self->{'currentField'} = $field
                        if $field;
                }
                elsif ($self->{'currentFieldDepth'} == 2)
                {
                    if (exists $self->{'currentField'} && $self->{'currentField'} ne '')
                    {
                        if ($text ne 'NA')
                        {
                            my $field = $self->{'currentField'};
                            my $info  = $self->{'curInfo'};

                            if ($field eq 'released')
                            {
                                my $releaseDate = $self->_normalizeDate($text);
                                $info->{$field} = $releaseDate;
                            }
                            elsif ($field eq 'platform')
                            {
                                $self->_storePlatformAndRegion($info, $text);
                            }
                            elsif ($field eq 'description')
                            {
                                my $currentDescription = $info->{'description'};
                                if ($currentDescription) {
                                    $currentDescription .= "\n";
                                }
                                $currentDescription .= $text;
                                $info->{'description'} = $currentDescription;
                            }
                            else
                            {
                                $info->{$field} = $text
                                    if $field;
                            }

                            unless ($field eq 'description')
                            {
                                delete $self->{'currentField'};
                                delete $self->{'currentFieldDepth'};
                            }
                        }
                    }
                }
            }
        }
    }

    sub end {
        my ($self, $tag) = @_;

        if ($self->{parsingList})
        {
            if ($tag eq 'div')
            {
                if ($self->{'insidePagination'})
                {
                    $self->{'insidePagination'}--;
                }
                elsif ($self->{'insideItem'})
                {
                    $self->{'insideItem'}--;
                    if (!$self->{'insideItem'})
                    {
                        push @{$self->{'itemsList'}}, $self->{'currentItem'};
                        $self->{'itemIdx'}     = scalar @{$self->{'itemsList'}} - 1;
                        $self->{'currentItem'} = {};
                    }
                }
            }
            elsif ($tag eq 'html')
            {
                $self->{'itemsList'} = [ sort { $self->_compareItems($a, $b) } @{$self->{'itemsList'}} ];
            }
        }
        else
        {
            if ($tag eq 'html')
            {
                my $info = $self->{'curInfo'};
                delete $info->{''};
            }
            elsif ($tag eq 'div')
            {
                if ($self->{'currentTab'})
                {
                    delete $self->{'currentTab'}
                        if exists $self->{'currentTab'};
                    delete $self->{'currentImage'}
                        if exists $self->{'currentImage'};
                }

                if (exists $self->{'insideImagesDiv'})
                {
                    if ($self->{'currentImage'})
                    {
                        delete $self->{'currentImage'};
                    }

                    $self->{'insideImagesDiv'}--;
                    if (!$self->{'insideImagesDiv'})
                    {
                        delete $self->{'insideImagesDiv'};
                    }
                }
            }
            elsif ($tag eq 'tr' && $self->{'currentFieldDepth'}) {
                delete $self->{'currentField'};
                delete $self->{'currentFieldDepth'};
            }
        }
    }

    sub _initFieldsMapping
    {
        my $self = shift;
        $self->{'fieldsMapping'} = {
            'Barcode:'         => 'ean',
            'Box Text:'        => 'description',
            'Description:'     => 'description',
            'Developer(s):'    => 'developer',
            'Genre:'           => 'genre',
            'Item Number:'     => 'serialnumber',
            'Platform:'        => 'platform',
            'Publisher(s):'    => 'editor',
            'Release Date:'    => 'released',
            'item-image-front' => 'boxpic',
            'item-image-back'  => 'screenshot1',
            'item-image-media' => 'screenshot2',
        };
    }

    sub _loadPlatforms
    {
        my $self = shift;

        return if $self->{'platformMapping'};

        my $browsePage = $self->loadPage("https://vgcollect.com/browse", undef, 1);
        for my $line (split(/\n/, $browsePage))
        {
            next unless $line =~ /browse-child/;
            if ($line =~ /([^"\/]+)"\>(.+?)\</)
            {
                $self->{'platformMapping'}->{$1} = $2;
            }
        }
    }
}

1;
