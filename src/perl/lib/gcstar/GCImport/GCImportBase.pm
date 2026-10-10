package GCImport::GCImportBase;

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
use GCExportImport;

{
    package GCImport::GCImportBaseClass;

    use base 'GCExportImportBase';
    use File::Basename;
    use File::Copy;
    use GCUtils 'localName';
    
    #Methods to be overriden in specific classes
    
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new;

        $self->{parsingError} = '';
        $self->{modelAlreadySet} = 0;

        bless ($self, $class);
        return $self;
    }

    sub getFilePatterns
    {
       return (['*.*', '*.*']);
    }

    sub getSuffix
    {
        my $self = shift;
        return '' if ! ($self->getFilePatterns)[0];
        (my $pattern = ($self->getFilePatterns)[0]->[1]) =~ s/.*?([[:alnum:]]+)/$1/;
        return $pattern;
    }

    #Return supported models name
    sub getModels
    {
        return [];
    }

    #Return current model name
    sub getModelName
    {
        return 'GCfilms';
    }

    sub getOptions
    {
    }
    
    sub wantsFieldsSelection
    {
        return 0;
    }

    sub wantsIgnoreField
    {
        return 0;
    }

    sub wantsImagesSelection
    {
        return 0;
    }
    
    sub wantsFileSelection
    {
        return 1;
    }
    
    sub wantsDirectorySelection
    {
        return 0;
    }
    
    # Returns true if the module should be hidden from
    # the menu when a collection of an incompatible kind is open.
    sub shouldBeHidden
    {
        return 0;
    }
    
    sub generateId
    {
        return 1;
    }
    
    sub getEndInfo
    {
    }
    
    sub getItemsArray
    {
    }

    #End of methods to be overriden
    
    # If you need really specific processing, you can instead override the process method
    
    sub process
    {
        my ($self, $options) = @_;
        $self->{options} = $options;

        $options->{parent}->{items}->updateSelectedItemInfoFromPanel;
        my $alreadySaved = 0;
        if ($options->{newList})
        {
            return if !$options->{parent}->checkAndSave;
            $alreadySaved = 1;
            $options->{parent}->setFile('');
        }
        $self->{options}->{parent}->setWaitCursor($self->{options}->{lang}->{ImportListTitle}.' ('.$options->{file}.')');
        my @tmpArray = @{$self->getItemsArray($options->{file})};

        if ($self->{parsingError})
        {
            $self->{options}->{parent}->restoreCursor;
            return $self->getEndInfo;
        }

        my $realModel = $self->getModelName;

        # Here we really know the model so we force a new list if needed
        if (($options->{newList})
         || ($options->{parent}->{model}->getName ne $realModel))
        {
            $options->{parent}->newList($realModel, $self->{modelAlreadySet}, $alreadySaved);
        }

        my $generateId = $self->generateId;
        foreach my $info(@tmpArray)
        {
            # option to set location (scanner)
            if ($options->{location})
            {
                $info->{location} = $options->{location};
                $info->{place} = $options->{location} if ($realModel eq 'GCfilms');
            }
            # option to set tags (scanner)
            if ($options->{tags})
            {
                undef $info->{tags};
                foreach my $tags (split /;/, $options->{tags})
                {
                    push @{$info->{tags}}, [$tags];
                }
            }
            my $itemExists = 0;
            if ($options->{overwriteItems})
            {
                # overwrite the first item with the same title or EAN/ISBN
                my $allItems = $options->{parent}->{items}->{itemArray};
                my $nbItems = scalar @{$allItems};
                my $overwriteName = $self->{model}->{commonFields}->{title};
                if ($self->{moduleName} =~ m/Scanner/)
                {
                    $overwriteName = 'ean';
                    $overwriteName = 'isbn' if ($realModel eq 'GCbooks' || $realModel eq 'GCcomics'); 
                }
                for (my $i=0; $i < $nbItems && ! $itemExists; $i++) {
                    if ($info->{$overwriteName} eq @{$allItems}[$i]->{$overwriteName})
                    {
                        $itemExists = 1;
                        $options->{parent}->{items}->writeItem($i,$info);
                    }
                }
            }
            if (! $itemExists)
            {
                $options->{parent}->{items}->addItem($info, !$generateId, 1);
            }
        }
        $options->{parent}->{items}->unselect;
        $self->{options}->{parent}->restoreCursor;
        
        $options->{parent}->checkPanelVisibility;
        $options->{parent}->selectFirst;
        $options->{parent}->markAsUpdated;
        $options->{parent}->viewAllItems;
        return $self->getEndInfo;
    }

    # This method could only be use if $self->{model} has been initialized
    sub copyPictures
    {
        my ($self, $itemsArray, $file) = @_;
        return if !$self->{model};
        foreach my $item(@$itemsArray)
        {
            my $title = $item->{$self->{model}->{commonFields}->{title}};
            foreach my $field(@{$self->{model}->{fieldsImage}})
            {
                (my $suffix = $item->{$field}) =~ s/.*?(\.[^.]*)$/$1/;
                my $imageFile = $self->{options}->{parent}->getUniqueImageFileName($suffix, $title);
                copy(localName(GCUtils::getDisplayedImage($item->{$field}, '', $file)),
                     localName($imageFile))
                    if $item->{$field};
                $item->{$field} = $imageFile;
            }
        }
    }

    # 3 methods below are created to implement interface
    # from GCFrame plugins could need to simulate if using
    # some backends
    sub preloadModel
    {
        my ($self, $model) = @_;
        # Preload the model into the factory cache
        $self->{modelsFactory}->getModel($model);
    }

    sub setCurrentModel
    {
        my ($self, $model) = @_;
        $self->{model} = $self->{modelsFactory}->getModel($model);
    }

    sub setCurrentModelFromInline
    {
        my ($self, $container) = @_;
        $self->{model} = GCModelLoader->newFromInline($self, $container);
    }
}

1;
