package GCCustomWidgets;

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

use utf8;
use strict;

{
    package GCRatingWidget;
    
    use Gtk3;
    use POSIX;
    use Cairo::GObject;


    use Glib::Object::Subclass
        Gtk3::DrawingArea::,
        signals => {
            changed => {
                        method      => 'do_rating_changed',
                        flags       => [qw/run-first/],
                        return_type => undef, # void return
                        param_types => [], # instance and data are automatic
            },
            #button_press_event => \&on_click, duplicate of on_release
            button_release_event => \&on_release,
            motion_notify_event => \&on_move,
            leave_notify_event => \&on_leave,
            #size_request => \&do_size_request,
            draw => \&on_expose,
            focus_in_event => \&on_focus,
            key_press_event => \&on_keypress
        },
        properties => [
            Glib::ParamSpec->int (
                'maxStars', # name
                'Max Stars', # nickname
                'Maximum number of stars to show', #blurb
                0, # min
                100, # max
                10, # default
                [qw/readable writable/] #flags
            ),
            Glib::ParamSpec->int (
                'rating', # name
                'Rating', # nickname
                'Current rating', #blurb
                0, # min
                100, # max
                0, # default
                [qw/readable writable/] #flags
            ),
            Glib::ParamSpec->string (
                'direction', # name
                'Direction', # nickname
                'Direction of stars', #blurb
                'LTR', # default
                [qw/readable writable/] #flags
            ),
        ];

    use constant {
        BORDER_WIDTH => 0,
    };


    sub INIT_INSTANCE {
        my $self = shift;

        $self->{maxStars} = 10;
        $self->{rating} = 0;
        $self->{direction} = 'LTR';
        $self->{glowingStars} = 0;

        # Load into some surfaces the graphics for the stars
        $self->{surface} = Cairo::ImageSurface->create_from_png($ENV{GCS_SHARE_DIR}.'/icons/star.png');
        $self->{surfaceDark} = Cairo::ImageSurface->create_from_png($ENV{GCS_SHARE_DIR}.'/icons/stardark.png');
        $self->{surfaceHover} = Cairo::ImageSurface->create_from_png($ENV{GCS_SHARE_DIR}.'/icons/star_hover.png');
        $self->{surfaceDarkHover} = Cairo::ImageSurface->create_from_png($ENV{GCS_SHARE_DIR}.'/icons/stardark_hover.png');
        # Grab width and height of surface
        $self->{surfaceWidth} = $self->{surface}->get_width;
        $self->{surfaceHeight} = $self->{surface}->get_height; 

        # Allow focus
        $self->set_can_focus(1);

        $self->add_events(['exposure-mask',
                           'visibility-notify-mask',
                           'button-press-mask',
                           'button-motion-mask',
                           'button-release-mask',
                           'pointer-motion-mask',
                           'leave-notify-mask',
                           'enter-notify-mask',
                           'key-press-mask'        ]);
         $self->set_size_request(240,24);
    }

    sub GET_PROPERTY
    {
        my ($self, $pspec) = @_;

        if ($pspec->get_name eq 'rating')
        {
            return $self->{rating};
        }
    }

    sub draw_stars
    {
        # Draw the stars on the control 
        my ($self) = @_;

        return if (! $self->{context});
        $self->{rating} = 0 if (! $self->{rating});
        # Make sure we don't try to draw the control before the background has been saved
        my $starSurface;
 
        # For each star, determine which surface to use
        for(my $count = 0; $count < $self->{maxStars}; $count++)
        {
            if ($count < $self->{glowingStars})
            {
                $starSurface = ($count < $self->{rating}) ? $self->{surfaceHover}
                            :                            $self->{surfaceDarkHover};
            }
            else
            {
                $starSurface = ($count < $self->{rating}) ? $self->{surface}
                            :                            $self->{surfaceDark};
            }

            # Put the star in the proper place
            if ($self->{direction} eq 'LTR')
            {
                # Left to Right
                $self->{context}->set_source_surface($starSurface, ($count * $self->{surfaceWidth}) + BORDER_WIDTH, 0);
            }
            else
            {
                # Right to Left
                $self->{context}->set_source_surface($starSurface, $self->get_allocation->{width} - (($count + 1) * $self->{surfaceWidth}) - BORDER_WIDTH,0);
            }
            $self->{context}->paint;
        }
        $self->queue_draw_area(0,0,240,24);
    }

    sub coordToNumberStars
    {
        # Translate an x-coordinate to how many stars it represents
        my ($self, $x) = @_;

        if ($self->{direction} ne 'LTR')
        {
            # Right to Left, easiest just to flip to coordinate over
            $x = $self->get_allocation->{width} - $x;
        }

        if ($x < ($self->{surfaceWidth} / 3))
        {
            # We reserve the first 1/3 of a star to mean "no stars selected"
            return 0;
        }
        else
        {
            my $value = ceil($x / $self->{surfaceWidth});
            return ($value <= $self->{maxStars}) ? $value : $self->{maxStars};
        }
    }

    sub on_expose
    {   
        # Called when control is first drawn
        my ($self, $context) = @_; 
        $self->{context} = $context;
        # Make a small (1x1) surface of the empty control
        $self->draw_stars;
        return 0;
    }

    sub on_leave
    {
        # Called when mouse leaves the control, remove all highlighting
        my ($self, $event) = @_;
        if ($self->has_focus)
        {
            # If control is still focused, leave highlight on selected stars
            $self->{glowingStars} = ($self->{rating} eq 0) ? 1
                           :                          $self->{rating};
        }
        elsif ($event->mode() eq "normal")
        {
            # React to mouse leaving the control when control not focused, clear all highlights
            $self->{glowingStars} = 0;
        }
    }

    sub on_release
    {
        # Called when mouse button released, set rating
        my ($self, $event) = @_;

        my $starsSelected = $self->coordToNumberStars($event->x);
        # alternate the 1st star between on and off
        $starsSelected = 0 if ($starsSelected eq 1 && $self->{rating} eq 1);
        $self->{rating} = $starsSelected;
        $self->{glowingStars} = $starsSelected;
        $self->signal_emit ("changed");
    }

    sub on_move
    {
        # Called when mouse moves on control, change star highlighting if needed
        my ($self, $event) = @_;
       
        $self->{glowingStars} = $self->coordToNumberStars($event->x);
        $self->createTooltip($self->{glowingStars});
    }

    sub createTooltip
    {
        my ($self, $tipValue) = @_;

        if ($self->{direction} eq 'LTR')
        {
            $self->set_tooltip_text($tipValue."/".$self->{maxStars});
        }
        else
        {
            # Hmmm - not sure if a / is the right symbol to use for rtl languages, perhaps it should be a \ ?
            $self->set_tooltip_text($self->{maxStars}."/".$tipValue);
        }
    }

    sub on_focus
    {
        # Called when control focused, change star highlighting
        my ($self, $event) = @_;
        
        #GTK3 : doesn't seem to get focus
    }

    sub on_keypress
    {
        # Called when key pressed
        my ($self, $event) = @_;
        
        #GTK3 not working
        if ( ($event->keyval eq $Gtk3::Gdk::KEY_Right) && ($self->{direction} eq 'LTR') ||
             ($event->keyval eq $Gtk3::Gdk::KEY_Left)  && ($self->{direction} ne 'LTR') )
        {
            # Increase rating
            $self->{rating}++ if $self->{rating} < $self->{maxStars}; 
            $self->{glowingStars} = $self->{rating};
           
            # Cancel key propagation
            return 1;
        }
        elsif ( ($event->keyval eq $Gtk3::Gdk::KEY_Left)  && ($self->{direction} eq 'LTR') ||
                ($event->keyval eq $Gtk3::Gdk::KEY_Right) && ($self->{direction} ne 'LTR') )
        {
            # Decrease rating
            $self->{rating}-- if $self->{rating} > 0; 
            if ($self->{rating} > 0)             
            {
                # If no stars are filled in, we'll just highlight the first star to show control is focused
                $self->{glowingStars} = $self->{rating};
            }
            else
            {                 
                $self->{glowingStars} = 1;                
            }

            # Cancel propagation
            return 1;
       }
    }

    sub set_rating
    {
        # Manual way of setting rating
        my ($self, $rating) = @_;

        $self->{rating} = $rating;
        $self->{glowingStars} = $self->{rating};
        $self->{glowingStars} = 0 if ! $self->{glowingStars};
        $self->draw_stars;
        $self->signal_emit ('changed');
    }
}

1;

