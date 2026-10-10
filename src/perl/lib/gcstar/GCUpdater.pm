package GCUpdater;

###################################################
#
#  Copyright 2005 Tian
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

use LWP;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $BASE_URL = 'http://gitlab.com/Kerenoc/GCstar/raw/v';
my $INDEX_FILE = 'list_modified_files.txt';

{
    package GCRealUpdater;

    use File::Basename;
    use File::Path;
    
    use GCUtils 'localName';
    
    sub abort
    {
        my ($self, $msg) = @_;
        print "$msg\n";
        exit 1;
    }
    
    sub getNextFile
    {
        my $self = shift;
        
        return $self->{filesList}->[$self->{next}];
    }
    
    sub createBrowser
    {
        my ($self, $proxy) = @_;

        $self->{browser} = LWP::UserAgent->new;            
        $self->{browser}->proxy(['http'], $proxy) if $proxy;
    }
    
    sub checkFile
    {
        my ($self, $file) = @_;
        
        return 1 if $self->{toBeUpdated}->{all};
        foreach ('plugins', 'import', 'export', 'lang', 'models', 'extract')
        {
            return 1 if ($self->{toBeUpdated}->{$_}) && ($file =~ /$_/i);
        }
        return 0;
    }
    
    sub updateNext
    {
        my $self = shift;
        
        my $file = $self->{filesList}->[$self->{next}];
        print "Saving in ",$self->{baseInstallation}.$file,"\n";
        mkpath(localName(dirname($self->{baseInstallation}.$file)));
        my $response = $self->{browser}->get($self->{baseUrl}.$file, ':content_file' => $self->{baseInstallation}.$file);
        if (!$response->is_success)
        {
            print $response->message, "\n";
            #print $self->{lang}->{UpdateFileNotFound},"\n";
        }
        $self->{next}++;
    }
    
    sub getIndex
    {
        my $self = shift;
        print "Getting index file ".$self->{baseUrl}.$INDEX_FILE."\n";
        my $response = $self->{browser}->get($self->{baseUrl}.$INDEX_FILE, ':content_file' => $self->{baseInstallation}.$INDEX_FILE);
        $self->abort("!!! ".$self->{lang}->{UpdateNone}) if !$response->is_success;
        print "Saving in ".$self->{baseInstallation}.$INDEX_FILE."\n";
        open INDEX, localName($self->{baseInstallation}.$INDEX_FILE);
        $self->{filesList} = [];
        while (<INDEX>)
        {
            chomp;
            push @{$self->{filesList}}, $_
                if $self->checkFile($_);
        }
        close INDEX;
        $self->{total} = scalar @{$self->{filesList}};
    }
    
    sub total
    {
        my $self = shift;
        $self->getIndex if ( !defined $self->{total});
        return $self->{total};
    }
    
    sub new
    {
        my ($proto, $lang, $baseDir, $toBeUpdated, $version) = @_;
        my $class = ref($proto) || $proto;
        my $self  = {
            lang => $lang,
            baseUrl => $BASE_URL.$version.'_U/gcstar/lib/gcstar/',
            baseInstallation => $baseDir.'/',
            toBeUpdated => $toBeUpdated
        };
        bless ($self, $class);
        $self->abort($self->{lang}->{UpdateNoPermission}.$baseDir) if (! -w localName($baseDir));     
        $self->{next} = 0;
        $self->{total} = undef;

        return $self;        
    }
}

{
    package GCTextUpdater;
    
    sub new
    {
        my ($proto, $lang, $baseDir, $toBeUpdated, $noProxy, $version) = @_;
        my $class = ref($proto) || $proto;
        my $self  = {
            lang => $lang,
            noProxy => $noProxy,
            updater => GCRealUpdater->new($lang, $baseDir, $toBeUpdated, $version)
        };
        bless ($self, $class);
        
        return $self;
    }
    
    sub update
    {
        my $self = shift;
        
        my $proxy;
        if (!$self->{noProxy})
        {
            # use proxy from options, don't ask
            #$proxy = <STDIN>;
            #chomp $proxy;
            
            # get environment variables and configuration file
            # copied from the main gcstar program to avoid modify it

            #XDG stuff
            my $home = $ENV{'HOME'};
            $home = $ENV{'APPDATA'} if ($^O =~ /win32/i);
            $home =~ s/\\/\//g if ($^O =~ /win32/i);
            
            $ENV{XDG_CONFIG_HOME} = $home.'/gcstar/config' if ($^O =~ /win32/i);
            $ENV{XDG_CONFIG_HOME} = $home.'/.config' if ! exists $ENV{XDG_CONFIG_HOME};
            
            $ENV{XDG_DATA_HOME} = $home.'/gcstar' if ($^O =~ /win32/i);
            $ENV{XDG_DATA_HOME} = $home.'/.local/share' if ! exists $ENV{XDG_DATA_HOME};
            
            $ENV{GCS_CONFIG_HOME} = $ENV{XDG_CONFIG_HOME}.'/gcstar';
            $ENV{GCS_CONFIG_HOME} = $ENV{XDG_CONFIG_HOME} if ($^O =~ /win32/i);
    
            $ENV{GCS_CONFIG_FILE} = $ENV{GCS_CONFIG_HOME}.'/GCstar.conf';
            
            use GCOptions;
            my $self->{options} = new GCOptionLoader($ENV{GCS_CONFIG_FILE}, 1);
            $proxy = $self->{options}->proxy if ($self->{options}->proxy !~ m/^#/);
        }
        
        $self->{updater}->createBrowser($proxy);
        
        my $count = $self->{updater}->total;
        print $self->{lang}->{UpdateNone},"\n" if !$count;
        for (my $i = 0; $i < $count; $i++)
        {
            print $i+1," / $count : ",$self->{updater}->getNextFile,"\n";
            $self->{updater}->updateNext;
        }
    }
}



1;
