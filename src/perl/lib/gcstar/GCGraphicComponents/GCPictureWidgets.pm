package GCImageListWidget;

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

{
    package GCItemImage;
    
    use Glib::Object::Subclass
                Gtk3::Image::
    ;
    
    @GCItemImage::ISA = ('Gtk3::Image', 'GCGraphicComponent');

    use File::Spec;
    use File::Basename;

    use GCUtils 'localName';

    sub new
    {
        my ($proto, $options, $parent, $fixedSize, $width, $height) = @_;
        my $class = ref($proto) || $proto;
#        my $self  = Gtk3::Image->new_from_file($parent->{defaultImage});
        my $self  = Gtk3::Image->new;
        $self->{options} = $options;
        #$self->{defaultImage} = $defaultImage;
        $self->{parent} = $parent;
        $self->{displayedImage} = '';
        $self->{fixedSize} = $fixedSize;
        bless ($self, $class);
        if ($width && $height)
        {
            $self->{width} = $width;
            $self->{height} = $height;
        }
        else
        {
            $self->{width} = 120;
            $self->{height} = 160;
        }
        $self->{immediate} = 0;
        return $self;
    }

    sub setImmediate
    {
        my ($self) = @_;
        $self->{immediate} = 1;
    }
    sub activateStateTracking
    {
        my $self = shift;
        $self->{trackState} = 1;
    }

    sub isEmpty
    {
        my $self = shift;
        
        return $self->getValue eq '';
    }
    
    sub setValue
    {
        my ($self, $displayedImage, $placer) = @_;
        $self->{displayedImage} = $displayedImage;
        $self->setChanged if $self->{trackState};
        if ($self->{immediate})
        {
            $self->setPicture;
            $placer->placeImg if $placer;
        }
        else
        {
            Glib::Source->remove($self->{timer})
                if $self->{timer};
            $self->{timer} = Glib::Timeout->add(100, sub {
                $self->setPicture;
                $placer->placeImg if $placer;
                return 0;
            });
        }
    }

    sub setPicture
    {
        my $self = shift;
        $self->{timer} = 0;
        my $displayedImage = GCUtils::getDisplayedImage($self->{displayedImage},
                                                        $self->{parent}->{defaultImage},
                                                        $self->{options}->file);
        my $pixbuf;
        eval
        {
            $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file(localName($displayedImage));
        };
        if ($@)
        {
            $displayedImage = $self->{parent}->{defaultImage};
            $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file(localName($displayedImage));
        }
        $self->{realImage} = $displayedImage;
        $pixbuf = GCUtils::scaleMaxPixbuf($pixbuf, $self->{width}, $self->{height});
        $self->set_from_pixbuf($pixbuf);
        $self->set_size_request($self->{width}, $self->{height}) if $self->{fixedSize};
    }
    
    sub getValue
    {
        my $self = shift;
        return $self->{displayedImage};
    }

    sub getFile
    {
        my $self = shift;
        return $self->{realImage};
    }

    sub clear
    {
        my $self = shift;
        $self->setValue('');
    }
    
    sub lock
    {
        my ($self, $locked) = @_;
    }
    
    sub setWidth
    {
        my ($self, $value) = @_;
        $self->{width} = $value;
    }

    sub setHeight
    {
        my ($self, $value) = @_;
        $self->{height} = $value;
    }
    
    sub getSize
    {
        my $self = shift;
        my $pixbuf = $self->get_pixbuf;
        return ($pixbuf->get_width, $pixbuf->get_height);
    }
}


our $hasGnome2VFS;
BEGIN {
    eval 'use Gnome2::VFS';
    if ($@)
    {
        $hasGnome2VFS = 0;
    }
    else
    {
        $hasGnome2VFS = 1;
        Gnome2::VFS->init();
    }
}

{
    package GCImageButton;

    use Glib::Object::Subclass
                Gtk3::Button::
    ;
    
    our $defaultImageDirectory = ''; # when adding a new picture

    @GCImageButton::ISA = ('Gtk3::Button', 'GCGraphicComponent');

    use File::Basename;
    use Encode;

    use GCUtils 'localName';

    sub setChanged
    {
        my $self = shift;
        $self->SUPER::setChanged;
        $self->{watcher}->notifyImgChange($self) if $self->{watcher};   
    }
    
    sub setWatcher
    {
        my ($self, $watcher) = @_;
        $self->{watcher} = $watcher;
    }

    sub animateImg
    {
        my ($self, $from, $to) = @_;
        my $pixbuf1 = Gtk3::Gdk::Pixbuf->new_from_file(localName($from));
        $pixbuf1 = GCUtils::scaleMaxPixbuf($pixbuf1, $self->{img}->{width}, $self->{img}->{height});
        my $pixbuf2 = Gtk3::Gdk::Pixbuf->new_from_file(localName($to));
        $pixbuf2 = GCUtils::scaleMaxPixbuf($pixbuf2, $self->{img}->{width}, $self->{img}->{height});
        my $height = $pixbuf2->get_height;
        my $width = $pixbuf2->get_width;
        foreach my $i(0..20)
        {
            Glib::Timeout->add(30*$i, sub {
                my $pixbufA = $pixbuf1->copy;
                my $pixbufB = $pixbuf2->copy;
                $pixbufA->composite($pixbufB, 0, 0, int($width - (($i/20)*$width)), $height, 0, 0, 1, 1, 'nearest', 255);
                $self->{img}->set_from_pixbuf($pixbufB);
            });
        }
    }

    sub setImg
    {
        my ($self, $value) = @_;
        $self->{img}->setValue($value, $self);
    }

    sub placeImg
    {
        my ($self) = @_;
        my ($picWidth, $picHeight) = $self->{img}->getSize;
        my ($buttonWidth, $buttonHeight) = ($self->get_allocation->{width}, $self->get_allocation->{height});
        my $x = int(($buttonWidth - $picWidth - $GCUtils::margin)/ 2);
        my $y = int(($buttonHeight -$picHeight - $GCUtils::margin)/ 2);

        # Don't allow negative positions, can happen when button has not been allocated a width/height yet
        $x = 0 if ($x < 0);
        $y = 0 if ($y < 0);
        if ($self->{img}->get_parent)
        {   
            $self->{layout}->move($self->{img}, $x, $y);
        }
        else
        {
            $self->{layout}->put($self->{img}, $x, $y);
            $self->show_all;
        }
    }

    sub changeState
    {
        my $self = shift;
        if ($self->{trackState})
        {
            if ($self->{flipped})
            {
                $self->{linkedComponent}->setChanged;
            }
            else
            {
                $self->setChanged;
            }
        }
    }

    sub clearImage
    {
        my $self = shift;

        $self->changeState;
        $self->{mainParent}->checkPictureToBeRemoved($self->{imageFile});
        $self->setValueWithParent('');
    }

    sub changeImage
    {
        my ($self, $fileName) = @_;
        return 0 if $self->{locked};
        if (!$fileName)
        {
            my $imageDialog = GCFileChooserDialog->new($self->{parent}->{lang}->{PanelImageTitle}, $self->{mainParent}, 'open');
            $imageDialog->setWithImagePreview(1);

            my $currentFile = $self->{img}->getValue;
            if ($currentFile && -r localName($currentFile))
            {
                $imageDialog->set_filename($currentFile);
            }
            else
            {
                $self->{parent}->{previousDirectory} = $defaultImageDirectory
                    if ($defaultImageDirectory ne '');
                $imageDialog->set_filename($self->{parent}->{previousDirectory});
            }
            my $response = $imageDialog->run;
            $fileName = $imageDialog->get_filename;
            $imageDialog->destroy;

            $self->{parent}->showMe;
            if ($response eq 'ok')
            {
                $self->{parent}->{previousDirectory} = dirname($fileName);
                $defaultImageDirectory = dirname($fileName);
                $self->setChanged if $self->{trackState};
            }
            else
            {
                return;
            }
        }

        my $ref = ($self->{flipped} ? $self->{backPic} : $self->{imageFile});
        if ($fileName ne $ref)
        {
            $self->{mainParent}->checkPictureToBeRemoved($ref);
            $self->changeState;
        }
        my $image = $self->{mainParent}->transformPicturePath($fileName);
        $self->setValueWithParent($image);
        return;        
    }
    
    sub isEmpty
    {
        my $self = shift;
        
        return $self->getValue eq '';
    }
    
    sub setValue
    {
        my ($self, $value) = @_;        
        $self->setChanged if $self->{trackState};
        $self->setActualValue($value);
    }

    sub setValueWithParent
    {
        my ($self, $value, $keepWatcher) = @_;
        
        $self->setActualValue($value, $keepWatcher, $self->{flipped});
        if ($self->{isCover} && !$self->{flipped})
        {
            $self->{mainParent}->{items}->updateSelectedItemInfoFromPanel(0, [$self->{name}]);
            $self->{hasChanged} = 0 if $self->{parent} eq $self->{mainParent}->{panel} && !$keepWatcher;
        }
    }

    sub setActualValue
    {
        my ($self, $value, $keepWatcher, $flipped) = @_;
        Glib::Source->remove($self->{fileWatcher})
            if $self->{fileWatcher} && !$keepWatcher;
        if ($flipped)
        {
            $self->{backPic} = $value;
        }
        else
        {
            $self->{imageFile} = $value;
        }
        $self->setImg($value);
    }

    sub getValue
    {
        my $self = shift;
        if ($self->{flipped})
        {
            return $self->{imageFile};
        }
        return $self->{img}->getValue;
    }

    sub setLinkedActivated
    {
        my ($self, $value) = @_;
        $self->flipImage(1) if $self->{flipped};
        $self->{flipActivated} = $value;
    }

    sub flipImage
    {
        my ($self, $noButton) = @_;
        my $newLabel;
        if ($self->{flipped})
        {
            $self->setImg($self->{imageFile});
            $self->{frontFlipImage}->show if !$noButton;
            $self->{backFlipImage}->hide;
            #$self->animateImg($self->{backPic}, $self->{imageFile});
        }
        else
        {
            $self->setImg($self->{backPic});
            $self->{backFlipImage}->show if !$noButton;
            $self->{frontFlipImage}->hide;
            #$self->animateImg($self->{imageFile}, $self->{backPic});
        }
        $self->{flipped} = !$self->{flipped};
    }

    sub setLinkedValue
    {
        my ($self, $linkedValue) = @_;
        $self->setChanged if $self->{trackState};
        $self->{backPic} = $linkedValue;
        $self->setImg($linkedValue) if $self->{flipped};
    }

    sub getLinkedValue
    {
        my ($self, $linkedValue) = @_;
        return $self->{backPic};
    }

    sub setLinkedComponent
    {
        my ($self, $linked) = @_;
        $self->{linkedComponent} = $linked;

        $self->{flipActivated} = 1;
        $self->{frontFlipImage} = Gtk3::Image->new_from_file($ENV{GCS_SHARE_DIR}.'/overlays/flip.png');
        $self->{frontFlipImage}->set_no_show_all(1);
        $self->{backFlipImage} = Gtk3::Image->new_from_file($ENV{GCS_SHARE_DIR}.'/overlays/flip2.png');
        $self->{backFlipImage}->set_no_show_all(1);
        my $pixbuf = $self->{frontFlipImage}->get_pixbuf;
        my ($picWidth, $picHeight) = ($pixbuf->get_width, $pixbuf->get_height);

        $self->{addedFlipButton} = 0;
        $self->signal_connect('enter' => sub {
            return if ! $self->{flipActivated};
            if (!$self->{addedFlipButton})
            {
                $self->{flipX} = $self->{width} - $picWidth - $GCUtils::margin;
                $self->{flipY} = $self->{height} - $picHeight - $GCUtils::margin;
                $self->{layout}->put($self->{frontFlipImage},
                                     $self->{flipX},
                                     $self->{flipY});
                $self->{layout}->put($self->{backFlipImage},
                                     $self->{flipX},
                                     $self->{flipY});
                $self->{addedFlipButton} = 1;
            }
            if ($self->{flipped})
            {
                $self->{backFlipImage}->show;
            }
            else
            {
                $self->{frontFlipImage}->show;
            }
        });
        $self->signal_connect('leave' => sub {
            $self->{frontFlipImage}->hide;
            $self->{backFlipImage}->hide;
        });
        $self->signal_connect('button-release-event' => sub {
            return 0 if ! $self->{flipActivated};
            my ($button, $event) = @_;
            my ($x, $y) = $event->get_coords;
            if (($x > $self->{flipX}) && ($y > $self->{flipY}))
            {
                $self->flipImage;
                $self->set_sensitive(0);
                $self->released;
                $self->set_sensitive(1);
                return 1;
            }
            else
            {
                return 0;
            }
        });
        
        $self->signal_connect('key-press-event' => sub {
            return 0 if ! $self->{flipActivated};
            my ($widget, $event) = @_;
            my $key = Gtk3::Gdk::keyval_name($event->keyval);
            
            if (($key eq 'f') || ($key eq 'BackSpace'))
            {
                $self->flipImage;
                return 1;
            }
            return 0;
        });
        
        $self->signal_connect('query_tooltip' => sub {
            my ($window, $x, $y, $keyboard_mode, $tip) = @_;
            return if $self->{settingTip};
            $self->{settingTip} = 1;
            if ($self->{flipActivated} && ($x > $self->{flipX}) && ($y > $self->{flipY}))
            {
                $self->set_tooltip_text($self->{flipped} ?
                                             $self->{parent}->{lang}->{ContextImgFront} :
                                             $self->{parent}->{lang}->{ContextImgBack});
            }
            else
            {
                $self->set_tooltip_text($self->{tip});
            }
            $self->{settingTip} = 0;
            return 0;
        });
        
    }

    sub clear
    {
        my $self = shift;
        $self->setValue('');
    }

    sub new
    {
        my ($proto, $parent, $img, $isCover, $default) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new;
        bless ($self, $class);

        $default = 'view' if !$default;

        $self->{layout} = new Gtk3::Fixed;
        $self->{layout}->put($img, 0, 0);
        $self->add($self->{layout});
        
        $self->{img} = $img;
        $self->{default} = $default;
        #$self->set_size_request(130,170);
        $self->{width} = -1;
        $self->{height} = -1;
        $self->{imageFile} = $img->getValue;

        # True if this is the cover used in image mode
        $self->{isCover} = $isCover;

        $self->{parent} = $parent;
        $self->getMainParent;

        $self->{tip} = ($default eq 'open') ? $parent->{lang}->{PanelImageTipOpen} : $parent->{lang}->{PanelImageTipView};
        $self->{tip} .= $parent->{lang}->{PanelImageTipMenu};
        $self->set_tooltip_text($self->{tip});

        $self->signal_connect('button_press_event' => sub {
            my ($widget, $event) = @_;
            return 0 if $event->button ne 3;
            $self->createContextMenu();
            $self->{imgContext}->popup(undef, undef, undef, undef, $event->button, $event->time);
            return 0;
        });

        $self->signal_connect('clicked' => sub {
            $self->changeImage if $self->{default} eq 'open';
            $self->showImage if $self->{default} eq 'view';
            return 1;
        });

        #Drag and drop a picture on a button
        $self->drag_dest_set('all', [], ['copy','private','default','move','link','ask']);
        my $target_list = Gtk3::TargetList->new();
        my $atom1 = Gtk3::Gdk::Atom::intern('text/uri-list',0);
        my $atom2 = Gtk3::Gdk::Atom::intern('text/plain',0);
        $target_list->add($atom1, 0, 0);
        $target_list->add($atom2, 0, 0);
        if ($^O =~ /win32/i)
        {
            my $atom2 = Gtk3::Gdk::Atom::intern('DROPFILES_DND',0);
            $target_list->add($atom2, 0, 0);
        }
        $self->drag_dest_set_target_list($target_list);
        $self->signal_connect(drag_data_received => sub {
            my ($widget, $context, $widget_x, $widget_y, $data, $info,$time) = @_;
            my @files = split /\n/, $data->data;
            my $fileName = $files[0];
            if ($fileName =~ /^http/)
            {
                $fileName = $self->{mainParent}->downloadPicture($fileName);
            }
            else
            {
                $fileName =  Glib::filename_from_uri  $fileName; 
                $fileName = decode('utf8', $fileName);           
                $fileName =~ s|^file://?(.*)\W*$|$1|;
                $fileName =~ s|^/*|| if ($^O =~ /win32/i);
                $fileName =~ s/.$//ms;
                $fileName =~ s/%20/ /g;
            }
            $self->changeImage($fileName);
        });

        $self->{parent}->{previousDirectory} = '';
        $self->{flipped} = 0;
        $self->{flipActivated} = 0;

        return $self;
    }
    
    sub createContextMenu
    {
        my $self = shift;
        
        my $parent;
        $parent = $self->{parent};

        $self->{imgContext} = new Gtk3::Menu;

        if ($parent->{options}->tearoffMenus)
        {
            $self->{imgContext}->append(Gtk3::TearoffMenuItem->new());
        }

        $self->{itemOpen} = Gtk3::ImageMenuItem->new_with_mnemonic($parent->{lang}->{ContextChooseImage});
        my $itemOpenImage = Gtk3::Image->new_from_stock('gtk-open', 'menu');
        $self->{itemOpen}->set_image($itemOpenImage);
        # This item will be deactivated if the component is locked
        $self->{itemOpen}->set_sensitive(!$self->{locked});
        $self->{itemOpen}->signal_connect("activate" , sub {
            $self->changeImage;
        });
        $self->{imgContext}->append($self->{itemOpen});
        $self->{itemShow} = Gtk3::ImageMenuItem->new_from_stock('gtk-zoom-100',undef);
        $self->{itemShow}->signal_connect("activate" , sub {
            $self->showImage;
        });
        # Disable for default image
        $self->{itemShow}->set_sensitive(0) if $self->isDefaultImage();
        $self->{imgContext}->append($self->{itemShow});

        if ($self->{linkedComponent})
        {
            $self->{itemFlip} = Gtk3::MenuItem->new($self->{flipped} ?
                                                        $parent->{lang}->{ContextImgFront} :
                                                        $parent->{lang}->{ContextImgBack});
            $self->{itemFlip}->signal_connect("activate" , sub {
                $self->flipImage;
            });
            $self->{imgContext}->append($self->{itemFlip});
        }

        $self->{itemClear} = Gtk3::ImageMenuItem->new_from_stock('gtk-clear',undef);
        # This item will be deactivated if the component is locked
        $self->{itemClear}->set_sensitive(!$self->{locked});
        $self->{itemClear}->signal_connect("activate" , sub {
            $self->clearImage;
        });
        $self->{imgContext}->append($self->{itemClear});        
        # Disable for default image
        $self->{itemClear}->set_sensitive(0) if $self->isDefaultImage();
        $self->{imgContext}->show_all;

        my $itemOpenWith = Gtk3::MenuItem->new_with_mnemonic($parent->{lang}->{ContextOpenWith});
        $self->{menuOpenWith} = Gtk3::Menu->new;

        if ($hasGnome2VFS && ($parent->{options}->programs eq 'system' || $parent->{options}->imageEditor eq ''))
        { 
            # Get applications for mime types corresponding with image

            # Get all editors/viewers for jpeg file format
            my $mimeTest = Gnome2::VFS::Mime::Type->new ("image/jpeg");
            my @mimeList = $mimeTest->get_short_list_applications;

            # Add applications to open with list
            foreach (@mimeList)
            {
                my $launchApp = $_;
                my $item = Gtk3::MenuItem->new_with_mnemonic($launchApp->get_name);
                $item->signal_connect ('activate' => sub {
                        $self->openWith($launchApp);
                });
                $self->{menuOpenWith}->append($item);
            }

            #Gnome2::VFS -> shutdown();
        }
        elsif ($parent->{options}->programs eq 'system' || $parent->{options}->imageEditor eq '')
        {
            # Can't parse applications, so use system default app  
            my $item = Gtk3::MenuItem->new_with_mnemonic($parent->{lang}->{ContextImageEditor});

            my $command;
            $command = ($^O =~ /win32/i) ? ''
                     : ($^O =~ /macos/i) ? '/usr/bin/open'
                     :                     'xdg-open';

            # Not sure if this is correct, haven't tested with Windows:
            if ($^O =~ /win32/i)
            {
                $command = '"'.$command.'"' if $command;
            }

            $item->signal_connect ('activate' => sub {
                     $self->openWithImageEditor($command);
            });

            $self->{menuOpenWith}->append($item);
        }
        else
        {
            # Use user defined app  
            my $item = Gtk3::MenuItem->new_with_mnemonic($parent->{lang}->{ContextImageEditor});
            $item->signal_connect ('activate' => sub {
                     $self->openWithImageEditor($parent->{options}->imageEditor);
            });

            $self->{menuOpenWith}->append($item);
        }


        $itemOpenWith->set_submenu($self->{menuOpenWith});
       
        # Disable for default image
        $itemOpenWith->set_sensitive(0) if $self->isDefaultImage();

        $self->{imgContext}->append($itemOpenWith);
        
        if (exists $self->{extraStock})
        {
            $self->{imgContext}->append(Gtk3::SeparatorMenuItem->new);
            $self->{extraMenu} = Gtk3::ImageMenuItem->new_from_stock($self->{extraStock}, undef);
            $self->{extraMenu}->set_sensitive(!$self->{locked});
            $self->{extraMenu}->signal_connect('activate' => $self->{extraCallback});
            $self->{imgContext}->append($self->{extraMenu});
        }
        
        $self->{imgContext}->show_all;

    }

    sub activateStateTracking
    {
        my $self = shift;
        $self->{trackState} = 1;
    }

    sub addCallbackWithStock
    {
        my ($self, $stock, $callback) = @_;
        $self->{extraStock} = $stock;
        $self->{extraCallback} = $callback;
    }
    
    sub lock
    {
        my ($self, $locked) = @_;
    
        $self->{locked} = $locked;
    }
    
    sub showImage
    {
        my $self = shift;
        $self->{mainParent}->launch($self->{img}->getValue, 'image');
    }
    
    sub isDefaultImage
    {
        my ($self) = @_;

        if ($self->{img}->getFile eq $self->{parent}->{defaultImage})
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    sub openWith
    {
        my ($self, $app) = @_;
        my $cmd;
        my $escFileName;

        # Ultra hacky workaround, because $app->{launch} segfaults. See http://bugzilla.gnome.org/show_bug.cgi?id=315049
        # Probably should change to gvfs when perl modules are available

        if ($app->{command} =~ m/(\w*)/)
        {
            $cmd = $1;
        }

        $escFileName = $self->{img}->getFile;
        $escFileName =~ s/\ /%20/g;
        $self->editPicture("$cmd file://$escFileName");
    }

    sub openWithImageEditor
    {
        my ($self, $editor) = @_;
        my $file = $self->{img}->getFile;
        $file =~ s|/|\\|g if ($^O =~ /win32/i);
        $self->editPicture("$editor \"$file\"");
    }

    sub editPicture
    {
        my ($self, $commandLine) = @_;
        my $file = $self->{img}->getFile;

        my $flipped = $self->{flipped};
        $self->{fileWatchDays} = -M $file; 
        $self->{fileWatcher} = Glib::Timeout->add(1000, sub {
            my $currentDays = -M $file;
            if ($currentDays < $self->{fileWatchDays})
            {
                $self->changeState;
                # We remove it from the pixbuf cache in items view. Useful
                # for detailed list to be sure it will be re-loaded
                delete $self->{mainParent}->{itemsView}->{cache}->{$file}
                    if $self->{mainParent}->{itemsView}->{cache};
                $self->setValueWithParent($self->{img}->getValue, 1, $flipped);
                $self->{fileWatchDays} = $currentDays; 
            }
            return 1;
        });
        $self->{mainParent}->launch($commandLine, 'program', 1);
    }

    sub setWidth
    {
        my ($self, $value) = @_;
        $self->{width} = $value;
        $self->set_size_request($value, $self->{height});
        $self->{img}->setWidth($value - $GCUtils::margin);
    }

    sub setHeight
    {
        my ($self, $value) = @_;
        $self->{height} = $value;
        $self->set_size_request($self->{width}, $value);
        $self->{img}->setHeight($value - $GCUtils::margin);
    }
    
}


{
    package GCImageListWidget;
    
        use Glib::Object::Subclass
                Gtk3::VBox::
    ;
    
    @GCImageListWidget::ISA = ('Gtk3::VBox', 'GCGraphicComponent');
    
    
    
    
    sub new
    {
        my ($proto, $parent, $readonly, $info) = @_;
        my $class = ref($proto) || $proto;
    
        my $self = $class->SUPER::new;

        $self->{parent} = $parent;
        $self->{readonly} = $readonly;
        $self->{itemsPerRow} = $info->{itemsPerRow};
        $self->{pictureHeight} = $info->{pictureHeight};
        $self->{nbLines} = 0;
        
		my $hboxActions = new Gtk3::HBox(0,0);

        # If list belongs to an expander, set box size to a reasonable size
        $self->{signalHandler} = $self->signal_connect('size-allocate' => sub {
            if (($self->{realParent}) && ($self->{realParent}->isa('GCExpander')))
            {
                my $width = $self->get_allocation->{width} - ( 2 * $GCUtils::margin) ;
                $self->set_size_request(($width >= -1) ? $width : -1 , -1);
                return 0;
            }
        });

        $self->{list} = Gtk3::Grid->new();
        my $scroll = new Gtk3::ScrolledWindow;
        $scroll->set_policy ('automatic', 'automatic');
        $scroll->set_shadow_type('etched-in');
        $scroll->set_size_request(-1, 120);
        $scroll->add_with_viewport($self->{list});
        $self->pack_start($scroll, 1, 1, 2);
        
        
        if (!$readonly)
        {
            $self->{addButton} = GCButton->newFromStock('gtk-add', 0);
            $self->{addButton}->signal_connect('clicked' => sub {
                $self->addImage;
                $self->show_all;
                $self->setChanged;
                $self->forceDisplay;                
            });
            $hboxActions->pack_start($self->{addButton}, 0, 0, 6);
        }
        else
        {
        }
        $self->pack_start($hboxActions, 0, 0, 6)
            if $readonly < 2;

        bless ($self, $class);
        return $self;
    }

    sub forceDisplay
    {
        my $self = shift;
        #FIXME Without this hack, the pictures are not initially shown until something is done
        #It seems to force a refresh
        Glib::Timeout->add(100, sub {
            #GTK $self->{list}->signal_emit('size-allocate', Gtk3::Gdk::Rectangle::new(0,0,$self->{list}->get_allocation->{width},$self->{list}->get_allocation->{height}));
            $self->{list}->signal_emit('size-allocate', {x=>0,y=>0,width=>$self->{list}->get_allocation->{width},height=>$self->{list}->get_allocation->{height}});
            return 0;
        });
    }

    sub notifyImgChange
    {
        my ($self,  $img) = @_;
        $self->setChanged;
    }

    sub addImage
    {
        my ($self, @values) = @_;
        my $img = new GCItemImage($self->{parent}->{options}, 
                                  $self->{parent},
                                  0,
                                  300,
                                  300);
        my $isCover = 0;
        my $widget = new GCImageButton($self->{parent}, $img, $isCover, $self->{default});
        $widget->setHeight($self->{pictureHeight});
        $widget->activateStateTracking;
        $widget->setWatcher($self);

        my ($lineWhereToAdd, $colWhereToAdd) = (0,0);
        my @children = $self->{list}->get_children;
        my $nbChildren = scalar @children;
        $lineWhereToAdd = int($nbChildren / $self->{itemsPerRow});
        $colWhereToAdd = $nbChildren % $self->{itemsPerRow};
        $self->{list}->attach($widget, $colWhereToAdd, $lineWhereToAdd, 1, 1);
        $widget->addCallbackWithStock('gtk-remove' => sub {
            $self->removeImage($widget);
        });

        return $widget;
    }
    
    sub coordToIdx
    {
        my ($self, $line, $col) = @_;
        return ($line * $self->{itemsPerRow}) + $col;
    }
    
    sub idxToCoord
    {
        my ($self, $idx) = @_;
        my ($line, $col);
        $line = int($idx / $self->{itemsPerRow});
        $col = $idx % $self->{itemsPerRow};
        return ($line, $col);
    }
    
    sub removeImage
    {
        my ($self, $imgToRemove) = @_;
        
        my @imgs = $self->getOrderedChildren;
        my $imgIdx = 0;
        my $found = 0;
        while ($imgIdx <= $#imgs)
        {
            if ($found)
            {
                $self->{list}->remove($imgs[$imgIdx]);
                my ($newLine, $newCol) = $self->idxToCoord($imgIdx - 1);
                $self->{list}->attach($imgs[$imgIdx], $newCol, $newLine, 1, 1);
            }
            elsif ($imgs[$imgIdx] == $imgToRemove)
            {
                $found = 1;
                $self->{list}->remove($imgs[$imgIdx]);
            }
            $imgIdx++;
        }
        $self->setChanged;
    }

    sub isEmpty
    {
        my $self = shift;
        
        return $self->getValue eq '';
    }
    
    sub getOrderedChildren
    {
        my $self = shift;
        my @orderedChildren;
        #get_children doesn't return items in order. It seems to be in reverse order
        #but to be sure, we just compute its rank in the array based on coordinates.
        for my $img($self->{list}->get_children)
        {
            my ($col, $line) = $self->{list}->child_get($img, qw(left-attach top-attach));
            $orderedChildren[$self->coordToIdx($line, $col)] = $img;
        }
        return @orderedChildren;        
    }
    
    sub getValue
    {
        my $self = shift;

        my @value;
        for my $img($self->getOrderedChildren)
        {
            push @value, [$img->getValue]
        }
        
        return \@value;
    }
    
    sub setValue
    {
        my ($self, $value) = @_;

        $self->clear;

        my @arrayValues;
        if (ref($value) ne 'ARRAY')
        {
            # The separator used was ; instead of ,
            $value =~ s/;/,/g if $value !~ /,/;
            my @values = split m/,/, $value;
            #TODO
            push @arrayValues, [$_] foreach @values;
            $value = \@arrayValues;
        }

        for my $imgPath(@{$value})
        {
            my $img = $self->addImage;
            $img->setValue($imgPath->[0]);
        }
        $self->forceDisplay;
        $self->show_all;
    }
    
    sub clear
    {
        my $self = shift;
        
        for my $img($self->{list}->get_children)
        {
            $self->{list}->remove($img);
            $img->destroy;
        }        
    }
    
    sub lock
    {
        my ($self, $locked) = @_;
        return if $self->{readonly};
        $self->{addButton}->set_sensitive(!$locked);
        foreach ($self->getOrderedChildren)
        {
            $_->lock($locked);
        }
    }    
    
}

1;
