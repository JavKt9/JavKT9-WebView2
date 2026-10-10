package GCDisplay;

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
use GCUtils;

{
    package GCFilterSearch;

    # Used to remove diacritics in test
    use Unicode::Normalize 'NFKD';

    sub compareExact
    {
        my ($field, $value) = @_;
        return $field eq $value;
    }
    
    sub compareContain
    {
        my ($field, $value) = @_;
        return $field =~ m/\Q$value\E/;
    }

    sub compareNotContain
    {
        my ($field, $value) = @_;
        return $field !~ m/\Q$value\E/;
    }

    sub compareRegexp
    {
        my ($field, $value) = @_;
        return $field =~ m/$value/;
    }

    sub compareLessStrings
    {
        my ($field, $value) = @_;
        return $field lt $value;
    }

    sub compareLessNumbers
    {
        my ($field, $value) = @_;
        return 0 if !defined($field);
        return $field < $value;
    }

    sub compareLessOrEqualStrings
    {
        my ($field, $value) = @_;
        return $field le $value;
    }

    sub compareLessOrEqualNumbers
    {
        my ($field, $value) = @_;
        return 0 if !defined($field);
        return $field <= $value;
    }
    
    sub compareGreaterStrings
    {
        my ($field, $value) = @_;
        return $field gt $value;
    }

    sub compareGreaterNumbers
    {
        my ($field, $value) = @_;
        return 0 if !defined($field);
        return $field > $value;
    }

    sub compareGreaterOrEqualStrings
    {
        my ($field, $value) = @_;
        return $field ge $value;
    }

    sub compareGreaterOrEqualNumbers
    {
        my ($field, $value) = @_;
        return 0 if !defined($field);
        return $field >= $value;
    }

    sub compareRangeStrings
    {
        my ($field, $value) = @_;
        return 1 if $value eq ';';
        my @values = split m/;/, $value;
        return ($field ge $values[0]) && ($field le $values[1]);
    }

    sub compareRangeNumbers
    {
        my ($field, $value) = @_;
        return 1 if $value eq ';';
        return 0 if !defined($field);
        my @values = split m/;/, $value;
        return ($field >= $values[0]) && ($field <= $values[1]);
    }

    sub new
    {
        my ($proto, $info) = @_;
        my $class = ref($proto) || $proto;
        my $self  = {};

        bless ($self, $class);

        $self->{info} = $info if $info;
        $self->clear if !$info;
        $self->setMode;
        $self->setCase(0);
        $self->setIgnoreDiacritics(0);
        return $self;
    }

    sub clear
    {
        my $self = shift;
        
        $self->{cleared} = 1;

        $self->{info} = {};
        $self->{currentSearch} = [];
    }

    sub getComparisonFunction
    {
        my ($self, $type) = @_;
        my ($comparison, $numeric) = @$type;
        $numeric = 1 if $numeric eq 'true';
        $numeric = 0 if $numeric eq 'false';

        if ($comparison eq 'eq')
        {
            return \&compareExact;
        }
        elsif ($comparison eq 'contain')
        {
            return \&compareContain;
        }
        elsif ($comparison eq 'notcontain')
        {
            return \&compareNotContain;
        }
        elsif ($comparison eq 'lt')
        {
            return \&compareLessStrings if (!$numeric);
            return \&compareLessNumbers if ($numeric);
        }
        elsif ($comparison eq 'le')
        {
            return \&compareLessOrEqualStrings if (!$numeric);
            return \&compareLessOrEqualNumbers if ($numeric);
        }
        elsif ($comparison eq 'gt')
        {
            return \&compareGreaterStrings if (!$numeric);
            return \&compareGreaterNumbers if ($numeric);
        }
        elsif ($comparison eq 'ge')
        {
            return \&compareGreaterOrEqualStrings if (!$numeric);
            return \&compareGreaterOrEqualNumbers if ($numeric);
        }
        elsif ($comparison eq 'range')
        {
            return \&compareRangeStrings if (!$numeric);
            return \&compareRangeNumbers if ($numeric);
        }
        elsif ($comparison eq 'regexp')
        {
            return \&compareRegexp;
        }
    }
    
    sub setFilter
    {
        my ($self, $filter, $value, $type, $model, $add) = @_;
        if (!$filter)
        {
            $self->clear;
            return;
        }
        if ($value eq '')
        {
            delete $self->{info}->{$filter};
        }
        else
        {
            $self->{cleared} = 0;
            my $preprocess = $type->[2];
            if (!$preprocess)
            {
                my $fieldType = $model->{fieldsInfo}->{$filter}->{type};
                $preprocess = ($fieldType eq 'date') ? 'reverseDate'
                            : ($fieldType eq 'number') ? 'noNullNumber'
                            : ($fieldType eq 'yesno') ? 'noNullNumber'
                            : ($fieldType eq 'single list') ? 'singleList'
                            : ($fieldType eq 'double list') ? 'doubleList'
                            : ($fieldType eq 'triple list') ? 'otherList'
                            : ($fieldType =~ /list$/o) ? 'singleList'
                            : '';
            }
            my $info = {
                            value => $value,
                            comp => $self->getComparisonFunction($type),
                            preprocess => $preprocess,
                            temporary => $add
                         };
            if ($add)
            {
                push @{$self->{info}->{$filter}}, $info;
            }
            else
            {
                $self->{info}->{$filter} = [$info];
            }
            push @{$self->{currentSearch}}, {
                field  => $filter,
                value  => $value,
                filter => $type
            };
        }
    }
    
    sub removeTemporaryFilters
    {
        my $self = shift;
        foreach (keys %{$self->{info}})
        {
            foreach my $i(0 .. scalar @{$self->{info}->{$_}} - 1)
            {
                delete $self->{info}->{$_}->[$i] if $self->{info}->{$_}->[$i]->{temporary};
            }
        }
    }

    sub setModel
    {
        my ($self, $model) = @_;
        
        $self->{model} = $model;
    }

    sub test
    {
        my ($self, $info) = @_;
        return 1 if $self->{cleared};
        my $testAnd = $self->{mode} eq 'and';

        foreach my $field(keys %{$self->{info}})
        {
            my $value = '';
            if ($field eq $GCFieldSelector::anyFieldValue)
            {
                # We concatenate all of the values here to perform the
                # the test on all of the fields in one shot
                foreach my $key(keys %$info)
                {
                    if (ref($info->{$key}) eq 'ARRAY')
                    {
                        $value .= GCPreProcess::otherList($info->{$key});
                    }
                    else
                    {
                        $value .= $info->{$key};
                    }
                }
            }
            else
            {
                $value = $info->{$field};
            }
            foreach my $filter(@{$self->{info}->{$field}})
            {
                next if !$filter;
                if ($filter->{preprocess})
                {
                    my $preProcess = 'GCPreProcess::'.$filter->{preprocess};
                    eval {
                        no strict qw/refs/;
                        $value = $preProcess->($value);
                    };
                }
                my $reference;

                if ($self->{ignoreDiacritics})
                {
                    # Transform diacritics into single characters
                    # e.g. é -> e; ç -> c
                    # First it normalizes the string to have 2 characters
                    # instead of only one. And then it removes the modifiers
                    ($reference = NFKD($filter->{value})) =~ s/\pm//g;
                    ($value = NFKD($value)) =~ s/\pm//g;
                }
                else
                {
                    $reference = $filter->{value};
                }
                if (!$self->{case})
                {
                    $reference = uc $reference;
                    $value = uc $value;
                }

                if ($testAnd)
                {
                    return 0 if ! $filter->{comp}->($value, $reference);
                }
                else
                {
                    return 1 if $filter->{comp}->($value, $reference);
                }
            }
        }
        return $testAnd;
    }

    sub setMode
    {
        my ($self, $mode) = @_;
        $mode ||= 'and';
        #*test = \&testAnd if $mode eq 'and';
        #*test = \&testOr if $mode eq 'or';
        $self->{mode} = $mode;
    }

    sub setCase
    {
        my ($self, $case) = @_;
        $self->{case} = $case;
    }

    sub setIgnoreDiacritics
    {
        my ($self, $id) = @_;
        $self->{ignoreDiacritics} = $id;
    }

    sub getCurrentSearch
    {
        my $self = shift;
        return {mode => $self->{mode},
                info => $self->{currentSearch},
                case => $self->{case},
                ignoreDiacritics => $self->{ignoreDiacritics}};
    }

    sub isEmpty
    {
        my $self = shift;
        return $self->{cleared};
    }
}

use Gtk3;

{
    package GCSearchDialog;
    
    use GCGraphicComponents::GCWidgets;
    
    use base 'GCModalDialog';
    
    sub initValues
    {
        my $self = shift;
        
        my $info = $self->{parent}->{filterSearch}->{info};
        
        foreach (@{$self->{fields}})
        {
            if (exists $info->{$_})
            {
                $self->{$_}->setValue($info->{$_}->[0]->{value});
            }
            else
            {
                $self->{$_}->clear if $self->{$_};
            }
            if ($self->{fieldsInfo}->{$_}->{type} eq 'history text')
            {
                $self->{$_}->setValues($self->{parent}->{panel}->{$_}->getValues);
            }
            if (
                 (
                   ($self->{fieldsInfo}->{$_}->{type} eq 'single list')
                   ||
                   ($self->{fieldsInfo}->{$_}->{type} eq 'double list')
                 )
                 &&
                 (
                   $self->{parent}->{panel}->{$_}->{withHistory}
                 )
               )
            {
                my @values;
                foreach ($self->{parent}->{panel}->{$_}->getValues)
                {
                    push @values, $_->[0];
                }
                $self->{$_}->setValues(@values);
            }
        }
    }
    
    sub show
    {
        my $self = shift;

        $self->initValues;
        $self->SUPER::show();
        $self->show_all;
        $self->activateOkButton($self->{notEmpty});
        $self->activateExtraButton($self->{notEmpty});
        $self->{search} = undef;
        my $ended = 0;
        while (!$ended)
        {
            my $response = $self->run;
            if ($response eq 'ok')
            {
                my %info;
            
                foreach (@{$self->{fields}})
                {
                    $info{$_} = $self->{$_}->getValue
                        if ! $self->{$_}->isEmpty;
                }

                $self->{parent}->{menubar}->initFilters(\%info);

                $self->{search} = \%info;
            }
            if (($response eq 'ok') || ($response eq 'cancel') || ($response eq 'delete-event'))
            {
                $ended = 1
            }
            elsif ($response eq 'reject')
            {
                $self->clear;
            }
        }
        $self->hide;
    }
    
    sub clear
    {
        my $self = shift;
        foreach (@{$self->{fields}})
        {
            $self->{$_}->clear;
        }
    }
    
    sub search
    {
        my $self = shift;
        
        return $self->{search};
    }
    
    sub new
    {
        my ($proto, $parent, $specialOK, @extraButtons) = @_;
        my $class = ref($proto) || $proto;
        my $self;
        if ($specialOK)
        {
            $self = $class->SUPER::new($parent,
                                       $parent->{lang}->{SearchTitle},
                                       $specialOK,
                                      );
        }
        else
        {
            $self = $class->SUPER::new($parent,
                                       $parent->{lang}->{SearchTitle},
                                       'gtk-find',
                                       0,
                                       @extraButtons,
                                       'gtk-clear' => 'reject',
                                      );
        }
        bless ($self, $class);
        $self->set_position('center-on-parent');
        $self->{parent} = $parent;

        # These ones are required for createWidget
        $self->{lang} = $parent->{lang};
        $self->{options} = $parent->{options};
        $self->{window} = $self;

        $self->{comparisonConvertor} = new GCComparisonSelector($parent);
        $self->{layoutTable} = new Gtk3::Grid();
        $self->{layoutTable}->set_row_spacing($GCUtils::halfMargin);
        $self->{layoutTable}->set_column_spacing($GCUtils::margin);
        $self->{layoutTable}->set_border_width($GCUtils::margin);
        
        $self->get_content_area->pack_start($self->{layoutTable}, 1, 1, 0);
        return $self;
    }
    
    sub setModel
    {
        my ($self, $model) = @_;
        $self->{model} = $model;
        foreach ($self->{layoutTable}->get_children)
        {
            $self->{layoutTable}->remove($_);
            $_->destroy;
        }

        my $fieldsInfo = $model->{fieldsInfo};
        $self->{fieldsInfo} = $fieldsInfo;
        my @filtersGroup = @{$model->{filtersGroup}};
        my @filtersTotal = @{$model->{filters}};

        my $row = 0;
        my $nbLines = @filtersTotal + (2 * @filtersGroup);
        if ($nbLines <= 0)
        {
            $self->{notEmpty} = 0;
            #GTK3 $self->{layoutTable}->resize(1, 1);
            my $label = new GCLabel($self->{parent}->{lang}->{SearchNoField});
            $self->{layoutTable}->attach($label, 0, 0, 1, 1);
            return;
        }
        $self->{notEmpty} = 1;
        #GTK3 $self->{layoutTable}->resize($nbLines, 3);

        $self->{fields} = [];
        foreach my $group(@filtersGroup)
        {
            $row++;
            my @filters = @{$group->{filter}};
            my $label = new GCHeaderLabel($model->getDisplayedText($group->{label}));
            $self->{layoutTable}->attach($label, 0, $row, 3, 1);
            $row++;
            my $withComparisonLabel;
            foreach my $filter(@filters)
            {
                my $field = $filter->{field};
                if ($field ne 'separator')
                {
                    push @{$self->{fields}}, $field;
                    my $labelText = $fieldsInfo->{$field}->{displayed};
                    $labelText = $model->getDisplayedText($filter->{label}) if $filter->{label};            
                    my $label = new GCLabel($labelText);
                    $self->{layoutTable}->attach($label, 0, $row, 1, 1);

                    ($self->{$field}, $withComparisonLabel) = 
                        GCWidgets::createWidget($self, $fieldsInfo->{$field},
                                                          $filter->{comparison});
                    $self->{$field}->signal_connect('activate' => sub {$self->response('ok')} )
                        if $self->{$field}->isa('GCShortText');
                    if ($withComparisonLabel
                    && ($filter->{comparison} ne 'eq'))
                    {
                        my $labelComparison = new GCLabel(
                           $self->{comparisonConvertor}->valueToDisplayed($filter->{comparison}),
                           1
                        );
                        $self->{layoutTable}->attach($labelComparison, 1, $row, 1, 1);
                    }
                    $self->{layoutTable}->attach($self->{$field}, 2, $row, 1, 1);
                    $self->{$field}->grab_focus if $row == 2;
                }
                else
                {
                    $self->{layoutTable}->attach(Gtk3::HSeparator->new, 0, $row, 3, 1);
                }
                $row++;
            }
        }
        $self->{layoutTable}->show_all;
    }
}

{
    package GCAdvancedSearchDialog;
    
    use GCGraphicComponents::GCWidgets;
    
    use base 'GCSearchDialog';
    
    sub addItem
    {
        my $self = shift;
        #GTK3 $self->{layoutTable}->resize($self->{nbFields} + 1, 3);
        my $field = new GCFieldSelector(0, $self->{model}, 0, 1);
        $field->{number} = $self->{nbFields};
        push @{$self->{fields}}, $field;
        $self->{layoutTable}->attach($field, 0, $self->{nbFields}, 1, 1);
        $field->show_all;

        my $comp = new GCComparisonSelector($self->{parent});
        $field->signal_connect('changed' => sub {
            my ($fs, $cs) = @_;
            $self->updateField($fs, $cs->getValue);
        }, $comp);
        $comp->signal_connect('changed' => sub {
            my ($cs, $fs) = @_;
            $self->updateField($fs, $cs->getValue);
        }, $field);
        push @{$self->{comps}}, $comp;
        $self->{layoutTable}->attach($comp, 1, $self->{nbFields}, 1, 1);
        $comp->show_all;

        my $value = new GCShortText;
        push @{$self->{values}}, $value;
        $self->{layoutTable}->attach($value, 2, $self->{nbFields}, 1, 1);
        $value->show_all;
        $self->{remove}->set_sensitive(1);
        $self->{nbFields}++;
    }
    
    sub removeItem
    {
        my $self = shift;
        $self->{layoutTable}->remove(pop @{$self->{fields}});
        $self->{layoutTable}->remove(pop @{$self->{comps}});
        $self->{layoutTable}->remove(pop @{$self->{values}});
        delete $self->{isNumeric}->[$self->{nbFields}];
        #GTK3 $self->{layoutTable}->resize(--$self->{nbFields}, 3);
        $self->{remove}->set_sensitive(0) if $self->{nbFields} < 2;
    }

    sub generateSearch
    {
        my $self = shift;
        my @info;
        my $i = 0;
        foreach (@{$self->{fields}})
        {
            my $field = $_->getValue;
            next if !$field;
            my $numeric = 'false';
            if ($self->{model}->{fieldsInfo}->{$field}->{type} eq 'number')
            {
                $numeric = 'true';
            }
            # We check we still have the same field in case it was changed
            elsif ($self->{isNumeric}->[$i]->[0] eq $field)
            {
                $numeric = $self->{isNumeric}->[$i]->[1];
            }
            push @info, {
                field => $field,
                value => $self->{values}->[$i]->getValue,
                filter => [$self->{comps}->[$i]->getValue,
                           $numeric,
                           undef]
            }
                if ! $self->{values}->[$i]->isEmpty;
            $i++;
        }
        $self->{search} = \@info;        
    }

    sub initSearch
    {
        my ($self, $filter) = @_;
        if ($filter->{mode} eq 'and')
        {
            $self->{testAnd}->set_active(1);
        }
        elsif ($filter->{mode} eq 'or')
        {
            $self->{testOr}->set_active(1);       
        }
        $self->{useCase}->set_active($filter->{case});
        $self->{ignoreDiacritics}->set_active($filter->{ignoreDiacritics});
        $self->removeItem while $self->{nbFields} > 1;
        $self->{isNumeric} = [];
        my $first = 1;
        foreach my $line(@{$filter->{info}})
        {
            $self->addItem if !$first;
            $first = 0;
            $self->{fields}->[-1]->setValue($line->{field});
            $self->{comps}->[-1]->setValue($line->{filter}->[0]);
            $self->{values}->[-1]->setValue($line->{value});
            # We also add the field name to be able to check it later
            push @{$self->{isNumeric}}, [$line->{field}, $line->{filter}->[1]];
        }
    }

    sub show
    {
        my $self = shift;
        
        $self->show_all;
        # If saving the search is not possible, hides the corresponding button
        if (!$self->{canSave})
        {
            ($self->get_action_area->get_children)[3]->hide;
        }
        $self->{search} = undef;
        my $ended = 0;
        while (!$ended)
        {
            my $response = $self->run;
            if ($response eq 'ok')
            {
                if ($self->{userFilter})
                {
                    $self->saveSearch;
                }
                else
                {
                    $self->generateSearch;
                }
            }
            else
            {
                $self->{search} = undef;
            }
            $ended = 1 if ($response eq 'ok') || ($response eq 'cancel') || ($response eq 'delete-event');
            $self->clear if ($response eq 'reject');
            $self->saveSearch if ($response eq 'accept');
        }
        $self->hide;
    }

    sub getMode
    {
        my $self = shift;
        return ($self->{testAnd}->get_active ? 'and' : 'or');
    }

    sub getCase
    {
        my $self = shift;
        return ($self->{useCase}->get_active ? 1 : 0);
    }

    sub getIgnoreDiacritics
    {
        my $self = shift;
        return ($self->{ignoreDiacritics}->get_active ? 1 : 0);
    }

    sub saveSearch
    {
        my $self = shift;
        
        my $response;
        my $name;
        if ($self->{userFilter} eq 'edit')
        {
            $response = 'ok';
            $name = '';
        }
        else
        {
            my $dialog = new Gtk3::Dialog($self->{parent}->{lang}->{AdvancedSearchSaveTitle},
                                          $self,
                                          [qw/modal destroy-with-parent/],
                                          @GCDialogs::okCancelButtons
                                          );
    
            my $hbox = Gtk3::HBox->new(0, $GCUtils::halfMargin);
            my $label = Gtk3::Label->new($self->{parent}->{lang}->{AdvancedSearchSaveName});
            $hbox->pack_start($label, 0, 0, 0);
            my $entry = Gtk3::Entry->new;
            $hbox->pack_start($entry, 1, 1, 0);
            $hbox->show_all;
            $dialog->get_content_area->pack_start($hbox, 1, 1, $GCUtils::margin);
            $dialog->set_default_response('ok');
            $entry->set_activates_default(1);
            while (1)
            {
                $response = $dialog->run;
                if ($response eq 'ok')
                {
                    $name = $entry->get_text;
                    if ($self->{model}->existsUserFilter($name))
                    {
                        my $errorDialog = Gtk3::MessageDialog->new($self,
                           [qw/modal destroy-with-parent/],
                           'error',
                           'ok',
                           $self->{parent}->{lang}->{AdvancedSearchSaveOverwrite});
                           $dialog->set_position('center-on-parent');
                        $errorDialog->run;
                        $errorDialog->destroy;
                        next;
                    }
                    last;
                }
                last;
            }
            $dialog->destroy;
        }

        if ($response eq 'ok')
        {
            $self->generateSearch;
            my $info = {
                'name' => $name,
                'mode' => $self->getMode,
                'case' => $self->getCase,
                'ignoreDiacritics' => $self->getIgnoreDiacritics,
                'info' => $self->{search}
            };
            $self->{parent}->addUserFilter($info);
        }
    }

    sub new
    {
        my ($proto, $parent, $userFilter) = @_;
        my $class = ref($proto) || $proto;
        my $self;
        if ($userFilter)
        {
            $self = $class->SUPER::new($parent, 'gtk-save');
        }
        else
        {
            $self = $class->SUPER::new($parent, undef, 'gtk-save' => 'accept',);
        }
        bless ($self, $class);

        $self->{parent} = $parent;
        $self->{userFilter} = $userFilter;
        $self->get_content_area->remove($self->{layoutTable});

        my $allTable = new Gtk3::Grid();
        $allTable->set_row_spacing($GCUtils::halfMargin);
        $allTable->set_column_spacing($GCUtils::margin);
        $allTable->set_border_width($GCUtils::margin);
        
        my $labelType = new GCHeaderLabel($parent->{lang}->{AdvancedSearchType});
        $self->{testAnd} = Gtk3::RadioButton->new_with_label_from_widget(undef, $parent->{lang}->{AdvancedSearchTypeAnd});
        $self->{testOr}  = Gtk3::RadioButton->new_with_label_from_widget($self->{testAnd}, $parent->{lang}->{AdvancedSearchTypeOr});

        my $prefStock = Gtk3::Stock::lookup('gtk-preferences');
        (my $prefLabel = $prefStock->{label}) =~ s/_//;
        my $labelPreferences = new GCHeaderLabel($prefLabel);
        $self->{useCase} = new GCCheckBox($parent->{lang}->{AdvancedSearchUseCase});
        $self->{ignoreDiacritics} = new GCCheckBox($parent->{lang}->{AdvancedSearchIgnoreDiacritics});

        my $offset1 = 0;
        $offset1 = 4;
        $allTable->attach($labelType, 0, $offset1, 3, 0);
        $allTable->attach($self->{testAnd}, 2, $offset1 + 1, 1, 1);
        $allTable->attach($self->{testOr}, 2, $offset1 + 2, 1, 1);
        $allTable->attach($labelPreferences, 0, $offset1 + 4, 3, 1);
        $allTable->attach($self->{useCase}, 2, $offset1 + 5, 1, 1);
        $allTable->attach($self->{ignoreDiacritics}, 2, $offset1 + 6, 1, 1);

        my $labelCriteria = new GCHeaderLabel($parent->{lang}->{AdvancedSearchCriteria});
        my $scrolled = new Gtk3::ScrolledWindow;
        $scrolled->set_policy ('never', 'automatic');
        $scrolled->set_border_width(0);
        $scrolled->set_shadow_type('none');
        $scrolled->add_with_viewport($self->{layoutTable});

        my $offset2 = 8;
        $offset2 = 0;
        $allTable->attach($labelCriteria, 0, $offset2 + 0, 3, 1);
        $allTable->attach($scrolled, 2, $offset2 + 1, 1, 1);

        my $hboxAction = new Gtk3::HBox(0,0);
        $self->{add} = Gtk3::Button->new_from_stock('gtk-add');
        $self->{add}->signal_connect('clicked' => sub {
            $self->addItem;
        });
        $hboxAction->pack_start($self->{add}, 0, 0, 0);
        $self->{remove} = Gtk3::Button->new_from_stock('gtk-remove');
        $self->{remove}->signal_connect('clicked' => sub {
            $self->removeItem;
        });
        $hboxAction->pack_start($self->{remove}, 0, 0, $GCUtils::margin);
#        if (!$userFilter)
#        {
#            $self->{save} = Gtk3::Button->new_from_stock('gtk-save');
#            $self->{save}->signal_connect('clicked' => sub {
#                $self->saveSearch;
#            });
#            $hboxAction->pack_end($self->{save}, 0, 0, 0);
#        }
        $allTable->attach($hboxAction, 2, $offset2 + 2, 1, 1);

        $self->get_content_area->pack_start($allTable,1,1,0);
        
        $self->set_size_request(-1, 400);
        return $self;
    }
    
    sub clear
    {
        my $self = shift;
        $self->setModel($self->{model});
    }

    sub setModel
    {
        my ($self, $model) = @_;

        $self->{model} = $model;
        # Searches can only be saved for default collections or user collections with a name
        # (i.e. when the model is not embedded within the collection).
        $self->{canSave} = ($model->getName) ? 1 : 0;
        $self->{nbFields} = 0;
        $self->{fields} = [];
        $self->{comps} = [];
        $self->{values} = [];
        foreach ($self->{layoutTable}->get_children)
        {
            $self->{layoutTable}->remove($_);
            $_->destroy;
        }
        $self->addItem;
        $self->{remove}->set_sensitive(0);
        $self->{layoutTable}->show_all;
    }

    sub updateField
    {
        my ($self, $fs, $comparison) = @_;
        my $idx = $fs->{number};
        my $widget = $self->{values}->[$idx];
        $self->{layoutTable}->remove($widget);

        my $newWidget;
        ($newWidget, undef) = $fs->createEntryWidget($self, $comparison, $widget);
        $newWidget->signal_connect('activate' => sub {$self->response('ok')} )
            if $newWidget->isa('GCShortText');

         $self->{values}->[$idx] = $newWidget;
         $self->{layoutTable}->attach($newWidget, 2, $idx, 1, 1);
         $newWidget->show_all;
    }
}

{
    package GCUserFiltersDialog;
    
    use GCGraphicComponents::GCWidgets;
    use Storable;
    use base 'GCModalDialog';

    sub setModel
    {
        my ($self, $model) = @_;
        $self->{model} = $model;
        $self->{filters} = Storable::dclone($model->getUserFilters);
        $self->initList(1);
        $self->{deletedFilters} = [];
    }

    sub initList
    {
        my ($self, $saved) = shift;
        @{$self->{filtersList}->{data}} = ();
        $self->{initializing} = 1;
        $self->{filters} = $self->getUserFilters;
        #my @sorted = sort {uc($a->{name}) cmp uc($b->{name})} @{$self->{filters}};
        #$self->{filters} = \@sorted;
        foreach(@{$self->{filters}})
        {
            push @{$self->{filtersList}->{data}}, $_->{name};
            # All of them should be already saved
            $_->{saved} = 1 if $saved;
        }
        $self->{initializing} = 0;
    }

    sub getUserFilters
    {
        my $self = shift;
        my @sorted = sort {uc($a->{name}) cmp uc($b->{name})} @{$self->{filters}};
        return \@sorted;
        return $self->{filters};
    }

    sub getDeletedFilters
    {
        my $self = shift;
        return $self->{deletedFilters};
    }

    sub show
    {
        my $self = shift;

        $self->SUPER::show();
        $self->show_all;
        my $response = $self->run;
        $self->hide;
        return ($response eq 'ok');
    }

    # Callbacked by advanced search dialog
    sub addUserFilter
    {
        my ($self, $filter) = @_;
        $filter->{saved} = 0;
        if ($self->{mode} eq 'new')
        {
            push (@{$self->{filters}}, $filter);
            push @{$self->{filtersList}->{data}}, $filter->{name};
        }
        else
        {
            my $selected = ($self->{filtersList}->get_selected_indices)[0];
            $filter->{name} = $self->{filters}->[$selected]->{name};
            $self->{filters}->[$selected] = $filter;
        }
    }

    sub newFilter
    {
        my $self = shift;
        $self->{mode} = 'new';
        $self->{panel} = $self->{parent}->{panel};
        my $dialog = new GCAdvancedSearchDialog($self, $self->{mode});
        $dialog->setModel($self->{model});
        $dialog->show;
        # To avoid unwanted reference if the panel is changed
        delete $self->{panel};
    }

    sub editFilter
    {
        my $self = shift;
        $self->{mode} = 'edit';
        my $selected = ($self->{filtersList}->get_selected_indices)[0];
        $self->{panel} = $self->{parent}->{panel};
        my $dialog = new GCAdvancedSearchDialog($self, $self->{mode});
        $dialog->setModel($self->{model});
        $dialog->initSearch($self->{filters}->[$selected]);
        $dialog->show;
        # To avoid unwanted reference if the panel is changed
        delete $self->{panel};
    }

    sub deleteFilter
    {
        my $self = shift;
        my $selected = ($self->{filtersList}->get_selected_indices)[0];
        push @{$self->{deletedFilters}}, $self->{filters}->[$selected]->{name};
        splice @{$self->{filters}}, $selected, 1;
        splice (@{$self->{filtersList}->{data}}, $selected, 1);
        $self->{filtersList}->select(0);
    }
    
    sub renameFilter
    {
        my $self = shift;
        my $selected = ($self->{filtersList}->get_selected_indices)[0];
        my $oldName = $self->{filters}->[$selected]->{name};
        my $newName = $self->{filtersList}->{data}->[$selected]->[0];
        return if $newName eq $oldName;
        $self->{filters}->[$selected]->{name} = $newName;
        $self->{filters}->[$selected]->{saved} = 0;
        push @{$self->{deletedFilters}}, $oldName;
        $self->initList(0);
    }

    sub new
    {
        my ($proto, $parent) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new($parent,
                                       $parent->{lang}->{MenuSavedSearchesEdit});
        bless ($self, $class);
        $self->set_position('center-on-parent');
        $self->{parent} = $parent;
        $self->{lang} = $parent->{lang};
        my $hBox = new Gtk3::HBox(0,0);
        $hBox->set_border_width($GCUtils::margin);
        my $buttonBox = new Gtk3::VBox(0,0);
        
        my $editButton = new Gtk3::Button->new_from_stock('gtk-edit');
        $editButton->signal_connect('clicked' => sub {
            $self->editFilter;
        });
        my $newButton = new Gtk3::Button->new_from_stock('gtk-new');
        $newButton->signal_connect('clicked' => sub {
            $self->newFilter;
        });
        my $deleteButton = new Gtk3::Button->new_from_stock('gtk-delete');
        $deleteButton->signal_connect('clicked' => sub {
            $self->deleteFilter;
        });

        $buttonBox->pack_start($newButton, 0, 0, $GCUtils::halfMargin);
        $buttonBox->pack_start($deleteButton, 0, 0, $GCUtils::halfMargin);
        $buttonBox->pack_start($editButton, 0, 0, $GCUtils::halfMargin);

        $self->{filtersList} = new Gtk3::SimpleList($parent->{lang}->{MenuSavedSearches} => 'text');
        $self->{filtersList}->set_column_editable(0, 1);
        $self->{filtersList}->get_model->signal_connect("row-changed" => sub {
            return if $self->{initializing};
            $self->renameFilter;
        });

        my $scroller = new Gtk3::ScrolledWindow;
        $scroller->set_policy ('automatic', 'automatic');
        $scroller->set_shadow_type('etched-in');
        $scroller->add($self->{filtersList});

        $hBox->pack_start($scroller, 1, 1, $GCUtils::margin);
        $hBox->pack_start($buttonBox, 0, 0, $GCUtils::margin);

        $self->get_content_area->pack_start($hBox, 1, 1, 0);
        $self->set_default_size(400, 400);
        return $self;
    }
}

1;
