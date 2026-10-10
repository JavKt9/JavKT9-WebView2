package GCImport::GCImportAlexandria;

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
use utf8;
use GCImport::GCImportBase;

{
    package GCImport::GCImporterAlexandria;

    use base qw(GCImport::GCImportBaseClass);
    use File::Copy;
    use Encode;
    use GCUtils qw(glob localName);
 
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);
        $self->{errors} = '';

        return $self;
    }

    sub getName
    {
        return "Alexandria";
    }
    
    sub getOptions
    {
        my $self = shift;
        return [
            {
                name => 'where',
                type => 'options',
                label => 'Where',
                default => 'Default',
                valuesList => 'Default,Specified'
            }
        ];
    }
    
    sub getFilePatterns
    {
        my $self = shift;
    
        return ();
    }
    
    #Return supported models name
    sub getModels
    {
        return ['GCbooks'];
    }

    sub getModelName
    {
        my $self = shift;
        
        return 'GCbooks';
    }
    
    sub wantsFieldsSelection
    {
        return 0;
    }
    
    sub wantsFileSelection
    {
        return 0;
    }
    
    sub wantsDirectorySelection
    {
        return 1;
    }
    
    sub getEndInfo
    {
        my $self = shift;
    
        return '';
    }
    
    sub getItemsArray
    {
        my ($self, $directory) = @_;

        my @result = ();

        my @files;
        $directory = $ENV{HOME}.'/.alexandria'
            if $self->{options}->{where} eq 'Default';

        foreach (glob "$directory/*")
        {
            if (-d $_)
            {
                my @array = glob "$_/*";
                foreach my $file(glob "$_/*")
                {
                    push @files, $file if $file =~ /yaml$/;
                }
            }
            push @files, $_ if /yaml$/;
        }

        foreach (@files)
        {
            push @result, $self->getBook($_);
        }

        return \@result;
    }
    
    sub transformValue
    {
        my ($self, $value) = @_;
        
        $value =~ s/^"(.*)"$/$1/;
        $value =~ s/\\x([0-9a-fA-F]{2})/pack("H2",$1)/ge;
        # $value = decode('UTF-8', $value);
                
        return $value;
    }
    
    sub getBook
    {
        my ($self, $file) = @_;
        
        my %book;
        open BOOK, "<".localName($file);
        binmode(BOOK, ':utf8');
        # 1st line contain ruby information
        my $line = <BOOK>;
        my $current = '';
        my $value = '';
        foreach (<BOOK>)
        {
            next if /^#/;
            if (/^([a-z_]*):\s*(.*)$/)
            {
                $current = $1;
                next if $current eq 'saved_ident';
                # Tag conversion
                $current = 'lendDate' if $current eq 'loaned_since';
                $current = 'borrower' if $current eq 'loaned_to';
                $current = 'comments' if $current eq 'notes';
                $current = 'publication' if $current eq 'publishing_year';
                $current = 'read' if $current eq 'redd';
                $book{$current} = $self->transformValue($2) if ($2);
            }
            elsif (/^\s*- (.*)$/)
            {
                $book{$current} ||= [];
                push @{$book{$current}}, [$self->transformValue($1)];
            }
        }
        close BOOK;
        #Some adjustments
        $book{rating} *= 2;
        $book{lendDate} =~ s|^([0-9]{4})-([0-9]{2})-([0-9]{2}).*$|$3/$2/$1|;
        if ($book{loaned} eq 'false')
        {
            $book{borrower} = 'none';
            $book{lendDate} = '';
        }
        delete $book{loaned};
        $book{genre} = $book{tags} if $book{tags};
        $book{read} = 1 if $book{read} eq 'true';
        $book{read} = 0 if $book{read} eq 'false';
        delete $book{comments} if $book{comments} eq "''" or $book{comments} eq '"';
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
        my $currentDate = sprintf('%02d/%02d/%4d', $mday, $mon+1, 1900+$year);
        $book{added} = $currentDate;
        $book{acquisition} = $currentDate if $book{own} eq 'true';

        #cover
        $file =~ s/yaml$/cover/;
        if (-e localName($file))
        {
            my $pic = $self->{options}->{parent}->getUniqueImageFileName('jpg', $book{title});
            copy localName($file), localName($pic);
            $book{cover} = $pic;
        }
        return \%book;
    }
	
}




1;