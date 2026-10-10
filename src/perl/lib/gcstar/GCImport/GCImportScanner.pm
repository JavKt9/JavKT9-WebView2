package GCImport::GCImportScanner;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2016-2018 Kerenoc
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
use threads;
use threads::shared;

use GCImport::GCImportBase;

{
    package GCScannerDialog;
    
    use base 'GCModalDialog';
    
    use XML::Simple;
    use IO::Socket::INET;

    my $scanned :shared;

    sub new
    {
        my ($proto, $parent, $lang, $model, $serverSocket, $port) = @_;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new($parent,
                                       $lang->{Waiting},
                                       'gtk-cancel' => 'cancel');
        bless($self, $class);

        $scanned = '';
        $self->{thr} = undef;
        $self->{timer} = undef;
        $self->{socket} = undef;
        
        $self->{lang} = $lang;
        $self->{model} = $model;
        $self->{accepted} = 0;
        print "\nDBG ScannerDialog new";
        my $table = new Gtk3::Grid();
        $table->set_row_spacing($GCUtils::halfMargin);
        $table->set_column_spacing($GCUtils::margin);
        $table->set_border_width($GCUtils::margin);
        $self->{previousLabel} = new GCLabel('');
        $self->{promptLabel} = new GCLabel($lang->{ScanPrompt});
        $table->attach($self->{previousLabel}, 0, 0, 1, 1);
        $table->attach($self->{promptLabel}, 0, 1, 1, 1);
        my $eanLabel = new GCLabel($lang->{EAN});
        $self->{ean} = new GCShortText;
        if ($serverSocket)
        {
            my $tmpSocket = IO::Socket::INET->new(
                Proto       => 'udp',
                PeerAddr    => '198.41.0.4', # a.root-servers.net
                PeerPort    => '53', # DNS
            );
            my $local_ip_address = $tmpSocket->sockhost;
            my $waitingMsg = '_ '.$local_ip_address." / ".$port.' _';
            $self->{ean}->setValue($waitingMsg);
            print "\nDBG ScannerDialog new msg ".$waitingMsg;
            $self->{network} = 1;
            $self->{serverSocket} = $serverSocket;
        }
        else
        {
            $self->{ean}->signal_connect('activate' => sub {$self->response('apply')} );
        }
        $table->attach($eanLabel, 0, 2, 1, 1);
        $table->attach($self->{ean}, 1, 2, 1, 1);
        $self->get_content_area->pack_start($table, 1, 1, 0);
        $table->show_all;
        $self->setCancelLabel($lang->{Terminate});
        # $self->setOkLabel($lang->{Terminate});
        $self->get_action_area->remove(($self->get_action_area->get_children)[$self->{okPosition}]);
        
        return $self;
    }
    
    sub setPrevious
    {
        my ($self, $previous) = @_;
        if (!$self->{first})
        {
            $self->{first} = 1;
            return;
        }
        my $label;
        if ($previous)
        {
            ($label = $self->{lang}->{Previous}) =~ s|%s|<b>$previous</b>|;
        }
        else
        {
            my $previous = $self->{previousCode};
            ($label = $self->{lang}->{NothingFound}) =~ s|%s|<b>$previous</b>|;
        }
        $self->{previousLabel}->set_markup($label);
        $self->{promptLabel}->set_label($self->{lang}->{ScanOtherPrompt});
    }
    
    sub readSocket
    {
        my ($self) = @_;
        print "\nDBG readSocket ".$self->{socket}->fileno;
        Glib::Source->remove($self->{socketWatch}) if $self->{socketWatch};
        my $socket = $self->{socket};
        my $line = <$socket>;
        print "\nDBG readSocket empty" if !$line;
        if (0 && $^O =~ /win32/i && !$line) 
        {
            $self->{socket}->close;
            $self->{socket} = undef;
            print "\nDBG readSocket stopping thread";
            threads->exit(1);
            return;
        }
        return if ! $line;
        # $self->response('cancel') if !$line;
        print "\nDBG readSocket got ".$line;
        my $xs = XML::Simple->new;
        my $scan = $xs->XMLin($line);
        my $code = $scan->{scan}->{content};
        #$code = $self->eanToIsbn($code)
        #    if $self->{model} eq 'GCbooks';
        $self->{ean}->setValue($code);
        $self->{previousCode} = $code;
        print "\nDBG readSocket code ".$code;
        $scanned = $code if ($^O =~ /win32/i && $scanned ne '_STOP_'); #GTK3
        $self->response('apply') if ($^O !~ /win32/i); #GTK3
    }
    
    sub waitForCode
    {
        my $self = shift;
        print "\nDBG waitForCode ";
        if ($^O !~ /win32/i) #GTK3
        {
            print "\nDBG waitForCode watch socket ".$self->{socket}->fileno;
            $self->{socketWatch} = Glib::IO->add_watch($self->{socket}->fileno,
            'in',
            sub {
                  $self->readSocket;
            });
            print "\nDBG waitForCade wait for read launched";
        }
        else
        {
            #$self->{thr}->detach;
            $SIG{'KILL'} = sub {
                print "\nDBG waitForCode killed ".$self->{socket};
                $self->{socket}->close if $self->{socket};
                print "\nDBG waitForCode socket closed ".$self->{socket};
                threads->exit();
                print "\nDBG waitForCode socket end ";
            };
            print "\nDBG waitForCode socket ".$self->{socket};
            $self->{socket} = $self->{serverSocket}->accept
                if (! $self->{socket});
            print "\nDBG waitForCode socket connect accepted";
            my $loop = 10;
            while ($loop && $scanned ne '_STOP_')
            {
                $self->readSocket;
                #$loop = 0 if ($scanned eq '');
                print "\nDBG waitForCode loop ".$loop." ".$scanned;
                $loop--;
            }
        }
    }
    
    sub clock {
        my $self = shift;
        print "\nDBG clock";
        if ($scanned ne '')
        {
            print "\nDBG clock ean ".$scanned;
            $self->{ean}->setValue($scanned);
            $scanned = '';
            $self->response('apply');
            return 0;
        }
        return 1;
    }
    
    sub eanToIsbn
    {
        my ($self, $code) = @_;
        return $code if $code !~ /978(\d{9})/;
        my $sub = $1;
        my $multiplier = 1;
        my $checkSum = 0;
        foreach (split(//, $sub))
        {
            $checkSum += $_ * $multiplier++;
        }
        $checkSum %= 11;
        $checkSum = 'X' if $checkSum == 10;
        print "\nScanner ISBN ".$sub.$checkSum;
        return $sub.$checkSum;
    }

    sub show
    {
        my $self = shift;
        my $thr = shift;
        
        print "\nDBG show";
        $self->SUPER::show();
        $self->show_all;
        $self->showMe;
        if ($self->{network})
        {
            print "\nDBG show accepted ".$self->{accepted};
            if (!$self->{accepted})
            {
                if ($^O =~ /win32/i) #GTK3
                {
                    Glib::Object->set_threadsafe (1);
                    $self->{thr} = threads::async(\&waitForCode, $self)
                        if (! $self->{thr});
                    $self->{thr}->set_thread_exit_only(1);
                    # $self->{thr}->detach;
                    $self->{timer} = Glib::Timeout->add (1000,\&clock, $self, $self->{thr});
                    # $thr->join;
                }
                else
                {
                    print "\nDBG show watch server socket ".$self->{serverSocket}->fileno;
                    $self->{serverWatch} = Glib::IO->add_watch($self->{serverSocket}->fileno,
                        'in',
                        sub {
                            print "\nDBG show accepting connexion ".$self->{serverSocket}->fileno;
                            return if $self->{socket}; # connexion may trigger twice
                            $self->{socket} = $self->{serverSocket}->accept;
                            $self->{accepted} = 1;
                            $self->waitForCode;
                        });
                }
            
            }
            else
            {
                print "\nDBG show waiting for code";
                $self->waitForCode if ($^O !~ /win32/i);
            }
        }
        else
        {
            print "\nDBG show empty focus";
            $self->{ean}->setValue('');
            $self->{ean}->grab_focus;
        }
        print "\nDBG show dialog run";
        my $code = $self->run;
        print "\nDBG show dialog end run ".$code;
        $self->hide;
        return $self->{ean}->getValue if $code eq 'apply';
        Glib::Source->remove($self->{timer}) if ($self->{timer});
        $self->{socket}->close if ($self->{socket});
        $self->{socket} = undef;
        $scanned = '_STOP_';
        #print "\nDBG killing thread ".$self->{thr}." ".ref($self->{thr});
        #$self->{thr}->kill('TERM');
        #$self->{thr}->kill('KILL')->detach if $self->{thr};
        #print "\nDBG thread closed";
        return undef;
    }
}

{
    package GCImport::GCImporterScanner;

    use base qw(GCImport::GCImportBaseClass);

    use IO::Socket;
    use GCPlugins;

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        
        bless ($self, $class);
        return $self;
    }

    sub wantsFieldsSelection
    {
        return 0;
    }

    sub wantsFileSelection
    {
        return 0;
    }
    
    sub hideFileSelection
    {
        return 1;
    }
    
    sub getFilePatterns
    {
       return ();
    }
    
    sub checkPortField
    {
        my ($self, $data) = @_;
        my ($parent, $list) = @{$data};
        my $model = $list->getValue ;
        $parent->{options}->{port}->set_sensitive($model eq 'Network');
    }

    sub getOptions
    {
        my $self = shift;
        
        my $pluginsList = '';
        my $nameEAN;
        foreach (@{$self->{model}->getPluginsNames})
        {
            my $plugin = $GCPlugins::pluginsMap{$self->{model}->getName}->{$_};
            if ($plugin->getEanField)
            {
                $pluginsList .= $plugin->getName . ',';
                $nameEAN = $plugin->getEanField;
            }
        }
        
        return [
            {
                name => 'type',
                type => 'options',
                label => 'Type',
                valuesList => 'Local,Network',
                default => 'Local',
                changedCallback => sub {shift; $self->checkPortField(@_)},
            },
            {
                name => 'port',
                type => 'number',
                label => 'Port',
                default => 50007,
                min => 1024,
                max => 65536,
            },
            {
                name => 'plugin',
                type => 'options',
                label => 'Plugin',
                valuesList => $pluginsList
            },
            {
                name => 'first',
                type => 'yesno',
                label => 'UseFirst',
                default => '1'
            },
            {
                name => 'overwriteItems',
                type => 'yesno',
                label => $self->{model}->{parent}->{lang}->{ImportOverwriteItems}." (".$nameEAN.")",
                default => '0'
            },
            {
                name => 'location',
                type => 'short text',
                label => 'PanelLocation',
                tooltip => 'LocationTooltip',
                default => '',
            },
            {
                name => 'tags',
                type => 'short text',
                label => 'PanelTags',
                tooltip => 'TagsTooltip',
                default => '',
            },
         ];
    }

    sub getModelName
    {
        my $self = shift;
        return $self->{model}->getName;
    }

    sub getBarCode
    {
        my ($self, $previous) = @_;
        #my $dialog = new
        $self->{dialog}->setPrevious($previous);
        return $self->{dialog}->show;
    }

    sub getItemsArray
    {
        my ($self, $file) = @_;
        my @result;
        
        #First we try to get the correct plugin
        my $plugin = $GCPlugins::pluginsMap{$self->{model}->getName}->{$self->{options}->{plugin}};
        $plugin->{bigPics} = $self->{options}->{parent}->{options}->bigPics;

        my $titleField = $self->{model}->{commonFields}->{title};
        my $searchField = $plugin->getEanField;
        my $pass = 1; # currently only one pass supported

        my $i = 0;

        my $resultsDialog;
        if (!$self->{options}->{first})
        {
            $resultsDialog = $self->{options}->{parent}->getDialog('Results');
            $resultsDialog->setModel($self->{model}, $self->{model}->{fieldsInfo});
            $resultsDialog->setMultipleSelection(0);
        }
        my $search;
        
        my $socket;
        if ($self->{options}->{type} eq 'Network')
        {
            print "\nDBG getItemsArray new socket ".$self->{options}->{port};
            $socket = new IO::Socket::INET(
                LocalPort => $self->{options}->{port},
                Proto => 'tcp',
                Listen => 1,
                Reuse => 1
            );
        }
        
        $self->{dialog} = new GCScannerDialog($self->{options}->{parent},
                                              $self->getLang,
                                              $self->{model}->getName,
                                              $socket,
                                              $self->{options}->{port});
        my $previous = '';
        while ($search = $self->getBarCode($previous))
        {
            chomp $search;
            next if ! $search;
            # prepare the plugin
            $plugin->setProxy($self->{options}->{parent}->{options}->proxy);
            $plugin->setCookieJar($self->{options}->{parent}->{options}->cookieJar);
            # $_ contains the title to search
            $plugin->{title} = $search;
            $plugin->{pass} = $pass;
            $plugin->{type} = 'load';
            $plugin->{urlField} = $self->{model}->{commonFields}->{url};
            $plugin->{searchField} = $searchField;
            $plugin->{nextUrl} = "" if ($pass == 1);
            
            #Initialize what will be pushed in the array
            my $info = {$searchField => $search};
            
            $self->{options}->{parent}->setWaitCursor($self->{options}->{lang}->{StatusSearch}.' ('.$search.')');
            $plugin->load;

            my $itemNumber = $plugin->getItemsNumber;

            if ($itemNumber != 0)
            {
                $plugin->{type} = 'info';
                if (($itemNumber == 1) || ($self->{options}->{first}))
                {
                    $plugin->{wantedIdx} = 0;
                }
                else
                {
                    my $withNext = 0;
                    my @items = $plugin->getItems;
                    $resultsDialog->setWithNext(0);
                    $resultsDialog->setSearchPlugin($plugin);
                    $resultsDialog->setList($search);
                    $resultsDialog->show;
                    if ($resultsDialog->{validated})
                    {
                        $plugin->{wantedIdx} = $resultsDialog->getItemsIndexes->[0];
                    }
                }
                $info = $plugin->getItemInfo;
                my $title = $info->{$titleField};
                $info->{$plugin->getEanField} = $search if (! $info->{$plugin->getEanField});
                $self->{options}->{parent}->{defaultPictureSuffix} = $plugin->getDefaultPictureSuffix;
                foreach my $field(@{$self->{model}->{managedImages}})
                {
                    $info->{$field} = '' if $info->{$field} eq 'empty';
                    next if !$info->{$field};
                    ($info->{$field}) = $self->{options}->{parent}->downloadPicture($info->{$field}, $title);
                }

                # Add the default value
                my $defaultInfo = $self->{model}->getDefaultValues;
                foreach my $field(keys %$defaultInfo)
                {
                    next if exists $info->{$field};
                    $info->{$field} = $defaultInfo->{$field};
                }
            }
            $previous = $info->{$titleField};
            push @result, $info;
            $self->{options}->{parent}->restoreCursor;
        }
        $socket->close if $socket;
        return \@result;
    }
    
    sub getEndInfo
    {
        my $self = shift;
        my $message;
        return $message;
    }
}

1;
