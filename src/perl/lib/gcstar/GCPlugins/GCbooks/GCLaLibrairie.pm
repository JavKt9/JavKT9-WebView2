package GCPlugins::GCbooks::GCLaLibrairie;
###################################################
#
#  Copyright 2005-2006 Tian
#  Copyright 2015-2026 Kerenoc
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
    package GCPlugins::GCbooks::GCPluginLaLibrairie;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        return if $self->{ending};

        if ($self->{parsingList})
        {
            if ($tagname eq 'h1' && $attr->{class} eq '')
            {
                $self->{ending} = 1; # empty search result
            }
            elsif ($tagname eq 'h5' && $attr->{class} =~ m/card-title/)
            {
                $self->{isTitle} = 1;
            }
            elsif ($self->{isTitle} eq 1 && $tagname eq 'a' && $attr->{title} ne '')
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = "https://www.lalibrairie.com" . $attr->{href};
                $self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title};
                $self->{isTitle} = 0;
            }
        }
        else
        {
            if ($tagname eq 'h1' && $attr->{class} eq 'titre')
            {
                $self->{isTitle} = 1 ;
            }
            elsif ($tagname eq 'h2' && $attr->{class} eq 'auteur')
            {
                $self->{isAuthor} = 1 ;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/livres\/auteurs\// && $self->{isAuthor})
            {
                $self->{isAuthor} = 2 ;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/livres\/collections\// && ! $self->{curInfo}->{collection})
            {
                $self->{isCollection} = 1;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/livres\/editeurs\// && ! $self->{curInfo}->{publisher})
            {
                $self->{isPublisher} = 1;
            }
            elsif ($tagname eq 'a' && $attr->{href} =~ /\/livres\/series\// && ! $self->{curInfo}->{serie})
            {
                $self->{isSerie} = 1;
            }
            elsif ($tagname eq 'section' && $attr->{id} eq 'quatreCouv')
            {
                $self->{isDescription} = 2 ;
            }
            elsif (($tagname eq 'a') && ( $attr->{itemprop} eq 'translator'))
            {
                $self->{isTranslator} = 1 ;
            }
            elsif ($tagname eq 'img' && $attr->{class} eq 'couverture')
            {
                $self->{curInfo}->{cover} = "https://lalibrairie.com".$attr->{src};
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'isbn')
            {
                $self->{isISBN} = 1 ;
            }
            elsif ($tagname eq 'span' && $attr->{itemprop} eq 'datePublished')
            {
                $self->{isPublication} = 1 ;
            }
            elsif ($tagname eq 'h5' && $attr->{id} =~ /infosTechniques/)
            {
                $self->{isAnalyse} = 1 ;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{isDescription} = 0 if ($tagname eq 'section');
        $self->{isAuthor} = 0 if ($tagname eq 'h2');
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;
        return if ! $origtext;

        if ($self->{parsingList})
        {
            if ($self->{isAuthor})
            {
                if ($origtext =~ m/Les outils de recherche/i)
                {
                    # the search failed
                    $self->{isAuthor} = 0;
                    return;
                }
                my $prefix = $self->{itemsList}[$self->{itemIdx}]->{authors} ? ", " : "";
                $self->{itemsList}[$self->{itemIdx}]->{authors} .= $prefix.$origtext;
                $self->{isAuthor} = 0 ;
            }
        }
        else
        {
            if ($self->{isTitle})
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAuthor} eq 2)
            {
                $origtext = ", ".$origtext if $self->{curInfo}->{authors};
                $self->{curInfo}->{authors} .= $origtext;
                $self->{isAuthor} = 1;
            }
            elsif ($self->{isTranslator})
            {
                $self->{curInfo}->{translator} = $origtext;
                $self->{isTranslator} = 0 ;
            }
            elsif ($self->{isPublisher})
            {
                $self->{curInfo}->{publisher} = $origtext;
                $self->{isPublisher} = 0 ;
            }
            elsif ($self->{isDescription})
            {
                $self->{curInfo}->{description} .= " ".$origtext;
            }
            elsif ($self->{isPublication})
            {
                $self->{curInfo}->{publication} = $origtext;
                $self->{isPublication} = 0;
            }
            elsif ($origtext =~ /(\d+) pages/)
            {
                $self->{curInfo}->{pages} = $1;
            }
            elsif ($self->{isSerie})
            {
                $self->{curInfo}->{serie} = $origtext;
                $self->{isSerie} = 0 ;
            }
            elsif ($self->{isCollection})
            {
                $self->{curInfo}->{edition} = $origtext;
                $self->{isCollection} = 0 ;
            }
            elsif ($self->{isISBN})
            {
                $origtext =~ s/-//g;
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }
            elsif ($self->{isAnalyse})
            {
                if ($origtext =~ m/Traduction : (.*)/s)
                {
                    my $text = $1;
                    $text =~ s/\n/ /sg;
                    $text =~ s/  */ /g;
                    my $prefix = $self->{curInfo}->{translator} ? ", " : "";
                    $self->{curInfo}->{translator} .= $prefix.$text;
                }
                elsif ($origtext =~ m/Dimensions : (.*)/s)
                {
                    my $text = $1;
                    $text =~ s/\n/ /sg;
                    $text =~ s/  */ /g;
                    $self->{curInfo}->{format} = $text;
                }
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
            edition => 1,
            serie => 1,
            isbn => 1,
            pages => 1,
            publisher => 1,
        };

        $self->{isTitle} = 0;
        $self->{isAuthor} = 0;
        $self->{isPublisher} = 0;
        $self->{isPublication} = 0;
        $self->{isAnalyse} = 0;
        $self->{isDescription} = 0;
        $self->{isISBN} = 0;
        $self->{isCollection} = 0;
        $self->{isCover} = 0;

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{ending} = 0;
        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        use URI::Escape;
        $word = uri_unescape($word);
        my $token;
        my $html = $self->loadPage("https://www.lalibrairie.com", undef, 1);
        if ($html =~ /"token" value="([^"]+)"/)
        {
            $token = $1;
        }
        return ('https://www.lalibrairie.com/livres/recherche.html', ["searchLang" => "fra", "rapid-search" => "$word", "token" => $token] );
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;
        return $url;
    }

    sub getName
    {
        return "LaLibrairie (FR)";
    }

    sub getCharset
    {
        return "UTF-8";
    }

    sub getAuthor
    {
        return 'TPF - Kerenoc';
    }

    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        return ['isbn', 'title'];
    }
}

1;
