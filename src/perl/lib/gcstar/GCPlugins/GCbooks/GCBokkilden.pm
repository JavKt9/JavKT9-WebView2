package GCPlugins::GCbooks::GCBokkilden;

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

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginBokkilden;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
	
        $self->{inside}->{$tagname}++;

        if ($self->{parsingEnded})
        {
            if ($self->{itemIdx} < 0)
            {
                $self->{itemIdx} = 0;
                $self->{itemsList}[0]->{url} = $self->{loadedUrl};
            }
            return;
        }

        if ($self->{parsingList})
        {
            if (($tagname eq 'article'))
            {
                $self->{isBook} = 1;
                $self->{itemIdx}++;
            }
            elsif ($self->{isBook})
            {
                if ($tagname eq 'a')
                {
                    $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
                    $self->{isTitle} = 1;
                }
                elsif ($tagname eq 'cite')
                {
                	$self->{isAuthor} = 1;
                }
            }
        }
        else
        {
            if ($tagname eq 'article' && $attr->{class} =~ m/(list-item-line|product)/)
            {
                $self->{isBook} = 1
            }
            return if (!$self->{isBook});
            if ($tagname eq 'img' && $attr->{itemprop} eq 'image')
            {
                $self->{curInfo}->{cover} = 'http://www.bokkilden.no/'
                                              . $attr->{src};
            }
            elsif (($tagname eq 'h1' && $attr->{class} eq 'title'))
            {
                $self->{isTitle} = 1;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'author' &&!$self->{curInfo}->{authors})
            {
                $self->{isTitle} = 0;
                $self->{isAuthor} = 2;
            }
            elsif ($attr->{class} eq 'text' && $attr->{itemprop} eq 'description')
            {
                $self->{isDescription} = 1;
            }
            elsif (($self->{isBook}) && $self->{inside}->{aside})
            {
                my $origtext = $attr->{itemprop};
                $self->{is} =
                     ($origtext eq 'datePublished')  ? 'publication'
                   : ($origtext eq 'publisher')      ? 'publisher'
                   : ($origtext eq 'Innb.: ')        ? 'format'
                   : ($origtext eq 'inLanguage')     ? 'language'
                   : ($origtext eq 'numberOfPages')  ? 'pages'
                   : ($origtext eq 'isbn')           ? 'isbn'
                   : ($origtext eq 'Utgave: ')       ? 'edition'
                   : ($origtext eq 'Genre:')         ? 'genre'
                   : $self->{is};
            }
            elsif ($self->{isDescription} eq 1)
            {
                $self->{curInfo}->{description} .= "\n" if ($tagname eq 'p');
                $self->{curInfo}->{description} .= "\n" if ($tagname eq 'br');
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;
        $self->{inside}->{$tagname}--;

        if ($tagname eq 'aside')
        {
            $self->{parsingEnded} = 1;
        }
        elsif ($self->{parsingList})
        {
	        if ($tagname eq 'h3')
	        {
	            $self->{isBook} = 0;
	        }
	        elsif ($tagname eq 'cite')
	        {
	        	$self->{isAuthor} = 0;
	        }
        }
        else
        {
	        if ($tagname eq 'div')
	        {
	            $self->{isTitle} = 0;
	            $self->{isDescription} = 0;
	        }
	        elsif ($tagname eq 'p')
	        {
	            $self->{isAuthor} = 0;
	        }
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        return if ($self->{parsingEnded});

        if ($self->{parsingList})
        {
            if ($self->{isTitle})
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $origtext;
                $self->{isTitle} = 0;
            }
            elsif ($self->{isAuthor})
            {
                return if ($origtext =~ m/^[\n ]*$/);
                $self->{itemsList}[$self->{itemIdx}]->{authors} .= ','
                    if $self->{itemsList}[$self->{itemIdx}]->{authors};
                $self->{itemsList}[$self->{itemIdx}]->{authors} .= $origtext;
                $self->{isAuthor} = 0;
            }
            elsif ($self->{isBook})
            {
                if ($origtext =~ / \| /)
                {
                    $origtext =~ /(\d{4})/;
                    $self->{itemsList}[$self->{itemIdx}]->{publication} = $1;
                    $self->{isBook} = 0;
                }
            }
        }
       	else
        {
             if ($self->{isTitle} eq 1)
             {
                  $self->{curInfo}->{title} .= " " if ($self->{curInfo}->{title});
                  $self->{curInfo}->{title} .= $origtext;
             }
             elsif ($self->{isAuthor} eq 2)
             {
                 return if ($origtext =~ m/^[; ]+$/);
                 return if ($origtext =~ /(m.fl.|\(Redakt.*)/);
                 return if ($origtext =~ /^\.+/);
                 # detect artist and translator after they were added to authors
                 if ($origtext =~ m/Illustrat/)
                 {
                     my $artist = $self->{curInfo}->{authors};
                     $artist =~ s/.*,//;
                     $self->{curInfo}->{artist} .= ',' if $self->{curInfo}->{artist};
                     $self->{curInfo}->{artist} .= $artist;
                     $self->{curInfo}->{authors} =~ s/,[^,]*$//;
                 }
                 elsif ($origtext =~ m/Oversetter/)
                 {
                     my $translator = $self->{curInfo}->{authors};
                     $translator =~ s/.*,//;
                     $self->{curInfo}->{translator} .= ',' if $self->{curInfo}->{translator};
                     $self->{curInfo}->{translator} .= $translator;
                     $self->{curInfo}->{authors} =~ s/,[^,]*$//;
                 }
                 else
                 {
                    $self->{curInfo}->{authors} .= ','
                        if ($self->{curInfo}->{authors} && !($origtext =~ m/\(.*\)/));
                    $origtext =~ s/; *//;
                    $self->{curInfo}->{authors} .= ' '.$origtext;
                 }
             }
             elsif ($self->{is})
             {
                 $origtext =~ s/^\s*//;
                 my $type = $self->{is};
                 $self->{is} = '';
                 if ($type eq 'genre')
                 {
                     $origtext =~ s/;\s*/,/g;
                 }
                 elsif ($type eq 'pages')
                 {
                     $origtext =~ s/[^0-9]//g;
                 }
                 elsif ($type eq 'serie')
                 {
                 	$self->{is} = 'volume';
                 }
                 elsif ($type eq 'volume')
                 {
                 	$origtext =~ s/.*\s//;
                 	$origtext = '' if (! ($origtext =~ m/^\d+$/));
                 }
                 $self->{curInfo}->{$type} = $origtext;
             }
             elsif ($self->{isDescription} eq 1)
             {
                 $self->{curInfo}->{description} .= $origtext." ";
             }
             elsif ($self->{inside}->{translator})
             {
                 $self->{curInfo}->{translator} .= ', '
                     if $self->{curInfo}->{translator};
                 $self->{curInfo}->{translator} .= $origtext;
             }
             elsif (($self->{isBook}) && $self->{inside}->{aside})
             {
                 $self->{is} =
                     ($origtext eq 'Utgitt: ') ? 'publication'
                   : ($origtext eq 'Forlag: ') ? 'publisher'
                   : ($origtext eq 'Innb.: ')  ? 'format'
                   : ($origtext =~ /Spr..?k:/) ? 'language'
                   : ($origtext eq 'Sider: ')  ? 'pages'
                   : ($origtext eq 'ISBN: ')   ? 'isbn'
                   : ($origtext eq 'Utgave: ') ? 'edition'
                   : ($origtext eq 'Genre:')   ? 'genre'
                   : ($origtext eq 'SERIE:')   ? 'serie'
                   : '';
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
            publication => 1,
            format => 0,
            edition => 0,
        };


        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{parsingEnded} = 0;
        $self->{isBook} = 0;
        if ($self->{parsingList})
        {
            $self->{isTitle} = 0;
            $self->{isAuthor} = 0;
        }
        else
        {
            $self->{is} = '';
            $self->{isCover} = 0;
            $html =~ s| *\n *||g;
            #$html =~ s|<a href="emneliste\.do\?emnekode=[.0-9]*">(.*?)</a>|$1|gim;
            #$html =~ s|<a href="sok\.do\?enkeltsok=[^"]*">([^<]*)</a>|<author>$1</author>|gim;
            #"
            #$html =~ s|<a href="sok\.do\?.*?rolle1=Oversetter">(.*?)</a>|<translator>$1</translator>|gim;
        }

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        return "https://www.bokkilden.no/enkeltSok.do?enkeltsok=".$word."&rom=MP";
        return "http://www.bokkilden.no/SamboWeb/sok.do?rom=MP&enkeltsok=$word&innsnevre=ja";
   }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return "http://www.bokkilden.no/$url"
            if $url !~ m|http://www.bokkilden.no/|;
        return $url;
    }

    sub getCharset
    {
        my $self = shift;

        return 'UTF-8';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }

    sub getName
    {
        return 'Bokkilden';
    }

    sub getLang
    {
        return 'NO';
    }

    sub getAuthor
    {
        return 'Tian';
    }

}

1;
