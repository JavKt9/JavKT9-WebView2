package GCImport::GCImportDataCrow;

###################################################
#
#  Copyright 2018 Kerenoc
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
    package GCImport::GCImporterDataCrow;

    use base qw(GCImport::GCImportBaseClass);

    use File::Basename;
    use File::Copy;
    use XML::Simple;

    use GCUtils 'localName';
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);
        return $self;
    }

    sub getName
    {
        return "DataCrow (.xml)";
    }

    sub getFilePatterns
    {
       return (['DataCrow (.xml)', '*.xml']);
    }

    sub getModelName
    {
        my $self = shift;
        return $self->{model}->getName;
    }

    sub getOptions
    {
        return [];
    }

    sub getEndInfo
    {
        return "";
    }

    sub getItemsArray
    {
        my ($self, $file) = @_;

        my $parent = $self->{options}->{parent};
        $self->{modelsFactory} = $parent->{modelsFactory};
        $self->{modelAlreadySet} = 0;

        my $xml = XML::Simple->new;
        my $data = $xml->XMLin (
            localName($file),
            forceArray => ['book','authors', 'publishers'],
            KeyAttr    => ['']
        );

        my @result;
        my $book;
        
        my($filename, $dirs, $suffix) = fileparse($file);
        $filename =~ s/.xml//;

        foreach $book(@{$data->{book}}){
                my $item;

                $item->{title} = $book->{title};
                $item->{date} = $book->{created};
                $item->{publication} = $book->{year};
                $item->{description} = $book->{description};
                $item->{webpage} = $book->{webpage};
                $item->{pages} = $book->{pages};
                $item->{isbn} = $book->{'isbn-13'};
                $item->{genre} = $book->{category};
                $item->{authors} = $book->{'authors-list'};
                $item->{publisher} = $book->{'publishers-list'};
                $item->{cover} = $book->{'picture-front'};
                # get cover pictures
                my $pictureName = $book->{'picture-front'};
                $pictureName =~ s/.*$filename/$filename/;
                $pictureName =~ s/\\/\// if ($^O =~ /win32/i);
                if (-e localName($pictureName))
                {
                    my $pic = $self->{options}->{parent}->getUniqueImageFileName('jpg', $book->{title});
                    copy localName($pictureName), localName($pic);
                    $item->{cover} = $pic;
                }

                push @result, $item;
        }
        return \@result;
    }
}

1;
