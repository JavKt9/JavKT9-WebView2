package GCPlugins::GCbooks::GCLeLivre;

###################################################
#
#  Copyright 2005-2006 Tian
#  Copyright 2016 Varkolak
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

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginLeLivre;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);
    use URI::Escape;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        
        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class} =~ m/row couleurLigne/)
            {
                $self->{isTitle} = 1;
            }
            elsif ($self->{isTitle} && $tagname eq 'a' && $attr->{href} =~ m|/livres/fiche|)
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = 'https://www.le-livre.fr'.$attr->{href};
                $self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                $self->{isTitle} = 0;
            }
        }
        else
        {
            if ($tagname eq 'img')
            {
                $self->{curInfo}->{cover} = $attr->{src}
                      if $attr->{src} =~ m/photos/ && !$self->{curInfo}->{cover};
                $self->{curInfo}->{cover} = $self->{curInfo}->{cover}.'https://www.le-livre.fr'
                      if ($self->{curInfo}->{cover} =~ /^\//);
            }
            elsif ($tagname eq 'h1')
            {
                $self->{isTitle} = 1;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'name' && $self->{isTitle} eq 1)
            {
                $self->{isTitle} = 2;
            }
            elsif ($tagname eq 'divers')
            {
                $self->{isFormat} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'description')
            { 
                $self->{isComm} = 1;
            }
            elsif ($self->{isComm} && $tagname eq 'div' && $attr->{itemprop} eq 'description')
            { 
                $self->{isComm} = 2;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        $self->{isComm} = 0 if ($tagname eq 'div' && $self->{isComm} eq 2);
        $self->{curInfo}->{description} .= "\n" if ($self->{isComm} && $tagname eq 'p');
        $self->{isTitle} = 1 if ($tagname eq 'span' && $self->{isTitle} eq 2);
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;

        return if ( $origtext eq '' );
        if ($self->{parsingList})
        {
            if ($origtext =~ m/Auteur *\(s\)/)
            {
                $self->{isAuthor} = 1;
            }
            elsif (($self->{isAuthor}) && ($origtext ne ''))
            {
                $self->{itemsList}[$self->{itemIdx}]->{authors} = $origtext;
                $self->{isAuthor} = 0 ;
            }
            elsif (($self->{isPublisher}) && ($origtext ne ''))
            {
                my @array = split(/\./,$origtext);
                $self->{itemsList}[$self->{itemIdx}]->{edition} = $array[0];
                $self->{itemsList}[$self->{itemIdx}]->{publication} = $array[1];
                $self->{itemsList}[$self->{itemIdx}]->{format} = $array[2];
                $self->{isPublisher} = 0 ;
            }
        }
        else
        {
            if ($self->{isTitle} eq 2)
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0;
            }
            elsif ($self->{isISBN})
            {
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0;
            }
            elsif ($self->{isComm} eq 2)
            {
                $self->{curInfo}->{description} .= $origtext;
                my @array = split(/[\.*]/,$origtext);
                for my $i (0 .. $#array)
                {
                   if ($array[$i] =~ s/.*[0-9]-//i)
                   {
                           #$array[$i] =~ s/.*-//i;
                        $array[$i] =~ s/^\s+//;
                        $self->{curInfo}->{genre} = $array[$i];
                   }
                }
            }
            elsif ($self->{isPublication})
            {
            	$self->{curInfo}->{publication} = $origtext;
            	$self->{isPublication} = 0;
            }
            elsif ($self->{isPublisher} eq 2  && !$self->{curInfo}->{publisher})
            {
                $origtext =~ s/IMP\. /IMP /g;
                my @array = split(/[\.]/,$origtext);
                $array[0] =~ s/([\w']+)/\u\L$1/g;
                $self->{curInfo}->{publisher} = $array[0];
                $array[1] =~ s/^\s+//;
                $self->{curInfo}->{publication} = $array[1];
                $array[2] =~ s/^\s+//;
                $self->{curInfo}->{format} = $array[2];
                for my $i (3 .. $#array)
                {
                   if ($array[$i] =~ /pages/i)
                   {
                        $array[$i] =~ s/ pages.*//i;
                        $array[$i] =~ s/^\s+//;
                        $self->{curInfo}->{pages} = $array[$i];
                   }
                }
            } 
            elsif ($self->{isAuthor})
            {
                my @array = split(/-/,$origtext);
                $array[0] =~ s/([\w']+)/\u\L$1/g;
                $self->{curInfo}->{authors} = $array[0];
                for my $i (1 .. $#array)
                {
                   $array[$i] =~ s/([\w']+)/\u\L$1/g;
                   $self->{curInfo}->{authors} .= ", " . $array[$i];
                }
                $self->{isAuthor} = 0 ;
            }
            elsif ($origtext eq 'Auteur')
            {
                $self->{isAuthor} = 1;
            }
            elsif ($origtext eq 'Impression')
            {
                $self->{isPublication} = 1;
            }
            elsif ($origtext eq 'Editeur')
            {
                $self->{isPublisher} = 2;
            }
            elsif ($origtext eq 'ISBN 10')
            {
                $self->{isISBN} = 1;
            }
        }
    } 

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            title => 1,
            authors => 1,
            publication => 0,
            format => 0,
            edition => 0,
            serie => 0,
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        if ($self->{parsingList})
        {
        }
        else
        {
            $html =~ s|\x{92}|'|g;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
        }
        
        $self->{isImage} = 0;
        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isPublisher} = 0;
        $self->{isPublication} = 0;
        $self->{isISBN} = 0;
        $self->{isFormat} = 0;
        $self->{isTranslator} = 0;
        $self->{isComm} = 0;

        return $html;
    }
    
    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return "https://www.le-livre.fr/recherche-avancee.html?select_titre=".$word;
        return "https://www.le-livre.fr/recherche-rapide.html?select_base=0&RechercheRap=".$word."&Submit_Rech_Rapide=+";
        return "http://www.le-livre.fr/default.asp?Rech=1&Submit_Rech_Rapide=1&rechercherap=". $word;
    }
    
    sub getItemUrl
    {
        my ($self, $url) = @_;
                
        return $url;
    }

    sub getName
    {
        return "Le-Livre";
    }
    
    sub getCharset
    {
        my $self = shift;
        return "ISO-8859-15";
    }

    sub getAuthor
    {
        return 'Varkolak';
    }
    
    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        return ['ISBN', 'title', 'authors', 'publication'];
    }
}

1;
