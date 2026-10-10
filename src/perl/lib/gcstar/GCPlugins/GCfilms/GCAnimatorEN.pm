package GCPlugins::GCfilms::GCAnimatorEN;

###################################################
#
#  Copyright 2005-2009 zserghei
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
use Encode qw(encode);

use GCPlugins::GCfilms::GCfilmsCommon;
use GCPlugins::GCfilms::GCAnimator;

{

    package GCPlugins::GCfilms::GCPluginAnimatorEN;

    use base qw(GCPlugins::GCfilms::GCPluginAnimator);

    sub getName
    {
        return "AnimatorEN";
    }

    sub getAuthor
    {
        return 'zserghei';
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

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return "http://www.animator.ru/db/?ver=eng&p=search&text=$word";
    }
}

1;
