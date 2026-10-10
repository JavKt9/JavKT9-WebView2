package GCSplash;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
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
use Gtk3;

{
    package GCSplashWindow;
    use GCUtils;
    use base "Gtk3::Window";
    
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{parent} = shift;
        $self->{version} = shift;

        $self->{splashImage} = $self->{parent}->{logosDir}.'splash.png';

        $self->set_decorated(0);
        $self->set_resizable(0);
        $self->set_transient_for($self->{parent});
        $self->set_destroy_with_parent(1);
        $self->set_modal(1);
        $self->set_skip_taskbar_hint(1);

        #$self->set_position('center-always');
        $self->set_keep_above(1);
        
        # JavKT9 native splash. It no longer shows the old GCstar artwork.
        $self->{title} = new Gtk3::Label;
        $self->{title}->set_markup(
            '<span size="36000" weight="bold" color="#FFFFFF">JavKT9</span>'
        );

        $self->{subtitle} = new Gtk3::Label;
        $self->{subtitle}->set_markup(
            '<span size="12000" weight="bold" color="#D9D2FF">JAV Collection Manager</span>'
        );

        $self->{label} = new Gtk3::Label('Iniciando JavKT9...');

        $self->{vbox} = new Gtk3::VBox(0,0);

        $self->{progress} = new Gtk3::ProgressBar;
        $self->{progress}->set_size_request(280,8);

        my $color_bg = Gtk3::Gdk::RGBA::parse('#241B4B');
        my $color_fg = Gtk3::Gdk::RGBA::parse('#FFFFFF');
        my $color_progress_bg = Gtk3::Gdk::RGBA::parse('#40346E');
        my $color_progress_fg = Gtk3::Gdk::RGBA::parse('#8F75FF');

        $self->{label}->override_color('normal', $color_fg);
        $self->{progress}->override_background_color('normal', $color_progress_bg);
        $self->{progress}->override_background_color('active', $color_progress_fg);
        $self->{progress}->override_background_color('prelight', $color_progress_fg);

        my $eventbox = Gtk3::EventBox->new();
        $eventbox->set_size_request(360,235);
        $eventbox->override_background_color('normal', $color_bg);

        my $inbox = new Gtk3::Fixed;
        $eventbox->add($inbox);

        $self->{title}->set_size_request(360,-1);
        $self->{subtitle}->set_size_request(360,-1);
        $self->{label}->set_size_request(360,-1);

        $inbox->put($self->{title},0,45);
        $inbox->put($self->{subtitle},0,100);
        $inbox->put($self->{label},0,150);
        $inbox->put($self->{progress},40,190);

        $self->{vbox}->pack_start($eventbox,0,0,0);
	    
        $self->add($self->{vbox});
        my $drawing_area = Gtk3::DrawingArea->new;
        $self->{vbox}->pack_start($drawing_area,0,0,0);
        $drawing_area->realize;
		
        $self->set_position('center');
        $self->{vbox}->show_all;
        $self->show;
        # JavKT9 splash widths were set above.
        
        return $self;
    }

    sub init
    {
        my $self = shift;

        if ($self->{phase} == 0)
        {
            $self->setLabel($self->{parent}->{lang}->{SplashInit});
            $self->{phase} = 1;
        }
        elsif ($self->{phase} == 1)
        {
            $self->setProgress(0.0);
            $self->{parent}->init($self);
            $self->setProgress(0.1);
            $self->{phase} = 2;
            $self->setLabel($self->{parent}->{lang}->{SplashLoad});
        }
        elsif ($self->{phase} == 2)
        {
            $self->{parent}->loadPrevious($self);
            $self->setProgress(0.7);
#            $self->{parent}->setSensitive(1);
            $self->{phase} = 3;
            $self->setLabel($self->{parent}->{lang}->{SplashSort});
        }
        elsif ($self->{phase} == 3)
        {
            $self->{parent}->initEnd;
            $self->setProgress(1.0);
            $self->{parent}->setSensitive(1);
            $self->{phase} = 4;
            $self->setLabel($self->{parent}->{lang}->{SplashDone});
        }
        else
        {
            $self->hide;
            $self->{parent}->{initializing} = 0;
            Glib::Timeout->add(700 ,\&destroyMe, $self);
            return 0;
        }
        Glib::Timeout->add(100 ,\&init, $self);           

        return 0;
    }

    sub setLabel
    {
        my ($self, $text) = @_;
        #$text =~ s|^(.)|<span size="x-large" color="#cdad00">$1</span>|;
        $self->{label}->set_markup('<b>'.$text.'</b>');    
    }

    sub setItemsTotal
    {
        my ($self, $total) = @_;
        $self->{step} = GCUtils::round($total / 7);
        $self->{step} = 1 if $self->{step} < 1;
        $self->{total} = $total;
    }

    sub setProgressForItemsLoad
    {
        my ($self, $current) = @_;
        if (! $self->{total})
        {
            $self->{progress}->set_fraction(0.2);
        }
        else
        {
            return if ($current % $self->{step});
            $self->setLabel($self->{parent}->{lang}->{SplashLoad}." <span color='#cdad00'>($current/".$self->{total}.')</span>');
            $self->{progress}->set_fraction(0.1 + (($current / $self->{total}) * 0.3));
        }
        GCUtils::updateUI;
    }

    sub setProgressForItemsDisplay
    {
        my ($self, $current) = @_;
        if (! $self->{total})
        {
            $self->{progress}->set_fraction(0.6);
        }
        else
        {
            return if ($current % $self->{step});
            $self->setLabel($self->{parent}->{lang}->{SplashDisplay}." <span color='#cdad00'>($current/".$self->{total}.')</span>');
            $self->{progress}->set_fraction(0.4 + (($current / $self->{total}) * 0.3));
        }
        GCUtils::updateUI;
    }

    sub setProgressForItemsSort
    {
        my ($self, $current) = @_;
        if (! $self->{total})
        {
            $self->{progress}->set_fraction(0.8);
        }
        else
        {
            return if ($current % $self->{step});
            $self->setLabel($self->{parent}->{lang}->{SplashSort}." <span color='#cdad00'>($current/".$self->{total}.')</span>');
            $self->{progress}->set_fraction(0.7 + (($current / $self->{total}) * 0.2));
        }
        GCUtils::updateUI;
    }

    sub setProgress
    {
        my ($self, $current) = @_;
        $self->{progress}->set_fraction($current);
        GCUtils::updateUI;
    }

    sub destroyMe
    {
        my $self = shift;
        
        $self->destroy;
        return 0;
    }

    sub show
    {
        my $self = shift;

        $self->SUPER::show_all;
        $self->{phase} = 0;
        Glib::Timeout->add(10 ,\&init, $self);
    }
}

1;
