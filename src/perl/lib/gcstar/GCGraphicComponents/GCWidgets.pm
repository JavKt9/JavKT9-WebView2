package GCWidgets;

###################################################
#
#  Copyright 2005-2016 Christian Jodar
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
use utf8;
use Gtk3;

use strict;

use GCGraphicComponents::GCBasicWidgets;
use GCGraphicComponents::GCDoubleLists;
use GCGraphicComponents::GCPictureWidgets;

sub createWidget
{
    my ($parent, $info, $comparison) = @_;
    my $widget;
    my $withComparisonLabel = 1;

    if ($info->{type} eq 'short text')
    {
        if ($comparison eq 'range')
        {
            $widget = new GCRange('text', $parent->{lang});
            $widget->setWidth(16);
            $withComparisonLabel = 0;
        }
        else
        {
            $widget = new GCShortText;
        }
    }
    elsif ($info->{type} eq 'number')
    {
        #If we want to have values that are less to the specified one,
        #we use max as default to be sure everything will be returned
        #in that case.
        my $default = $info->{min};
        $default = $info->{max}
            if $comparison =~ /^l/;
        if (exists $info->{min})
        {
            if ($comparison eq 'range')
            {
                $widget = new GCRange('number',
                                      $parent->{lang},
                                      $info->{min},
                                      $info->{max},
                                      $info->{step});
                $widget->setWidth(16);
                $withComparisonLabel = 0;
            }
            else
            {
                $widget = new GCNumeric($default,
                                        $info->{min},
                                        $info->{max},
                                        $info->{step});
            }
        }
        else
        {
            if ($comparison eq 'range')
            {
                $widget = new GCRange('numeric text', $parent->{lang});
                $widget->setWidth(16);
                $withComparisonLabel = 0;
            }
            else
            {
                $widget = new GCCheckedText('0-9.');
            }
        }
    }
    elsif ($info->{type} eq 'checked text')
    {
        $widget = new GCCheckedText($info->{format});
    }
    elsif (($info->{type} eq 'history text')
           || (($info->{type} =~ /list/)
               && ($info->{history} ne 'false')))
    {
        $widget = new GCHistoryText;
    }
    elsif ($info->{type} eq 'images')
    {
        $widget = new GCImageListWidget;
    }
    elsif ($info->{type} eq 'options')
    {
        $widget = new GCMenuList;
        $widget->setValues($parent->{model}->getValues($info->{values}), $info->{separator});
    }
    elsif ($info->{type} eq 'yesno')
    {
        $widget = new GCCheckBoxWithIgnore($parent);
        $withComparisonLabel = 0;
    }
    elsif ($info->{type} eq 'date')
    {
    	if ($comparison eq 'range')
        {
            $widget = new GCRange('date', $parent->{lang}, undef, undef, undef, $parent);
            $widget->setWidth(16);
            $withComparisonLabel = 0;
        }
        else
        {
			$widget = new GCDate($parent->{window}, $parent->{lang}, 1,
            	                 $parent->{options}->dateFormat);
        }
    }
    else
    {
        $widget = new GCShortText;
    }
    
    return ($widget, $withComparisonLabel);
}

our $hasSpellChecker;
BEGIN {
    eval 'use Gtk3::Spell';
    if ($@)
    {
        $hasSpellChecker = 0;
    }
    else
    {
        $hasSpellChecker = 1;
    }
}

1;

