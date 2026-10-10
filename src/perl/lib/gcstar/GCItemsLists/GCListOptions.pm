package GCListOptions;

###################################################
#
#  Copyright 2005-2011 Christian Jodar
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
    package GCListOptionsPanel;
    use base "Gtk3::Frame";
    
    sub setView
    {
        my ($self, $view) = @_;
        if ((!exists $self->{currentView}) || ($view != $self->{currentView}))
        {
            $self->{currentView} = $view;
            if ($self->{panel})
            {
                $self->{scroll}->remove(($self->{scroll}->get_children)[0]);
                $self->{panel}->destroy;
            }
            
            $self->{cancel}->set_sensitive(1);
            $self->{apply}->set_sensitive(1);
    
            if ($view == 0)
            {
                $self->{panel} = new GCEmptyOptionsPanel($self->{parent}->{model}->{preferences}, $self->{parent});
                $self->{cancel}->set_sensitive(0);
                $self->{apply}->set_sensitive(0);
            }
            elsif ($view == 1)
            {
                $self->{panel} = new GCImagesOptionsPanel($self->{parent}->{model}->{preferences}, $self->{parent});
            }
            else
            {
                $self->{panel} = new GCDetailedOptionsPanel($self->{parent}->{model}->{preferences}, $self->{parent});
            }
            $self->{scroll}->add_with_viewport($self->{panel});
            ($self->{scroll}->get_child)[0]->set_shadow_type('none');
        }
        $self->{panel}->initValues;
    }
    
    sub new
    {
        my ($proto, $optionsManager, $parent) = @_;
        my $class = ref($proto) || $proto;
        
        my $self  = $class->SUPER::new;
        $self->{optionsManager} = $optionsManager;
        $self->{parent} = $parent;
        $self->{scroll} = new Gtk3::ScrolledWindow;
        $self->{scroll}->set_policy ('automatic', 'automatic');
        $self->{scroll}->set_shadow_type('none');
        $self->{hboxButtons} = new Gtk3::HBox(0,0);
        $self->{cancel} = GCButton->newFromStock('gtk-clear');
        $self->{apply} = GCButton->newFromStock('gtk-apply'); #GTK3 : deprecated stock
        
        $self->{vbox} = new Gtk3::VBox(0,0);

        $self->{hboxButtons}->pack_end($self->{apply}, 0, 0, $GCUtils::halfMargin);
        $self->{hboxButtons}->pack_end($self->{cancel}, 0, 0, $GCUtils::halfMargin);
        $self->add($self->{vbox});

        $self->{vbox}->pack_start($self->{scroll}, 1, 1, $GCUtils::quarterMargin);
        $self->{vbox}->pack_start($self->{hboxButtons}, 0, 0, $GCUtils::quarterMargin);

        $self->{cancel}->signal_connect('clicked' => sub {
            $self->{panel}->initValues
                if $self->{panel};
        });
        $self->{apply}->signal_connect('clicked' => sub {
            if ($self->{panel})
            {
                $self->{panel}->saveValues;
                $self->{parent}->setItemsList(0, 1);
            }
        });
        

        bless $self, $class;
        return $self;    
    }
}

{
    # Class used when there is no option
    package GCEmptyOptionsPanel;
    use base "Gtk3::VBox";
    use GCStyle;
    
    sub initValues
    {
        my $self = shift;
    }
    sub saveValues
    {
        my $self = shift;
    }
    sub new
    {
        my ($proto, $optionsManager, $parent) = @_;
        my $class = ref($proto) || $proto;
        
        my $self  = $class->SUPER::new(0,0);
        bless $self, $class;
        # TODO to be replaced with a translatable label
        my $label = new GCLabel("No option");
        $self->pack_start($label,1,1,0);
        $self->show_all;
        return $self;
    }        
}
    
{
    # Class used to let user select images options
    package GCImagesOptionsPanel;
    use base "Gtk3::Grid";
    #use base "Gtk3::VBox";
    use GCStyle;
    
    sub initValues
    {
        my $self = shift;
        $self->{groupByOption}->setModel($self->{parent}->{model});
        $self->{secondarySortOption}->setModel($self->{parent}->{model});

        $self->{resizeImgList}->set_active($self->{optionsManager}->resizeImgList);
        $self->{animateImgList}->set_active($self->{optionsManager}->animateImgList);
        $self->{columns}->set_value($self->{optionsManager}->columns);
        $self->{imgSizeOption}->setValue($self->{optionsManager}->listImgSize);
        $self->{optionStyle}->setValue($self->{optionsManager}->listImgSkin);
        $self->{useOverlays}->set_active($self->{optionsManager}->useOverlays);             
        $self->{listBgPicture}->set_active($self->{optionsManager}->listBgPicture);
        $self->activateColors(! $self->{optionsManager}->listBgPicture);
        $self->{mlbg} = $self->{optionsManager}->listBgColor;
        $self->{mlfg} = $self->{optionsManager}->listFgColor;
        $self->{groupByOption}->setValue($self->{optionsManager}->groupBy);
        $self->{secondarySortOption}->setValue($self->{optionsManager}->secondarySort);        
    }
    
    sub saveValues
    {
        my $self = shift;
        
        $self->{optionsManager}->resizeImgList(($self->{resizeImgList}->get_active) ? 1 : 0);
        $self->{optionsManager}->animateImgList(($self->{animateImgList}->get_active) ? 1 : 0);
        $self->{optionsManager}->columns($self->{columns}->get_value);
        $self->{optionsManager}->listImgSize($self->{imgSizeOption}->getValue);
        $self->{optionsManager}->listImgSkin($self->{optionStyle}->getValue);
        $self->{optionsManager}->listBgColor($self->{mlbg});
        $self->{optionsManager}->listFgColor($self->{mlfg});
        $self->{optionsManager}->listBgPicture(($self->{listBgPicture}->get_active) ? 1 : 0);
        $self->{optionsManager}->useOverlays(($self->{useOverlays}->get_active) ? 1 : 0);
        $self->{optionsManager}->groupBy($self->{groupByOption}->getValue);
        $self->{optionsManager}->secondarySort( $self->{secondarySortOption}->getValue);
    }
    
    sub changeColor
    {
        my ($self, $type, $color) = @_;
        
        $self->{'ml'.$type} = join ',',$color->red, $color->green, $color->blue;
    }
    
    sub activateColors
    {
        my ($self, $value) = @_;
        
        $self->{labelStyle}->set_sensitive(!$value);
        $self->{optionStyle}->set_sensitive(!$value);
        $self->{labelBg}->set_sensitive($value);
        $self->{buttonBg}->set_sensitive($value);
    }
    
    sub setOptionsManager
    {
        my ($self,$optionsManager) = @_;
        $self->{optionsManager} = $optionsManager;
    }
    
    sub new
    {
        my ($proto, $optionsManager, $parent) = @_;
        my $class = ref($proto) || $proto;
        
        my $self  = $class->SUPER::new();
        
        $self->{optionsManager} = $optionsManager;
        $self->{parent} = $parent;
        $self->{lang} = $parent->{lang};

        # $self->set_row_spacing($GCUtils::halfMargin);
        $self->set_column_spacing($GCUtils::margin);
        $self->set_border_width($GCUtils::margin);

        $self->{labelColumns} = new GCLabel($self->{lang}->{OptionsColumns});
        my  $adj = Gtk3::Adjustment->new(0, 1, 20, 1, 1, 0) ;
        $self->{columns} = Gtk3::SpinButton->new($adj, 0, 0);

        $self->{resizeImgList} = new Gtk3::CheckButton($self->{lang}->{ImagesOptionsResizeImgList});
        $self->{resizeImgList}->signal_connect('clicked' => sub {
            $self->{columns}->set_sensitive(! $self->{resizeImgList}->get_active);
        });
        $self->{resizeImgList}->set_active($self->{resizeImgList});

        $self->{animateImgList} = new Gtk3::CheckButton($self->{lang}->{ImagesOptionsAnimateImgList});
        $self->{animateImgList}->signal_connect('clicked' => sub {
            $self->{columns}->set_sensitive(! $self->{animateImgList}->get_active);
        });
        $self->{animateImgList}->set_active($self->{animateImgList});

        $self->{imgSizeLabel} = new GCLabel($self->{lang}->{ImagesOptionsSizeLabel});
        $self->{imgSizeOption} = new GCMenuList;
        my %imgSizes = %{$self->{lang}->{ImagesOptionsSizeList}};
        my @imgValues = map {{value => $_, displayed => $imgSizes{$_}}}
                                 (sort keys %imgSizes);
        $self->{imgSizeOption}->setValues(\@imgValues);

        $self->{useOverlays} = new Gtk3::CheckButton($self->{lang}->{ImagesOptionsUseOverlays});
        $self->{useOverlays}->set_active($self->{useOverlays});

        $self->{listBgPicture} = new Gtk3::CheckButton($self->{lang}->{ImagesOptionsBgPicture});
        $self->{listBgPicture}->signal_connect('clicked' => sub {
            $self->activateColors(! $self->{listBgPicture}->get_active);
        });
        
        $self->{labelStyle} = new GCLabel($self->{lang}->{OptionsStyle});
        $self->{optionStyle} = new GCMenuList;
        my @styleValues;
        foreach (@GCStyle::lists)
        {
            (my $displayed = $_) =~ s/_/ /g;
            push @styleValues, {value => $_, displayed => $displayed};
        }
        $self->{optionStyle}->setValues(\@styleValues);
       
        $self->{labelBg} = new GCLabel($self->{lang}->{ImagesOptionsBg});
        $self->{buttonBg} = new Gtk3::ColorButton;
        $self->{buttonBg}->set_rgba(GCUtils::getColor($optionsManager->{options}->{listBgColor},'white'));
        $self->{buttonBg}->set_tooltip_text($self->{lang}->{ImagesOptionsBgTooltip});
        $self->{buttonBg}->signal_connect('color-set' => sub {
            $self->changeColor('bg',$self->{buttonBg}->get_color());
        });
        $self->{labelFg} = new GCLabel($self->{lang}->{ImagesOptionsFg});
        $self->{buttonFg} = new Gtk3::ColorButton();
        $self->{buttonFg}->set_rgba(GCUtils::getColor($optionsManager->{options}->{listFgColor},'white'));        
        $self->{buttonFg}->set_tooltip_text($self->{lang}->{ImagesOptionsFgTooltip});
        $self->{buttonFg}->signal_connect('color-set' => sub {
            $self->changeColor('fg',$self->{buttonFg}->get_color());
        });
        $self->{groupItems} = new GCLabel($self->{lang}->{DetailedOptionsGroupItems});
        $self->{groupByOption} = new GCFieldSelector(0, undef, 1, 0, 0);
        $self->{groupByOption}->setModel($parent->{model});
        
        $self->{secondarySort} = new GCLabel($self->{lang}->{DetailedOptionsSecondarySort});
        $self->{secondarySortOption} = new GCFieldSelector(0, undef, 1);
        $self->{secondarySortOption}->setModel($parent->{model});

        my $imagesDisplayExpander = new GCExpander($self->{lang}->{OptionsImagesDisplayGroup}, 1);
        $self->attach($imagesDisplayExpander, 0, 0, 4, 1);
        $self->attach($self->{resizeImgList}, 2, 1, 2, 1);
        $self->attach($self->{animateImgList}, 2, 2, 2, 1);
        $self->attach($self->{labelColumns}, 2, 3, 1, 1);
        $self->attach($self->{columns}, 3, 3, 1, 1);
        $self->attach($self->{imgSizeLabel}, 2, 4, 1, 1);
        $self->attach($self->{imgSizeOption}, 3, 4, 1, 1);
        $self->attach($self->{groupItems}, 2, 5, 1, 1);
        $self->attach($self->{groupByOption}, 3, 5, 1, 1);
        $self->attach($self->{secondarySort}, 2, 6, 1, 1);
        $self->attach($self->{secondarySortOption}, 3, 6, 1, 1);        

        my $imagesStyleExpander = new GCExpander($self->{lang}->{OptionsImagesStyleGroup}, 1);
        $self->attach($imagesStyleExpander, 0, 8, 4, 1);
        $self->attach($self->{useOverlays}, 2, 9, 2, 1);
        $self->attach($self->{listBgPicture}, 2, 10, 2, 1);
        $self->attach($self->{labelStyle}, 2, 11, 1, 1);
        $self->attach($self->{optionStyle}, 3, 11, 1, 1);
        $self->attach($self->{labelBg}, 2, 12, 1, 1);
        $self->attach($self->{buttonBg}, 3, 12, 1, 1);
        $self->attach($self->{labelFg}, 2, 13, 1, 1);
        $self->attach($self->{buttonFg}, 3, 13, 1, 1);
        
        $imagesDisplayExpander->signal_connect('activate' => sub {
            if (!$imagesDisplayExpander->get_expanded)
            {
                $self->{resizeImgList}->show_all;
                $self->{labelColumns}->show_all;
                $self->{columns}->show_all;
                $self->{imgSizeLabel}->show_all;
                $self->{imgSizeOption}->show_all;
                $self->{groupItems}->show_all;
                $self->{groupByOption}->show_all;
                $self->{secondarySort}->show_all;
                $self->{secondarySortOption}->show_all;
            }
            else
            {
                $self->{resizeImgList}->hide;
                $self->{labelColumns}->hide;
                $self->{columns}->hide;
                $self->{imgSizeLabel}->hide;
                $self->{imgSizeOption}->hide;
                $self->{groupItems}->hide;
                $self->{groupByOption}->hide;
                $self->{secondarySort}->hide;
                $self->{secondarySortOption}->hide;
            }
        });  
        $imagesStyleExpander->signal_connect('activate' => sub {
            if (!$imagesStyleExpander->get_expanded)
            {
                $self->{useOverlays}->show_all;
                $self->{listBgPicture}->show_all;
                $self->{labelStyle}->show_all;
                $self->{optionStyle}->show_all;
                $self->{labelBg}->show_all;
                $self->{buttonBg}->show_all;
                $self->{labelFg}->show_all;
                $self->{buttonFg}->show_all;
            }
            else
            {
                $self->{useOverlays}->hide;
                $self->{listBgPicture}->hide;
                $self->{labelStyle}->hide;
                $self->{optionStyle}->hide;
                $self->{labelBg}->hide;
                $self->{buttonBg}->hide;
                $self->{labelFg}->hide;
                $self->{buttonFg}->hide;
            }
        });

        $self->show_all;
        $imagesDisplayExpander->set_expanded(1);
        $imagesStyleExpander->set_expanded(1);

        bless ($self, $class);
        return $self;
    }
}



{
    # Class used to let user select detailed options
    package GCDetailedOptionsPanel;
    use base "Gtk3::VBox";
   
    
    sub initValues
    {
        my $self = shift;
        
        $self->{groupByOption}->setModel($self->{parent}->{model});
        $self->{secondarySortOption}->setModel($self->{parent}->{model});
        
        $self->{imgSizeOption}->setValue($self->{optionsManager}->detailImgSize);
        $self->{groupByOption}->setValue($self->{optionsManager}->groupBy);
        $self->{secondarySortOption}->setValue($self->{optionsManager}->secondarySort);
        $self->{groupedFirst}->setValue($self->{optionsManager}->groupedFirst);
        $self->{addCount}->setValue($self->{optionsManager}->addCount);
        
        $self->{fieldsSelection}->setModel($self->{parent}->{model});
        my @tmpFieldsArray = split m/\|/, $self->{optionsManager}->details;
        $self->{fieldsSelection}->setListFromIds(\@tmpFieldsArray);

    }
    
    sub saveValues
    {
        my $self = shift;
        $self->{optionsManager}->detailImgSize($self->{imgSizeOption}->getValue);
        $self->{optionsManager}->groupBy($self->{groupByOption}->getValue);
        $self->{optionsManager}->secondarySort($self->{secondarySortOption}->getValue);
        $self->{optionsManager}->groupedFirst($self->{groupedFirst}->getValue);
        $self->{optionsManager}->addCount($self->{addCount}->getValue);
        my $details = join('|', @{$self->{fieldsSelection}->getSelectedIds});
        $self->{optionsManager}->details($details);
    }
    
    sub hideExtra
    {
        my $self = shift;

    }

    sub show
    {
        my $self = shift;

        $self->initValues;
        
        my $code = $self->SUPER::show;
        if ($code eq 'ok')
        {
            $self->saveValues;
        }
        $self->hide;
    }
    
    sub new
    {
        my ($proto, $optionsManager, $parent, $preIdList) = @_;
        my $class = ref($proto) || $proto;
        my $self = $class->SUPER::new(0,0);

        $self->{lang} = $parent->{lang};
        $self->{optionsManager} = $optionsManager;
        $self->{parent} = $parent;

        bless ($self, $class);

        $self->set_border_width($GCUtils::margin);

        $self->{groupItems} = new GCLabel($self->{lang}->{DetailedOptionsGroupItems});
        $self->{groupByOption} = new GCFieldSelector(0, undef, 1);
        $self->{groupByOption}->setModel($parent->{model});

        $self->{secondarySort} = new GCLabel($self->{lang}->{DetailedOptionsSecondarySort});
        $self->{secondarySortOption} = new GCFieldSelector(0, undef, 1);
        $self->{secondarySortOption}->setModel($parent->{model});

        $self->{groupedFirst} = new GCCheckBox($self->{lang}->{DetailedOptionsGroupedFirst});
        $self->{addCount} = new GCCheckBox($self->{lang}->{DetailedOptionsAddCount});
        
        $self->{imgSizeLabel} = new GCLabel($self->{lang}->{DetailedOptionsImageSize});
        $self->{imgSizeOption} = new GCMenuList;
        my %imgSizes = %{$self->{lang}->{ImagesOptionsSizeList}};
        my @imgValues = map {{value => $_, displayed => $imgSizes{$_}}}
                                 (sort keys %imgSizes);
        $self->{imgSizeOption}->setValues(\@imgValues);

        my $preferencesExpander = new GCExpander($self->{lang}->{OptionsDetailedPreferencesGroup}, 1);
        $self->pack_start($preferencesExpander, 0, 0, $GCUtils::quarterMargin);

        my $tablePreferences = new Gtk3::Grid();
        $tablePreferences->set_column_spacing($GCUtils::margin);

        $tablePreferences->attach($self->{imgSizeLabel}, 2, 1, 1, 1);
        $tablePreferences->attach($self->{imgSizeOption}, 3, 1, 1, 1);

        $tablePreferences->attach($self->{groupItems}, 2, 2, 1, 1);
        $tablePreferences->attach($self->{groupByOption}, 3, 2, 1, 1);
        $tablePreferences->attach($self->{secondarySort}, 2, 3, 1, 1);
        $tablePreferences->attach($self->{secondarySortOption}, 3, 3, 1, 1);

        $tablePreferences->attach($self->{groupedFirst}, 2, 4, 2, 1);
        $tablePreferences->attach($self->{addCount}, 2, 5, 2, 1);

        $preferencesExpander->add($tablePreferences);

        my $fieldsExpander = new GCExpander($self->{lang}->{DetailedOptionsFields}, 1);
        my @tmpFieldsArray = split m/\|/, $optionsManager->details;
        $self->{fieldsSelection} = new GCFieldsSelectionWidget($parent, \@tmpFieldsArray, 1);

        $self->pack_start($fieldsExpander, 0, 0, $GCUtils::quarterMargin);
        $fieldsExpander->add($self->{fieldsSelection});
        $self->{fieldsSelection}->set_border_width($GCUtils::margin);

        $preferencesExpander->set_expanded(1);
        $fieldsExpander->set_expanded(1);

        $self->show_all;
        return $self;
    }
}

1;
