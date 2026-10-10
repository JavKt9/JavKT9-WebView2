package GCPlugins::GCbooks::GCLeyaOnline;

###################################################
#
#  Copyright 2005-2006 Tian
#  Copyrigth 2024 Kerenoc
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

use GCPlugins::GCbooks::GCbooksCommon;

{
    package GCPlugins::GCbooks::GCPluginLeyaOnline;

    use base 'GCPlugins::GCbooks::GCbooksPluginsBase';

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        if ($self->{parsingList})
        {

            if ($tagname eq 'div' && $attr->{id} && $attr->{id} =~ /bookcard_[0-9]/)
            {
                $self->{itemIdx}++;
                $self->{isBook} = 1 ;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ m;com/pt/(livros|escolar|ebook)/; && $self->{isBook})
            {
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
            }
            elsif ($tagname eq 'h6' && $attr->{class} && $attr->{class} =~ m|book-title| && $self->{isBook})
            {
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class} =~ m|book-author| && $self->{isBook})
            {
                $self->{isAuthor} = 1 ;
            }
        }
        else
        {
            if ($tagname eq 'div' && $attr->{class} && $attr->{class} eq 'h1')
            {
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'a' && $attr->{class} && $attr->{class} =~ m|nome_autor|)
            {
                $self->{isAuthor} = 1;
            }
            elsif ($self->{isISBN} eq 1)
            {
                $self->{isISBN} = 2 ;
            }
            elsif (($tagname eq 'span') && ($self->{isTitle}))
            {
                $self->{isTitle} = 2 ;
            }
            elsif ($tagname eq 'img' && $attr->{src} =~ m|fotos/produtos/|)
            {
                $self->{curInfo}->{cover} = $attr->{src} if ! $self->{curInfo}->{cover};
                $self->{curInfo}->{cover} =~ s|/100|/500|;
            }
            elsif ($tagname eq 'section' && $attr->{class} && $attr->{class} eq 'sinopse')
            {
                $self->{isDescription} = 1;
            }
            elsif ($tagname eq 'li')
            {
                $self->{isAnalyse} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{isAuthor} = 0 if $tagname eq 'div';
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//;

        return if ! $origtext;

        if ($self->{parsingList})
        {
            if ($self->{isTitle})
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAuthor} eq 1)
            {
                if (! $self->{itemsList}[$self->{itemIdx}]->{authors} && ($origtext ne ''))
                {
                   $self->{itemsList}[$self->{itemIdx}]->{authors} = $origtext;
                }
                elsif ($origtext ne '')
                {
                   $self->{itemsList}[$self->{itemIdx}]->{authors} .= ', ';
                   $self->{itemsList}[$self->{itemIdx}]->{authors} .= $origtext;
                }
                $self->{isAuthor} = 0 ;
            }
        }
           else
        {
            if ($self->{isTitle} eq '1')
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAuthor} eq 1)
            {
                if ($origtext ne '')
                {
                   $self->{curInfo}->{authors} .= $origtext if ($self->{curInfo}->{authors} !~ /$origtext/);
                   $self->{curInfo}->{authors} .= ",";
                }
                $self->{isAuthor} = 0 ;
            }
            elsif ($self->{isDescription} eq 1)
            {
                if ($origtext eq 'Ler mais')
                {
                    $self->{isDescription} = 2;
                }
                elsif ($origtext ne 'Sinopse')
                {
                    $self->{curInfo}->{description} .= $origtext;
                }
            }
            elsif ($self->{isAnalyse} && $self->{isDescription} eq 2)
            {
                $origtext =~ s/\n//g;
                $self->{curInfo}->{isbn} = $1 if ($origtext =~ m/ISBN *: *(.*)/);
                $self->{curInfo}->{format} = $1 if ($origtext =~ m/Dimens.*es *: *(.*)/);
                $self->{curInfo}->{publication} = $1 if ($origtext =~ m/Ano de Edi.*: *(.*)/);
                $self->{curInfo}->{publisher} = $1 if ($origtext =~ m/Editora *: *(.*)/);
                $self->{curInfo}->{pages} = $1 if ($origtext =~ m/P.*ginas *: *(.*)/);

                $self->{isAnalyse} = 0 ;
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
            edition => 1,
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{isBook} = 0;
        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isDescription} = 0;
        $self->{isISBN} = 0;

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        return "https://leyaonline.com/pt/pesquisa/pesquisar.php?texto=".$word;
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url if $url;
        return 'https://www.leyaonline.pt/';
    }

    sub getName
    {
        return "LeyaOnline";
    }

    sub getAuthor
    {
        return 'TPF - Kerenoc';
    }

    sub getCharset
    {
        return "CP1252";
    }

    sub getLang
    {
        return 'PT';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }

}

1;
