package GCPanel;

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
use Gtk3;
use GCBorrowings;
use GCGraphicComponents::GCWidgets;

use strict;
use GCDates;
use File::Basename ();
use File::Spec ();

{
    package GCItemPanel;

    @GCItemPanel::ISA = ('Gtk3::Frame');
    
    sub new
    {
        my ($proto, $parent, $options, $layout) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();

        bless ($self, $class);

        # GCJav dark mode. Controlled by GCJavTheme.conf next to GCPanel.pm.
        # dark=1 -> prefer GTK dark theme, dark=0 -> normal/light theme.
        if (!$GCItemPanel::GCJAV_THEME_APPLIED)
        {
            my $dark = 1;
            eval {
                my $cfgPath = File::Spec->catfile(
                    File::Basename::dirname(__FILE__),
                    'GCJavTheme.conf'
                );
                if (open(my $themeCfg, '<', $cfgPath))
                {
                    while (my $line = <$themeCfg>)
                    {
                        next if $line =~ /^\s*(?:#|;|$)/;
                        if ($line =~ /^\s*dark\s*=\s*([01])\s*$/i)
                        {
                            $dark = $1;
                            last;
                        }
                    }
                    close($themeCfg);
                }
                my $settings = Gtk3::Settings::get_default();
                $settings->set_property('gtk-application-prefer-dark-theme', $dark ? 1 : 0)
                    if $settings;
            };
            $GCItemPanel::GCJAV_THEME_APPLIED = 1;
        }

        $self->{disableBorrowerChange} = 0;
        $self->{autoUpdate} = 1;
        $self->{previouslyHidden} = 0;

        $self->{expanders} = [];
        $self->{dateFields} = [];
        $self->{longTextFields} = [];
        $self->{formatted} = [];
        #Stores for each fields the widgets which depends on it
        # (used for formatted and launcher)
        $self->{dependencies} = {};

        $self->{parent} = $parent;
        $self->{lang} = $parent->{lang};
        $self->{options} = $options;
        $self->{layout} = $layout;
        $self->set_shadow_type('none');

        $self->{infoBox} = new Gtk3::VBox(1,0);
        $self->{viewAllBox} = new Gtk3::EventBox;
        $self->{viewAllVBox} = new Gtk3::VBox(0,0);
        $self->{viewAll} = new Gtk3::HBox(0,0);
        $self->{viewAllButton} = new Gtk3::Button->new_from_stock('gtk-refresh');
        $self->{viewAll}->pack_start($self->{viewAllButton},1,0,50);
        $self->{viewAllVBox}->pack_start($self->{viewAll},0,0,0);
        $self->{viewAllBox}->add($self->{viewAllVBox});
        $self->{viewAllButton}->signal_connect('clicked' => sub {
            $self->{parent}->viewAllItems;
        });

        $self->{margin} = $GCUtils::margin;
        $self->{halfMargin} = $GCUtils::halfMargin;
        $self->{quarterMargin} = $GCUtils::quarterMargin;

        return $self;
    }

    sub loadStyles
    {
        my ($self, $style) = @_;
    }


    sub setExpandersMode
    {
        my ($self, $mode) = @_;
        $_->setMode($mode)
            foreach (@{$self->{expanders}});
    }

    sub setDateFormat
    {
        my ($self, $format) = @_;
        foreach (@{$self->{dateFields}})
        {
            $_->setFormat($format);
            $_->resetChanged;
        }
    }

    sub setSpellChecking
    {
        my ($self, $activate, $lang) = @_;
        foreach (@{$self->{longTextFields}})
        {
            $_->setSpellChecking($activate, $lang);
        }
    }

    sub createContent
    {
        my ($self, $model) = @_;
        return if $self->{model}
              && ($self->{model}->getName eq $model->getName);

        if ($self->{model})
        {
            my @children = $self->{mainBox}->get_children;
            $self->{mainBox}->remove($_) foreach (@children);
            foreach (@{$self->{toDestroy}})
            {
                $_->destroy if $_;
            }
        }

        $self->{model} = $model;
        $self->{fieldsInfo} = $self->{model}->{fieldsInfo};
        $self->{toDestroy} = [];
        foreach (@{$model->{fieldsNames}})
        {
            $self->{$_} = $self->createItem($self->{model}->{fieldsInfo}->{$_});
            push @{$self->{toDestroy}}, $self->{$_};
            $self->{$_.'Label'} = $self->createLabel($self->{model}->{fieldsInfo}->{$_}, $self->{withSeparator});
            push @{$self->{toDestroy}}, $self->{$_.'Label'};
        }
        $self->createSpecial;

        $self->{displayedValues} = {};
        $self->createLayout($self->{layout}, $self->{layoutBox});

        $self->show_all;
    }

    sub initShow
    {
        my ($self, $show, $hasToShow) = @_;

        $self->{show} = $show;

        if ($hasToShow)
        {
            $self->show_all;
            $self->{infoBox}->hide;
            return 1;
        }
        else
        {
            $self->hide(0);
            $self->{previouslyHidden} = 1;
            return 0;
        }
    }

    sub show
    {
        my $self = shift;
        $self->{mainBox}->show;
        $self->{infoBox}->hide;
        $self->setShowOption($self->{show}, 1) if $self->{previouslyHidden};
        $self->{previouslyHidden} = 0;
    }

    sub setShowOption
    {
        my ($self, $show, $hasToShow) = @_;
        return if ! $self->initShow($show, $hasToShow);
        my %parentsToHide;
        foreach (keys %{$show})
        {
            $self->{$_.'Label'}->hide if (! $show->{$_}) && ($self->{$_.'Label'});
            my $widget = $self->{$_};
            if ($widget)
            {
                if ($show->{$_})
                {
                    # Useful for GCLinkedComponent
                    $widget->show if !$widget->isa('Gtk3::Widget');

                    my $parent = $widget->{realParent};
                    while ($parent)
                    {
                        $parentsToHide{$parent} = 0;
                        $parent = $parent->{realParent};
                    }
                    foreach my $dependency(@{$self->{dependencies}->{$_}})
                    {
                        $parentsToHide{$dependency->{realParent}} = 0;
                    }
                }
                else
                {
                    $widget->hide;
                    my $parent = $widget->{realParent};
                    while ($parent)
                    {
                        $parentsToHide{$parent} = $parent if ! exists $parentsToHide{$parent};
                        $parent = $parent->{realParent};
                        undef $parent if $parent && $parent->isa('Gtk3::Notebook');
                    }
                    foreach my $dependency(@{$self->{dependencies}->{$_}})
                    {
                        $dependency->hide;
                    }
                }
            }
        }

        foreach (keys %parentsToHide)
        {
            $parentsToHide{$_}->hide if ($parentsToHide{$_});
        }

        $self->setShowOptionForSpecials($show, $hasToShow);
    }

    sub setShowOptionForSpecials
    {
        my ($self, $show, $hasToShow) = @_;
    }

    sub hide
    {
        my ($self, $filtering) = @_;
        $self->{infoBox}->show_all;
        if ($filtering)
        {
            $self->{warning}->set_markup('<b>'.$self->{lang}->{AllItemsFiltered}.'</b>');
        }
        else
        {
            $self->{warning}->set_markup($self->{lang}->{Warning}) if !$filtering;
            $self->{viewAllBox}->hide;
        }
        $self->{mainBox}->hide;
    }

    sub showMe
    {
        my $self = shift;
        my $parent = $self->get_parent;
        while ($parent)
        {
           last if ($parent->isa('Gtk3::Window'));
           $parent = $parent->get_parent;
        }
        $parent->present if $parent;
    }

    sub isReadOnly
    {
        return 1;
    }

    sub getAsHash
    {
        my $self = shift;
        my $hash = {};
        $hash->{$_} = $self->$_ foreach(@{$self->{parent}->{model}->{fieldsNames}});
        return $hash;
    }

    sub getValue
    {
        my ($self, $field) = @_;

        return $self->$field;
    }

    sub disableBorrowerChange
    {
        my $self = shift;
        $self->{disableBorrowerChange} = 1;
    }

    sub disableAutoUpdate
    {
        my $self = shift;
        $self->{autoUpdate} = 0;
    }

    sub dataChanged
    {
        my ($self, $info, $withoutPanel) = @_;

        if (!$withoutPanel)
        {
            foreach (@{$self->{expanders}})
            {
                $self->setExpanderLabel($_, 1);
            }
        }
        foreach (@{$self->{formatted}})
        {
            $self->setFormattedLabel($_, 1, $info, $withoutPanel);
        }
    }

    sub createLabel
    {
        my ($self, $info, $withSeparator) = @_;

        my $label = $self->{model}->getDisplayedText($info->{label});
        $label .= $self->{parent}->{lang}->{Separator} if $withSeparator;
        my $widget = new Gtk3::Label($label);
        $widget->set_alignment(0, 0.5);
        return $widget;
    }

    # JAVkt9: estado de expanders por modelo y panel, guardado en el perfil
    # de esta edición (GCS_CONFIG_HOME), no en el archivo de películas.
    sub _javExpanderStateFile
    {
        my $self = shift;
        return undef if !$ENV{GCS_CONFIG_HOME};
        return File::Spec->catfile($ENV{GCS_CONFIG_HOME}, 'JavKT9-expanders.txt');
    }

    sub _javExpanderKey
    {
        my ($self, $title) = @_;
        my $model = $self->{model}->getName;
        my $layout = $self->{layout}->{name} || 'form';
        my $key = join('|', $model, $layout, $title);
        $key =~ s/[\r\n\t]//g;
        return $key;
    }

    sub _javReadExpanderStates
    {
        my $self = shift;
        my %states;
        my $file = $self->_javExpanderStateFile;
        return \%states if !$file || !-f $file;
        if (open(my $fh, '<:encoding(UTF-8)', $file)) {
            while (my $line = <$fh>) {
                $line =~ s/[\r\n]+$//;
                my ($key, $state) = split(/\t/, $line, 2);
                $states{$key} = $state if defined($key) && defined($state) && $state =~ /^[01]$/;
            }
            close $fh;
        }
        return \%states;
    }

    sub _javSaveExpanderState
    {
        my ($self, $key, $state) = @_;
        my $file = $self->_javExpanderStateFile;
        return if !$file;
        my $states = $self->_javReadExpanderStates;
        $states->{$key} = $state ? 1 : 0;
        if (open(my $fh, '>:encoding(UTF-8)', $file)) {
            foreach my $k (sort keys %$states) {
                print $fh $k, "\t", $states->{$k}, "\n";
            }
            close $fh;
        }
    }

    sub createExpander
    {
        my ($self, $label) = @_;

        return new GCExpander($label);
    }

    sub formatLabel
    {
        my ($self, $format, $info) = @_;

        my $label = $format;

        # Remove from format conditional part using this format:
        # =field.....=
        $label =~ s/\=(\w*)([^\=]*)\=/($self->{show}->{$1}) ? $2 : ''/eg;

        # Allow formatting using %fields[format]%
        if ($info)
        {
            $label =~ s/%(.*?)(\[(.*?)\])*%/$3 ? sprintf($3,$info->{$1}) : $info->{$1}/eg;
        }
        else
        {
            $label =~ s/%(.*?)(\[(.*?)\])*%/$3 ? sprintf($3,$self->{$1}->getValue(1)) : $self->{$1}->getValue(1)/eg;
        }
        if ($label =~ /^=(.*)$/)
        {
            $label = eval $1;
        }

        $label =~ s/@(.*?)@/$self->{model}->getDisplayedText($1)/eg;

        # Strings between ^ cannot be on the end or on the beginning.
        # Typically used for separators
        $label =~ s/^\^([^\^]*)\^//;
        $label =~ s/\^([^\^]*)\^$//;
        $label =~ s/\^//g;

        return $label;
    }

    sub setExpanderLabel
    {
        my ($self, $expander, $init) = @_;

        my $count = 0;
        if ($expander->{collapsedTemplate} && $expander->{collapsedTemplate} =~ /^%([^%]*)%$/ )
        {
            if ($self->{$1}->{list}->{data} && ref($self->{$1}->{list}->{data}) eq 'ARRAY')
            {
                $count = scalar @{$self->{$1}->{list}->{data}};
            }
        }

        my $label = "";
        $label = $self->formatLabel($expander->{collapsedTemplate}) if $expander->{collapsedTemplate};

        if ($expander->{collapsedTemplate}
        && ($expander->get_expanded xor $init))
        {
            my $label = $self->formatLabel($expander->{collapsedTemplate});
            $expander->setValue($expander->{originalLabel}.($label ? $self->{parent}->{lang}->{Separator} : ""),
                                $label);
        }
        else
        {
            $expander->setValue($expander->{originalLabel});
            $expander->setValue($expander->{originalLabel}." (".$count.")") if $count;
        }
    }

    sub setAsFormatted
    {
        my ($self, $widget, $name, $format) = @_;
        $widget->{format} = $format;
        $widget->{name} = $name;
        push @{$self->{formatted}}, $widget;
        while ($format =~ /%(.*?)%/g)
        {
            push @{$self->{dependencies}->{$1}}, $widget;
        }
    }

    sub setFormattedLabel
    {
        my ($self, $label, $init, $info, $withoutPanel) = @_;

        my $name = $label->{name};
        if ($withoutPanel)
        {
            $info->{$name} = $self->formatLabel($label->{format}, $info);
        }
        else
        {
            $self->$name($self->formatLabel($label->{format}, $info));
            # We store here the value so it could be used by caller if needed
            # The user is GCData::updateSelectedItemInfoFromPanel
            $info->{$name} = $self->$name if defined $info;
        }
    }

    sub prepareDate
    {
        my ($self, $value) = @_;

        return GCDates::timeToStr($value, $self->{parent}->{options}->dateFormat)
    }

    sub addToContainer
    {
        my ($self, $container, $widget, $info) = @_;
        $info->{expand} = 'default' if !exists $info->{expand};
        # P3: decorative director button wraps the existing editable field.
        # Only the visual container changes; $self->{director} remains intact.
        if ($widget && $widget->{name} && $widget->{name} eq 'director'
            && $self->isa('GCFormPanel') && !$widget->{javP3Wrapped})
        {
            my $original = $widget;
            $original->{javP3Wrapped} = 1;
            my $line = Gtk3::HBox->new(0, 4);
            my $star = Gtk3::Button->new_with_label('☆');
            $star->set_tooltip_text('Agregar o quitar director favorito');
            my $refresh = sub {
                my $name = $original->getValue;
                $name =~ s/^\s+|\s+$//g;
                my $active = 0;
                if (length $name) {
                    eval { require GCJavPersonFavorites;
                        my $store = GCJavPersonFavorites->new();
                        $active = $store->is_favorite('directors', $name); 1;
                    } or warn "P3 director refresh: $@";
                }
                # P9.1: use label markup so the director star has the same
                # clearly visible gold/gray treatment as actor stars.
                my $label = $star->get_child;
                if ($label && $label->isa('Gtk3::Label')) {
                    $label->set_markup($active
                        ? '<span foreground="#f5bd31" size="large"><b>★</b></span>'
                        : '<span foreground="#999999" size="large">☆</span>');
                } else {
                    $star->set_label($active ? '★' : '☆');
                }
                $star->set_sensitive(length($name) ? 1 : 0);
            };
            $original->signal_connect('changed' => sub { $refresh->(); });
            $star->signal_connect('clicked' => sub {
                my $name = $original->getValue;
                $name =~ s/^\s+|\s+$//g;
                return unless length $name;
                eval { require GCJavPersonFavorites;
                    my $store = GCJavPersonFavorites->new();
                    my $active = $store->is_favorite('directors', $name);
                    $store->set_favorite('directors', $name, !$active); 1;
                } or warn "P3 director toggle: $@";
                $refresh->();
            });
            $line->pack_start($original, 1, 1, 0);
            $line->pack_start($star, 0, 0, 0);
            $widget = $line;
            $refresh->();
        }
        if ($container->isa('Gtk3::Notebook'))
        {
            $container->append_page($widget, Gtk3::Label->new($self->{model}->getDisplayedText($info->{title})));
        }
        elsif ($container->isa('Gtk3::Grid'))
        {
            my $left = ($info->{col} ? $info->{col} : 0);
            my $right = $left + ($info->{colspan} ? $info->{colspan} : 1);
            my $top = $info->{row};
            my $bottom = $top + ($info->{rowspan} ? $info->{rowspan} : 1);
            if ($info->{expand} eq 'shrink')
            {
                my $hbox = new Gtk3::HBox(0,0);
                $hbox->pack_start($widget,0,0,0);
                $widget = $hbox;
            }
            $widget->set_hexpand(1) if $info->{expand} eq 'true';
            $widget->set_halign('fill') if $info->{expand} ne 'false';
            if ($info->{expand} eq 'horizontal')
            {
                $widget->set_halign('fill');
                $container->attach($widget, $left, $top, $right-$left, $bottom-$top);
            }
            else
            {
                $container->attach($widget, $left, $top, $right-$left, $bottom-$top);
                $widget->set_vexpand(1) if $info->{expand} eq 'true';
                $widget->set_valign('fill') if $info->{expand} ne 'false';
            }
            $container->queue_resize();
        }
        else
        {
            my $expand = ($info->{expand} eq 'true') ? 1 : 0;
            $widget->set_hexpand($expand);
            if ($container->isa('Gtk3::VBox'))
            {
                my $margin = $self->{halfMargin};
                $margin = 0 if (exists $info->{nomargin}) && ($info->{nomargin} eq 'true');
                if ((exists $info->{place}) && ($info->{place} eq 'end'))
                {
                    $container->pack_end($widget, $expand, $expand, $margin);
                }
                else
                {
                    $container->pack_start($widget, $expand, $expand, $margin);
                }
            }
            else
            {
                my $margin = $self->{halfMargin};
                $margin = 0 if (exists $info->{nomargin}) && ($info->{nomargin} eq 'true');
                if (($container->get_children) && (!$container->get_homogeneous) && ($margin > 0))
                {
                    my $marginBox = new Gtk3::HBox(0,0);
                    $container->pack_start($marginBox, 0, 0, $margin);
                }
                $container->pack_start($widget, $expand, $expand, 0)
                    if ref($widget) ne 'HASH';
            }
        }
    }

    sub setWidgetStyle
    {
        my ($self, $widget, $name, $style) = @_;
    }

    sub getWidget
    {
        my ($self, $field, $info) = @_;
        return $self->{$field};
    }

    sub createLayout
    {
        my ($self, $xml, $container, $parent, $noTab) = @_;
        #
        foreach (@{$xml->{item}})
        {
            my $widget;
            my $box;
            my $isContainer = 0;

            # TODO We should return an error here
            $_->{type} = 'default' if ! exists $_->{type};
            if ($_->{type} =~ m/(formatted|imglink)/)
            {
                my $info = {};
                my $foo = $_;
                if ($_->{type} =~ m/imglink/)
                {
                    $info->{type} = 'image';
                }
                else
                {
                    $info->{type} = 'short text';
                }
                $info->{value} = $_->{name};
                $widget = $self->createItem($info);
                $widget->setWidth($_->{width}) if $_->{width};
                $widget->setHeight($_->{height}) if $_->{height};
                $widget->expand if (exists $_->{expand}) && ($_->{expand} eq 'true');

                $self->{$_->{name}} = $widget;
                $self->setAsFormatted($widget, $_->{name}, $_->{value});
                $_->{for} = $widget->{name};
            }
            elsif ($_->{type} eq 'value')
            {
                $widget = $self->getWidget($_->{for}, $_);
                if ($widget)
                {
                    $widget->setWidth($_->{width}) if $_->{width};
                    $widget->setHeight($_->{height}) if $_->{height};
                    # JavKT9: Comments must remain a visible multiline editor in the personal panel.

                    $widget->{itemsPerRow} = $_->{cols} if $_->{cols};
                    $widget->expand if (exists $_->{expand}) && ($_->{expand} eq 'true');
                    if ($_->{values} || $self->{model}->{fieldsInfo}->{$_->{for}}->{values})
                    {
                        $self->{displayedValues}->{$_->{for}} =
                                $_->{values}
                             || $self->{model}->{fieldsInfo}->{$_->{for}}->{values};
                    }
                    # If the item is related to another, it has to be hidden with it
                    if (exists $self->{model}->{fieldsInfo}->{$_->{for}}->{relatedto})
                    {
                        my $relatedTo = $self->{model}->{fieldsInfo}->{$_->{for}}->{relatedto};
                        push @{$self->{dependencies}->{$relatedTo}}, $widget;
                    }
                }
            }
            elsif ($_->{type} eq 'label')
            {
                if ($_->{for})
                {
                    $widget = $self->{$_->{for}.'Label'};
                }
                else
                {
                    $widget = $self->createLabel($_, $self->{withSeparator});
                }
                if ((exists $_->{align}) && ($_->{align} eq 'center'))
                {
                    $widget->set_alignment(0.5, 0.5);
                    if ($self->{withSeparator})
                    {
                        my $label = $widget->get_label;
                        my $sep = $self->{parent}->{lang}->{Separator};
                        $label =~ s/$sep$//;
                        $widget->set_label($label);
                    }
                }
                $widget->set_alignment(0, 0) if (exists $_->{align}) && ($_->{align} eq 'top');
            }
            elsif ($_->{type} eq 'special')
            {
                $widget = $self->{$_->{for}};
                $widget->{param} = $_->{param};
            }
            elsif ($_->{type} eq 'launcher')
            {
                my $valueWidget = $self->{$_->{for}};
                my $format = $self->{model}->{fieldsInfo}->{$_->{for}}->{format};

                # If the launcher is for a video or music file, label the button 'play'
                if (($format eq 'video') || ($format eq 'audio') || ($format eq 'ebook'))
                {
                    $widget = Gtk3::Button->new_from_stock('gtk-media-play');
                }
                elsif ($format eq 'program')
                {
                    # For program launchers, label the button 'launch'
                    $widget = Gtk3::Button->new($self->{parent}->{lang}->{PanelLaunch});
                }
                else
                {
                    # Label the button 'open'
                    $widget = Gtk3::Button->new_from_stock('gtk-open');
                }

                $widget->signal_connect('clicked' => sub {
                    $self->{parent}->launch($valueWidget->getValue, $format);
                });
                push @{$self->{dependencies}->{$_->{for}}}, $widget;
            }
            elsif ($_->{type} eq 'extractor')
            {
                $widget = Gtk3::Button->new($self->{parent}->{lang}->{ExtractButton});
                my $valueWidget = $self->{$_->{for}};
                $widget->signal_connect('clicked' => sub {
                    $self->{parent}->extractInfo($valueWidget->getValue, $self);
                });
                push @{$self->{dependencies}->{$_->{for}}}, $widget;
            }
            elsif ($_->{type} eq 'line')
            {
                my $homogeneous = (exists $_->{homogeneous} && ($_->{homogeneous} eq 'true'))
                                ? 1 : 0;
                $widget = new Gtk3::HBox($homogeneous, $self->{margin});
                $widget->set_size_request(-1, $_->{height}) if $_->{height};
                $box = $widget;
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'box')
            {
                $widget = new Gtk3::VBox(0,0);
                $box = $widget;
                if ($_->{width})
                {
                    $widget->set_size_request($_->{width}, -1);
                }
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'notebook')
            {
                if ($noTab)
                {
                    $widget = new Gtk3::VBox(0,0);
                }
                else
                {
                    $widget = new Gtk3::Notebook;
                }
                $widget->set_border_width($self->{margin});
                $box = $widget;
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'tab')
            {
                $widget = new Gtk3::VBox(0,0);
                if ((exists $_->{compact}) && ($_->{compact} eq 'true'))
                {
                    $widget->set_vexpand(0);
                    $widget->set_valign('start');
                }
                if ($noTab)
                {
                    my $label = new Gtk3::Label;
                    $label->set_markup('<b>'.$self->{model}->getDisplayedText($_->{title}).'</b>');
                    $label->set_alignment(0,0);
                    $widget->pack_start($label, 0, 0, 0);
                    $widget->set_border_width(0);
                    $box = new Gtk3::VBox(0,0);
                    $box->set_border_width($self->{margin});
                    $widget->pack_start($box, 1, 1, 0);
                }
                else
                {
                    $widget->set_border_width($self->{margin});
                    $box = $widget;
                }
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'table')
            {
                # GTK3 seems to be more strict on the existence of rows and cols
                print "\nDBG GCPanel Table : check rows and cols in model ".$_->{rows}." - ".$_->{cols}
				    if ((! $_->{cols}) || (!  $_->{rows}));
                $_->{cols} = 1 if ! $_->{cols};
                $_->{rows} = 1 if ! $_->{rows};
                $widget = new Gtk3::Grid();
                $widget->set_border_width($self->{margin});
                $widget->set_column_spacing($self->{colSpacing});
                $widget->set_row_spacing($self->{rowSpacing});
                $box = $widget;
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'frame')
            {
                $widget = new GCGroup($self->{model}->getDisplayedText($_->{title}));
                $widget->set_border_width(0);
                $widget->setPadding(0);
                $_->{cols} = 1 if ! $_->{cols};
                $_->{rows} = 1 if ! $_->{rows};
                $box = new Gtk3::Grid();
                $box->set_border_width($self->{halfMargin});
                $box->set_column_spacing($self->{margin});
                $box->set_row_spacing($self->{halfMargin});
                $widget->addWidget($box);
                $isContainer = 1;
            }
            elsif ($_->{type} eq 'expander')
            {
                $widget = $self->createExpander($self->{model}->getDisplayedText($_->{title}));
                $widget->setMode($self->{parent}->{options}->expandersMode);
                $widget->{originalLabel} = $self->{model}->getDisplayedText($_->{title});
                $widget->{collapsedTemplate} = $_->{collapsed};
                $self->setExpanderLabel($widget, 1);
                $widget->signal_connect('activate' => sub {
                    $self->setExpanderLabel($widget, 0);
                });
                # Priorizar la elección guardada; sin preferencias previas,
                # respetar el valor expanded del modelo XML.
                my $expanderKey = $self->_javExpanderKey($_->{title});
                my $expanderStates = $self->_javReadExpanderStates;
                my $initialExpanded = exists($expanderStates->{$expanderKey})
                    ? $expanderStates->{$expanderKey}
                    : ((defined $_->{expanded}) && ($_->{expanded} eq 'true'));
                $widget->set_expanded($initialExpanded ? 1 : 0);
                $widget->signal_connect('notify::expanded' => sub {
                    $self->_javSaveExpanderState($expanderKey, $widget->get_expanded ? 1 : 0);
                });
                push @{$self->{expanders}}, $widget;
                $box = new Gtk3::VBox(0,0);
                $box->set_border_width($self->{halfMargin});
                $widget->add($box);
                $isContainer = 1;
                $_->{style} = 'expander' if !exists $_->{style};
            }

            if (exists $_->{border})
            {
                $widget->set_border_width($_->{border});
            }

            if (exists $_->{collapse})
            {
                $widget->{collapse} = $_->{collapse};
            }

            if ($isContainer)
            {
                $self->createLayout($_, $box, $widget, $noTab);
            }
            push @{$self->{toDestroy}}, $widget;
            $widget->{realParent} = $parent if $parent;
            $self->setWidgetStyle($widget, $_->{for}, $_->{style}) if $_->{style};
            $widget->queue_resize;
            $self->addToContainer($container, $widget, $_) if $widget;
        }
    }
}

{
    package GCReadOnlyPanel;

    use Glib::Object::Subclass
                Gtk3::Frame::
    ;
    @GCReadOnlyPanel::ISA = ('GCItemPanel');

    use File::Basename;
    use GCUtils 'localName';

    sub new
    {
        my ($proto, $parent, $options, $layout) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new($parent, $options, $layout);

        bless ($self, $class);

        $self->{withSeparator} = 0;
        $self->{colSpacing} = $self->{quarterMargin};
        $self->{rowSpacing} = $self->{quarterMargin};
        $self->loadStyles($options->panelStyle);

        $self->{inBox} = new Gtk3::VBox(0, 0);
        $self->{inBox}->set_border_width($self->{margin});
        $self->set_name('GCReadOnlyPanel');

        $self->{inBox} = new Gtk3::VBox(0, 0);
        my $hboxMargins = new Gtk3::HBox(0,0);
        $hboxMargins->pack_start($self->{inBox}, 1, 1, 50);
        $self->{mainBox} = new Gtk3::EventBox;
        $self->{mainBox}->override_background_color('normal', $self->{styles}->{page}->{bgColor});
        $self->{mainBox}->add($hboxMargins);

        my $realMain = new Gtk3::VBox(0,0);

        # GCUtils::setWidgetPixmap($self->{mainBox},$ENV{GCS_SHARE_DIR}.'/logos/splash.png');

        $realMain->pack_start($self->{mainBox},1,1,0);

        $self->{layoutBox} = $self->{inBox};

        $self->add($realMain);
        $self->show_all;

        $self->{warning} = new Gtk3::Label;

        $self->{infoBox}->pack_start($self->{warning},1,1,0);
        $self->{infoBox}->pack_start($self->{viewAllBox},1,1,0);
        $realMain->pack_start($self->{infoBox},1,1,0);

        return $self;
    }

    sub loadStyles
    {
        my ($self, $style) = @_;

        $self->{styles} = {};
        my $styleFile = $ENV{GCS_SHARE_DIR}.'/panels/'.$style;

        open STYLE, localName($styleFile);
        while (<STYLE>)
        {
            chomp;
            next if !$_;
            m/^(.*?)\s*=\s*(.*)$/;
            my $item = $1;
            (my $value = $2) =~ s/^"(.*?)"$/$1/;
            $item =~ /(.*?)(Bg|Color|Style|Justify|Arrow|Prelight)/;
            my $comp = $1;
            my $style = lc $2;
            $self->{styles}->{$comp}->{$style} = $value;
        }
        close STYLE;
        foreach (keys %{$self->{styles}})
        {
            $self->{styles}->{$_}->{bgColor} = Gtk3::Gdk::RGBA::parse($self->{styles}->{$_}->{bg});
            $self->{styles}->{$_}->{style} = $self->{styles}->{$_}->{style}
                                           . " foreground='".$self->{styles}->{$_}->{color}."'";
        }

        eval
        {
            require GCJavSkins;
            GCJavSkins::adjust_panel_styles($self->{styles});
        };
    }

    sub deactivate
    {
        my $self = shift;
    }

    sub getValues
    {
        my ($self, $field) = @_;
        if ($field eq $self->{model}->{commonFields}->{borrower}->{name})
        {
            my $borrowers = $self->{model}->getValues($self->{model}->{commonFields}->{borrower}->{name});
            shift @{$borrowers} if !$borrowers->[0]->{displayed};
            return $borrowers;
        }
        else
        {
            return $self->{$field}->getValues;
        }
    }


    sub selectTitle
    {
        my $self = shift;
        $self->myRealize;
    }

    sub setBorrowers
    {
        my ($self) = @_;
    }

    sub createSpecial
    {
        my $self = shift;
    }

    sub createLabel
    {
        my ($self, $info) = @_;

        my $label = $self->{model}->getDisplayedText($info->{label});
        my $widget = new GCColorLabel($self->{styles}->{label}->{bgColor});
        $widget->set_selectable(0);
        $widget->set_padding(5,5);
        $widget->set_justify('fill');
        $widget->set_markup("<span ".$self->{styles}->{label}->{style}.">".$label.'</span>');
        return $widget;
    }

    sub createExpander
    {
        my ($self, $label) = @_;

        return new GCColorExpander($label,
                                   $self->{styles}->{expander}->{bgColor},
                                   $self->{styles}->{expander}->{style});
    }

    sub setWidgetStyle
    {
        my ($self, $widget, $name, $style) = @_;
        $self->{style}->{$name} = $style;
        if ($self->{styles}->{$style}->{bgColor})
        {
            $widget->override_background_color('normal', $self->{styles}->{$style}->{bgColor});
        }

        if ($widget->isa('GCColorLabel') || $widget->isa('GCColorText'))
        {
            my $justify = $self->{styles}->{$style}->{justify};
            $widget->set_justify($justify) if $justify;
        }

        if ($widget->isa('GCColorExpander'))
        {
            my $arrowColor = Gtk3::Gdk::RGBA::parse($self->{styles}->{expander}->{arrow});
            my $prelightColor;
            if (exists $self->{styles}->{expander}->{prelight})
            {
                $prelightColor = Gtk3::Gdk::RGBA::parse($self->{styles}->{expander}->{prelight});
            }
            else
            {
                $prelightColor = $self->{styles}->{expander}->{bgColor};
            }
            
            $widget->override_background_color('prelight', $prelightColor);
            $widget->get_label_widget->override_background_color('prelight', $prelightColor);
            $widget->override_color('normal', $arrowColor);
            $widget->override_color('prelight', $arrowColor);
        }
    }

    sub createItem
    {
        my ($self, $info) = @_;

        my $widget;

        if ($info->{type} eq 'long text')
        {
            $widget = new GCColorText($self->{styles}->{field}->{bgColor}, 0);
            $self->{style}->{$info->{value}} = 'field';
        }
        elsif ($info->{type} eq 'image')
        {
            $widget = new GCItemImage($self->{parent}->{options},
                                      $self->{parent});
        }
        elsif ($info->{type} eq 'button')
        {
            $widget = new GCButton($self->{model}->getDisplayedText($info->{label}));
        }
        elsif($info->{type} =~ /list$/o)
        {
            my $number = GCUtils::listNameToNumber($info->{type});
            my $label = $self->{model}->getDisplayedText($info->{label});
            undef $label if $number eq 1; # prevent duplication of label
            my @labels;
            for my $i (1..$number)
            {
                push @labels, $self->{model}->getDisplayedText($info->{'label'.$i});
            }
            $widget = new GCColorTable($number, \@labels,
                                       $self->{styles}->{label},
                                       $self->{styles}->{field},
                                       $label);
        }
        elsif ($info->{type} eq 'url')
        {
            $widget = new GCColorLink($self->{styles}->{field}->{bgColor}, $self->{parent});
            $self->{style}->{$info->{value}} = 'field';
            $widget->set_selectable(0);
        }
        else
        {
            # See GCColorLabel constructor for the meaning of listType;
            $widget = new GCColorLabel($self->{styles}->{field}->{bgColor});
            if ($info->{value} eq $self->{model}->{commonFields}->{borrower}->{name})
            {
                $self->{prepare}->{$info->{value}}->{func} = 'prepareBorrower';
            }
            elsif ($info->{type} eq 'date')
            {
                $self->{prepare}->{$info->{value}}->{func} = 'prepareDate';
            }
            $self->{style}->{$info->{value}} = 'field';
            $widget->set_selectable(0);
            $widget->set_padding(5,5);
            $widget->set_justify('fill');
            $self->setAsFormatted($widget, $info->{value}, $info->{init})
                if ($info->{type} =~ m/(formatted|imglink)/);
        }
        $widget->{name} = $info->{value};
        return $widget;
    }

    sub getWidget
    {
        my ($self, $field, $info) = @_;

        my $widget = $self->{$field};
        if ($info->{height} && $widget->isa('GCColorLabel'))
        {
            my $style = $info->{style};
            $style = 'field' if !$style;
            $widget->destroy;
            $widget = new GCColorText($self->{styles}->{$style}->{bgColor}, 0);
            $widget->{name} = $self->{$field}->{name};
            $self->{$field} = $widget;
        }
        elsif ($widget->isa('GCColorTable') && ($info->{flat} eq 'true'))
        {
            my $columns = $widget->{number};
            $widget->destroy;
            $self->{prepare}->{$field}->{func} = 'prepareMultipleList';
            $self->{prepare}->{$field}->{extra} = $columns;
            if ($info->{height})
            {
                $widget = new GCColorText($self->{styles}->{field}->{bgColor}, 0, $columns);
            }
            else
            {
                $widget = new GCColorLabel($self->{styles}->{field}->{bgColor}, $columns);
                $widget->set_selectable(0);
                $widget->set_padding(5,5);
                $widget->set_justify('fill');
            }
            $self->{style}->{$field} = 'field';
            $self->{$field} = $widget;
        }

        return $widget;
    }

    sub prepareMultipleList
    {
        my ($self, $value, $extra) = @_;
        return GCPreProcess::multipleList($value, $extra);
    }

    sub prepareBorrower
    {
        my ($self, $value) = @_;

        $value = $self->{lang}->{PanelNobody} if $value eq 'none';
        $value = $self->{lang}->{PanelUnknown} if $value eq 'unknown';
        return $value;
    }

    sub AUTOLOAD
    {
        return if our $AUTOLOAD =~ /::DESTROY$/;
        (my $name = $AUTOLOAD) =~ s/.*?::(.*)/$1/;
        return if !$name;
        no strict 'refs';

        *{$AUTOLOAD} = sub {
            my $self = shift;
            return 0 if !$self->{$name};
            return $self->{$name.'Value'}
                if !(scalar @_);
            my $text = shift;
            $self->{$name.'Value'} = $text;
            if (my $func = $self->{prepare}->{$name}->{func})
            {
                $text = $self->$func($text, $self->{prepare}->{$name}->{extra});
            }
            $text = ' ' if ! defined $text;
            $text = $self->{model}->getDisplayedValue($self->{displayedValues}->{$name}, $text)
                if ($self->{displayedValues}->{$name});
            if ($self->{$name})
            {
                # Hide collapsible fields if the field is empty
                if (($text !~ m/\S+/) && ($self->{$name}->{collapse}))
                {
                    $self->{$name}->hide;
                }
                else
                {
                    # Otherwise, make sure the field is shown
                    $self->{$name}->show;
                }

                if ($self->{$name}->acceptMarkup)
                {
                    $self->{$name}->setMarkup("<span ".
                                              $self->{styles}->{$self->{style}->{$name}}->{style}.
                                              ">".$self->{$name}->cleanMarkup($text, 1).'</span>');
                }
                else
                {
                    $self->{$name}->setValue($text);
                }
                #$self->{$name}->resetChanged;
            }
        };
        goto &{$AUTOLOAD};
    }
}


{
    package GCFormPanel;

    use Glib::Object::Subclass
                Gtk3::Frame::
    ;
    @GCFormPanel::ISA = ('GCItemPanel');

    sub createSpecial
    {
        my $self = shift;

        $self->{mailButton} = new GCButton($self->{parent}->{lang}->{MailTitle});
        $self->{mailButton}->signal_connect('clicked' => sub {
            $self->sendBorrowerEmail;
        });
        push @{$self->{toDestroy}}, $self->{mailButton};

        $self->{itemBackButton} = new GCButton($self->{parent}->{lang}->{PanelReturned});
        $self->{itemBackButton}->signal_connect('clicked' => sub {
            $self->itemBack;
        });
        push @{$self->{toDestroy}}, $self->{mailButton};

        $self->{searchButton} = new GCButton($self->{parent}->{lang}->{PanelSearchButton});
        $self->{searchButton}->signal_connect('clicked' => sub {
            warn "GCJav: Descargar clicked
";
            $self->searchItem('gcjav');
        });
        my @subMenuSearch;
        $subMenuSearch[0]=Gtk3::ImageMenuItem->new_with_mnemonic($self->{parent}->{lang}->{PanelSearchContextChooseOne});
        $subMenuSearch[0]->signal_connect("activate" , sub {$self->searchItem('ask')});
        
        $subMenuSearch[1]=Gtk3::ImageMenuItem->new_with_mnemonic($self->{parent}->{lang}->{PanelSearchContextMultiSite});
        $subMenuSearch[1]->signal_connect("activate" ,sub {$self->searchItem('multi')});
        
        $subMenuSearch[2]=Gtk3::ImageMenuItem->new_with_mnemonic($self->{parent}->{lang}->{PanelSearchContextMultiSitePerField});
        $subMenuSearch[2]->signal_connect("activate" ,sub {$self->searchItem('multiperfield')});
        
        $subMenuSearch[3]=Gtk3::ImageMenuItem->new_with_mnemonic($self->{parent}->{lang}->{PanelSearchContextOptions});
        $subMenuSearch[3]->signal_connect("activate" ,sub {$self->{parent}->options(0,3)});

        # GCJav: JavLibrary is the only provider; no legacy provider menu.
        $self->{searchButton}->set_tooltip_text($self->{parent}->{lang}->{PanelSearchTip});
        push @{$self->{toDestroy}}, $self->{searchButton};

        $self->{deleteButton} = GCButton->newFromStock('gtk-delete');
        $self->{deleteButton}->signal_connect("clicked" => \&deleteItem, $self);
        $self->{deleteButton}->set_tooltip_text($self->{parent}->{lang}->{PanelRemoveTip});
        push @{$self->{toDestroy}}, $self->{deleteButton};

        $self->{refreshButton} = new GCButton($self->{parent}->{lang}->{PanelRefresh});
        $self->{refreshButton}->signal_connect("clicked" => sub {
            warn "GCJav: Update clicked
";
            $self->searchItem('gcjav');
        });
        $self->{refreshButton}->set_tooltip_text($self->{parent}->{lang}->{PanelRefreshTip});
        push @{$self->{toDestroy}}, $self->{refreshButton};
    }

    sub new
    {
        my ($proto, $parent, $options, $layout) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new($parent, $options, $layout);

        bless ($self, $class);

        $self->set_name('GCFormPanel');

        $self->{withSeparator} = 1;
        $self->{locked} = 0;
        $self->{colSpacing} = $self->{margin};
        $self->{rowSpacing} = $self->{halfMargin};

        $self->{mainBox} = new Gtk3::VBox(0, 0);
        $self->{mainBox}->set_border_width($self->{margin});

        my $realMain = new Gtk3::VBox(0,0);

        $realMain->pack_start($self->{mainBox},1,1,0);
        $self->{layoutBox} = $self->{mainBox};

        $self->add($realMain);
        $self->show_all;

        $self->{warning} = new Gtk3::Label;
        
        $self->{infoBox}->pack_start($self->{warning},1,1,0);
        $self->{infoBox}->pack_start($self->{viewAllBox},1,1,0);
        $realMain->pack_start($self->{infoBox},1,1,0);

        return $self;
    }

    sub isReadOnly
    {
        return 0;
    }

    sub searchItem
    {
        my ($self, $pluginType) = @_;

        if ($pluginType eq 'refresh')
        {
            $self->{parent}->refreshItemForPanel($self, $self->{$self->{model}->{commonFields}->{url}}->getValue);
        }
        else
        {
            $self->{parent}->searchItemForPanel($self, $pluginType);
            $self->showMe;
        }
    }

    sub checkBorrowerButtons
    {
        my $self = shift;
        my $borrowerField = $self->{model}->{commonFields}->{borrower}->{name};
        return if ! $self->{$borrowerField};
        my $locked = (($self->{$borrowerField}->getValue eq 'none')
                   || ($self->{$borrowerField}->getValue eq 'unknown'));
        $self->{mailButton}->lock($locked)
            if $self->{mailButton};
        $locked = ($self->{locked} || ($self->{$borrowerField}->getValue eq 'none'));
        $self->{itemBackButton}->lock($locked)
            if $self->{itemBackButton};
    }

    sub itemBack
    {
        my $self = shift;

        my $isBack = 0;
        my $dialog = new GCDateSelectionDialog($self->{parent}, $self->{lang}->{PanelReturned});
        if ($dialog->show)
        {
            my $borrowerField = $self->{model}->{commonFields}->{borrower}->{name};
            my $lendDateField = $self->{model}->{commonFields}->{borrower}->{date};
            my $borrowingsField = $self->{model}->{commonFields}->{borrower}->{history};
            my @data = ($self->{$borrowerField}->getDisplayedValue,
                        $self->{$lendDateField}->getValue,
                        $dialog->date);
            foreach (@data[1..2])
            {
                $_ = $self->prepareDate($_);
            }
            $self->{$borrowingsField}->addValues(@data);
            my $previous = $self->getAsHash;
            $self->{$borrowerField}->setValue('none');
            $self->{$lendDateField}->clear;
            my $new = $self->getAsHash;
            $isBack = 1;
        }
        $self->showMe;
        return $isBack;
    }

    sub lock
    {
        my ($self, $value) = @_;
        $self->changeState($self, $value);
    }

    sub deactivate
    {
        my $self = shift;
        $self->changeState($self,1);
    }

    sub changeState
    {
        my ($caller, $self, $locked)  = @_;
        $locked = 1 if $self->{parent}->{items}->getLock;
        return if $self->{locked} == $locked;
        $self->{locked} = $locked;
        my $info;
        foreach (@{$self->{parent}->{model}->{fieldsNames}})
        {
            $info = $self->{model}->{fieldsInfo}->{$_};
            next if $info->{type} eq 'button';
            $self->{$_}->lock($locked) if ($self->{$_});
        }

        $self->{searchButton}->lock($locked);
        $self->checkBorrowerButtons;
        $self->{deleteButton}->lock($locked);
        $self->{refreshButton}->lock($locked);
    }

    sub setShowOptionForSpecials
    {
        my ($self, $show, $hasToShow) = @_;

        if (   ! $self->{model}->{commonFields}->{borrower}->{name}
            && ! $show->{$self->{model}->{commonFields}->{borrower}->{name}})
        {
            $self->{mailButton}->hide;
            $self->{itemBackButton}->hide;
        }
    }

    sub setBorrowers
    {
        my $self = shift;

        return if ! $self->{borrowerControl};

        my $borrowers = $self->{model}->getValues($self->{model}->{commonFields}->{borrower}->{name});
        shift @{$borrowers} if !$borrowers->[0]->{displayed};
        $self->{borrowerControl}->setValues($borrowers);

        return;
    }

    sub sendBorrowerEmail
    {
        use GCDialogs;

        my $self = shift;

        my %info;
        $info{title} = $self->{$self->{model}->{commonFields}->{title}}->getValue;
        $info{borrower} = $self->{$self->{model}->{commonFields}->{borrower}->{name}}->getValue;
        $info{lendDate} = $self->prepareDate(
            $self->{$self->{model}->{commonFields}->{borrower}->{date}}->getValue
        );
        $self->{parent}->sendBorrowerEmail(\%info);
    }

    sub selectTitle
    {
        my $self = shift;
        my $titleField = $self->{model}->{commonFields}->{title};
        $self->{$titleField}->selectAll;
    }

    sub deleteItem
    {
       my ($widget, $self) = @_;

       $self->{parent}->deleteCurrentItem;
    }

    sub createItem
    {
        my ($self, $info) = @_;

        my $widget;

        if (exists $info->{linkedto})
        {
            $widget = new GCLinkedComponent($self->{$info->{linkedto}});
        }
        elsif ($info->{type} eq 'short text')
        {
            $widget = new GCShortText;
            $widget->signal_connect('activate', sub {
                # Enter debe usar el mismo proveedor que Descargar y Update.
                $self->searchItem('gcjav');
            }) if $self->{model}->isSearchField($info->{value});
        }
        elsif ($info->{type} eq 'long text')
        {
            $widget = new GCLongText;
            $widget->setSpellChecking($self->{parent}->{options}->spellCheck);
            push @{$self->{longTextFields}}, $widget;
        }
        elsif ($info->{type} eq 'history text')
        {
            $widget = new GCHistoryText;
        }
        elsif ($info->{type} eq 'options')
        {
            $info->{values} = $info->{value} if !$info->{values};
            if (   $self->{model}->{commonFields}->{borrower}->{name}
                && $info->{value} eq $self->{model}->{commonFields}->{borrower}->{name})
            {
                $widget = new GCMenuList;
                #When borrower not found, we use the last choice: unknown
                $widget->setLastForDefault;
                $self->{borrowerControl} = $widget;
                $widget->signal_connect('changed' => sub {
                    $self->checkBorrowerButtons;
                });
                $self->setBorrowers;
            }
            else
            {
                $widget = new GCMenuList($self->{model}->getValues($info->{values}), $info->{separator});
            }
        }
        elsif ($info->{type} =~ /list$/o)
        {
            my $number;
            my $readonly = 0;
            my $withHistory = 1;
            my @types;
            my @labels;
            $withHistory = 0
                if (exists $info->{history}) && ($info->{history} eq 'false');
            $readonly = 1
                if $info->{value} eq $self->{model}->{commonFields}->{borrower}->{history};
            $number = GCUtils::listNameToNumber($info->{type});
            @types=split / / ,$info->{subtypes} if $info->{subtypes};
            my $typesRef = \@types;
            undef $typesRef if scalar(@types)!=$number;
            if ($number == 1)
            {
                @labels = ($self->{model}->getDisplayedText($info->{label}));
            }
            else
            {
                for my $i (1..$number)
                {
                    push @labels, $self->{model}->getDisplayedText($info->{'label'.$i});
                }
            }
            $widget = new GCMultipleList($self, $number, \@labels, $withHistory, $readonly,0,$typesRef);
            # P8c: visible star per actress; safe activation uses row-activated.
            if ($info->{value} eq 'actors' && $number >= 1)
            {
                my $list = $widget->{list};
                my $renderer = Gtk3::CellRendererText->new;
                $renderer->set(xalign => 0.5, 'ypad' => 3);
                my $column = Gtk3::TreeViewColumn->new;
                $column->set_title('★');
                $column->set_sizing('fixed');
                # La columna de estrella es estrecha; nunca debe ocupar
                # el ancho sobrante del TreeView.
                $column->set_fixed_width(36);
                $column->set_min_width(36);
                $column->set_max_width(36);
                $column->set_expand(0);
                $column->pack_start($renderer, 0);
                $column->set_cell_data_func($renderer, sub {
                    my ($col,$cell,$model,$iter)=@_;
                    my $name=$model->get($iter,0);
                    my $active=0;
                    if (defined $name && length $name) {
                        eval { require GCJavPersonFavorites; my $store=GCJavPersonFavorites->new();
                               $active=$store->is_favorite('actors',$name); 1; }
                            or warn "P8 actors render: $@";
                    }
                    $cell->set(markup => $active
                        ? '<span foreground="#f5bd31" size="x-large"><b>★</b></span>'
                        : '<span foreground="#999999" size="x-large">☆</span>');
                });
                $list->append_column($column);
                # Columna vacia flexible: absorbe el espacio libre, NO la estrella.
                my $filler = Gtk3::TreeViewColumn->new;
                $filler->set_sizing('fixed');
                $filler->set_fixed_width(1);
                $filler->set_expand(1);
                $filler->pack_start(Gtk3::CellRendererText->new, 1);
                $list->append_column($filler);
                # P9: consume a click on the star BEFORE Gtk selects the row.
                # Normal clicks on the actress name still select the row for Add/Remove.
                $list->signal_connect('button-press-event' => sub {
                    my ($tree,$event)=@_;
                    return 0 unless $event->button == 1;
                    my ($path,$hit_column) = $tree->get_path_at_pos($event->x,$event->y);
                    return 0 unless defined $path && defined $hit_column;
                    my $title=eval { $hit_column->get_title } || '';
                    return 0 unless $title eq '★';

                    my $model=$tree->get_model;
                    my $iter=$model->get_iter($path);
                    return 1 unless $iter;
                    my $name=$model->get($iter,0);
                    return 1 unless defined $name && $name =~ /\S/;
                    $name =~ s/^\s+|\s+$//g;
                    eval {
                        require GCJavPersonFavorites;
                        my $store=GCJavPersonFavorites->new();
                        my $active=$store->is_favorite('actors',$name);
                        $store->set_favorite('actors',$name,!$active);
                        1;
                    } or warn "P9 actors toggle: $@";
                    # El click en favoritos no debe dejar la fila entera azul.
                    $tree->get_selection->unselect_all;
                    $tree->queue_draw;
                    return 1; # no seleccionar la fila por pulsar la estrella
                });
            }
        }
        elsif ($info->{type} eq 'images')
        {
            $widget = new GCImageListWidget($self->{parent},0,$info);
        }
        elsif ($info->{type} eq 'checked text')
        {
            $widget = new GCCheckedText($info->{format});
            $widget->signal_connect('activate', sub {
                $self->searchItem('gcjav');
            }) if $self->{model}->isSearchField($info->{value});
        }
        elsif ($info->{type} eq 'number')
        {
            if ($info->{displayas} && ($info->{displayas} eq 'graphical')
             && ($self->{parent}->{options}->useStars))
            {
                $widget = new GCNumeric($info->{init}, 0, $info->{max}, 0, 'graphical');
            }
            else
            {
                if ((exists $info->{min}) && ($info->{min} ne ''))
                {
                    $widget = new GCNumeric($info->{init},
                                            $info->{min},
                                            $info->{max},
                                            $info->{step},
                                            'text');
                }
                else
                {
                    $widget = new GCCheckedText('0-9/.');
                    $widget->setReadOnly
                        if ($info->{value} eq $self->{model}->{commonFields}->{id});
                }
                $widget->signal_connect('activate', sub {
                    $self->searchItem('gcjav');
                }) if $self->{model}->isSearchField($info->{value});
            }
        }
        elsif ($info->{type} eq 'image')
        {
            my $img = new GCItemImage($self->{parent}->{options},
                                      $self->{parent});
            my $isCover = 0;
            $isCover = 1 if $info->{value} eq $self->{model}->{commonFields}->{cover};
            #$img->setImmediate if $isCover;
            my $miniatureField = $info->{value} if ($info->{miniature} && $info->{miniature} eq "true"); # image can be used for image list
            $widget = new GCImageButton($self, $img, $isCover, $info->{default}, $miniatureField);
        }
        elsif ($info->{type} eq 'button')
        {
            if ($info->{format} eq 'url')
            {
                $widget = new GCUrlButton($self->{model}->getDisplayedText($info->{label}),
                                          $self->{parent});
                $info->{tip} = $self->{lang}->{PanelWebTip}
                    if $info->{value} eq $self->{model}->{commonFields}->{url};
            }
            else
            {
                $widget = new GCButton($self->{model}->getDisplayedText($info->{label}));
            }
        }
        elsif ($info->{type} eq 'url')
        {
            $widget = new GCUrl($self->{parent});
        }
        elsif ($info->{type} eq 'yesno')
        {
            $widget = new GCCheckBox($self->{model}->getDisplayedText($info->{label}));
        }
        elsif ($info->{type} eq 'file')
        {
            $widget = new GCFile($self, undef, undef, undef, undef, 1, $info->{format});
        }
        elsif ($info->{type} eq 'date')
        {
            $widget = new GCDate($self, $self->{lang},
                                 $self->{parent}->{options}->dateFormat);
            push @{$self->{dateFields}}, $widget;
        }
        elsif ($info->{type} eq 'formatted')
        {
            $widget = new GCShortText;
            $widget->setReadOnly;
            $self->setAsFormatted($widget, $info->{value}, $info->{init});
        }
        elsif ($info->{type} eq 'imglink')
        {
            $info->{type} = 'image';
            $widget = $self->createItem($info);
            # $widget->setReadOnly;
            $self->setAsFormatted($widget, $info->{value}, $info->{init});
        }
        else
        {
            print "\n!!!!!!!!!!!!!! Invalid type : ",$info->{type}," for ",$info->{value},"\n";
            $widget = 0;
        }

        $widget->{name} = $info->{value} if $widget;
        $widget->set_tooltip_text($self->{model}->getDisplayedText($info->{tip}))
            if $info->{tip};
        $widget->activateStateTracking;
        return $widget;
    }

    sub getValues
    {
        my ($self, $field) = @_;
        return $self->{$field}->getValues
            if exists $self->{$field};
        return [];
    }

    sub AUTOLOAD
    {
        return if our $AUTOLOAD =~ /::DESTROY$/;
        (my $name = $AUTOLOAD) =~ s/.*?::(.*)/$1/;
        return if !$name;
        my $self = $_[0];
        no strict 'refs';
        {
            *{$AUTOLOAD} = sub {
                my $self = shift;
                return 0 if !$self->{$name};
                return $self->{$name}->getValue
                    if !(scalar @_);
                $self->{$name}->setValue(shift);
            };
        }
        goto &{$AUTOLOAD};
    }
}

1;
