package GCPlugins::GCbooks::GCFnacCommon;

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
    package GCPlugins::GCbooks::GCPluginFnacCommon;

    use base qw(GCPlugins::GCbooks::GCbooksPluginsBase);

    use URI::Escape;

    use GCUtils;

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $attr->{class} eq "Article-itemInfo")
            {
                $self->{isTitle} = 1;
            }
            elsif ($self->{isTitle} eq 1 && $tagname eq 'a' && $attr->{class} =~ "Article-title")
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href};
                $self->{isTitle} = 2;
            }
            elsif ($tagname eq 'p' && $attr->{class} eq "Article-descSub")
            {
                $self->{is_authors} = 1;
                $self->{author} = "";
            }
            elsif ($self->{is_authors} eq 1 && $tagname eq 'a')
            {
                $self->{is_authors} = 2;
            }
            elsif ($self->{is_authors} && $tagname eq 'span')
            {
                $self->{is_authors} = 0;
            }
            elsif ($tagname eq 'li' && $attr->{class} && $attr->{class} eq "moreInfos-item")
            {
                $self->{isAnalyse} = 1;
            }
        }
        else
        {
            if ($attr->{class} && $attr->{class} =~ m/productHeader-Title/)
            {
                $self->{isTitle} = 1 ;
            }
            elsif (($tagname eq 'h1') && ($attr->{class} =~ /productHeader/))
            {
                $self->{isTitle} = 1 ;
            }
            elsif (($self->{is_authors} eq 1) && ($tagname eq 'a'))
            {
                $self->{is_authors} = 2 ;
            }
            elsif (($tagname eq 'img') && $attr->{class} && ($attr->{class} =~ m/viewItem--main/i))
            {
                $self->{curInfo}->{cover} = $attr->{src} ;
            }
            elsif ($tagname eq 'div' && $attr->{class} && $attr->{class} =~ /productDesc__body/)
            {
                $self->{isDescription} = 1 ;
            }
            elsif (($tagname eq 'div') && $attr->{class} && ($attr->{class} =~ m/f-productProperties/))
            {
                $self->{isDescription} = 0;
            }
            elsif (($tagname eq 'dt') && $attr->{class} && ($attr->{class} =~ m/Properties__term/))
            {
                $self->{isAnalyse} = 1 ;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        if (! $self->{parsingList})
        {
            if ($tagname eq 'div')
            {
                $self->{isAnalyse} = 0;
                $self->{is_authors} = 0;
            }
            elsif ($tagname eq 'dl')
            {
                $self->{is_authors} = 0;
            }
        }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        # Enleve les blancs en debut et fin de chaine
        $origtext =~ s/^\s+//;
        $origtext =~ s/\s+$//g;
        return if ! $origtext;

        if ($self->{parsingList})
        {
            if ($self->{isTitle} eq 2)
            {
                $origtext = '-'.$origtext if ($self->{itemsList}[$self->{itemIdx}]->{title} ne '');
                $self->{itemsList}[$self->{itemIdx}]->{title} .= $origtext if ($origtext ne '-' && $origtext ne '');
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAnalyse})
            {
                if ($self->{isAnalyse} eq 1)
                {
                    $self->{isAnalyse} = 'publication' if $origtext eq "Parution";
                    $self->{isAnalyse} = 'publisher' if $origtext eq "Editeur";
                }
                else
                {
                    $self->{itemsList}[$self->{itemIdx}]->{$self->{isAnalyse}} = $origtext;
                    $self->{isAnalyse} = 0;
                }
            }
            elsif ($self->{is_authors})
            {
                if ($origtext =~ /\(Auteur\)/)
                {
                    $self->{itemsList}[$self->{itemIdx}]->{authors} .= $self->{author};
                    $self->{author} = "";
                }
                elsif ($origtext =~ /\(.*\)/)
                {
                    $self->{author} = "";
                    $self->{is_authors} = 0;
                }
                else
                {
                    $self->{author} = ', ' if ($self->{itemsList}[$self->{itemIdx}]->{authors});
                    $self->{author} .= $origtext;
                }
            }
        }
        else
        {
            if ($self->{isTitle})
            {
                if ($origtext =~ /(.*) - Tome (\d+) : (.*)/)
                {
                    $self->{curInfo}->{serie} = $1;
                    $self->{curInfo}->{volume} = $2;
                    $self->{curInfo}->{title} = $3;
                    $self->{curInfo}->{title} =~ s/ - n°\d+//;
                }
                else
                {
                    $self->{curInfo}->{title} = $origtext;
                }
                $self->{isTitle} = 0 ;
            }
            elsif ($self->{isAnalyse})
            {
                $self->{isISBN} = 1 if ($origtext =~ m/ISBN/);
                $self->{isEAN} = 1 if ($origtext =~ m/EAN/);
                while ( my ($field, $pattern) = each %{$self->{translations}} )
                {
                    $self->{"is_$field"} = 1 if ($origtext =~ m/$pattern/i)
                };
                $self->{isAnalyse} = 0 ;
            }
            elsif ($self->{is_authors})
            {
                $origtext = ', '.$origtext if ($self->{curInfo}->{authors});
                $self->{curInfo}->{authors} .= $origtext;
            }
            elsif ($self->{is_translator})
            {
                $self->{curInfo}->{translator} = $origtext;
                $self->{is_translator} = 0;
            }
            elsif ($self->{is_artist})
            {
                $self->{curInfo}->{artist} = $origtext if ! ($origtext =~ m/illustration/i);
                $self->{is_artist} = 0;
            }
            elsif ($self->{isISBN} && !$self->{curInfo}->{isbn})
            {
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isISBN} = 0 ;
            }
            elsif ($self->{isEAN})
            {
                $self->{curInfo}->{isbn} = $origtext;
                $self->{isEAN} = 0 ;
            }
            elsif ($self->{is_publisher})
            {
                $self->{curInfo}->{publisher} = $origtext;
                $self->{is_publisher} = 0 ;
            }
            elsif ($self->{is_format})
            {
                $self->{curInfo}->{format} = $origtext;
                $self->{is_format} = 0 ;
            }
            elsif ($self->{is_serie})
            {
                if ($origtext =~ m/(.*),.* ([0-9]+) *$/)
                {
                    $self->{curInfo}->{edition} = $1;
                    $self->{curInfo}->{rank} = $2;
                }
                else
                {
                    $self->{curInfo}->{edition} = $origtext;
                }
                $self->{is_serie} = 0 ;
            }
            elsif ($self->{is_publication})
            {
                $self->{curInfo}->{publication} = $self->decodeDate($origtext)
                    if (!$self->{curInfo}->{publication});
                $self->{is_publication} = 0 ;
            }
            elsif (($self->{is_page}))
            {
                $self->{curInfo}->{pages} = $origtext;
                $self->{is_page} = 0 ;
            }
            elsif ($self->{isDescription})
            {
                $origtext =~ s/\r\n/ /g;
                $self->{curInfo}->{description} .= $origtext."\n" if ($origtext ne '');
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
            publisher => 1,
        };

        $self->initTranslations();

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{isTitle} = 0;
        $self->{isISBN} = 0;
        $self->{isEAN} = 0;
        $self->{isDescription} = 0;
        while ( my ($field, $pattern) = each %{$self->{translations}} ) {
            $self->{"is_$field"} = 0;
        };

        return $html;
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $word =~ s/%E[89AB]/e/g ;
        $word =~ s/%E[024]/a/g ;
        $word =~ s/%E[EF]/i/g ;
        $word =~ s/%F[9B]/u/g ;
        $word =~ s/%F[46]/o/g ;
        $word =~ s/%E7/c/g ;

        $self->loadPage($self->{rootURL});

        return $self->{rootURL}."/SearchResult/ResultList.aspx?SCat=$self->{categorie}!1&SDM=list&Search=$word&sft=1";
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url if $url;
        return $self->{rootURL};
    }

    sub getCharset
    {
        return "UTF-8";
    }

    sub getAuthor
    {
        return 'TPF - Kerenoc';
    }

    sub getSearchFieldsArray
    {
        return ['title', 'isbn', 'authors'];
    }

    sub decodeDate
    {
        my ($self, $date) = @_;

        # date déjà dans le bon format
        return $date if ($date =~ m|/.*/|);

        my $date1 = GCDates::strToTime($date,"%e %B %Y",$self->getLang);
        return $date1 if $date1 =~ /\//;
        $date = GCDates::strToTime($date,"%B %Y",$self->getLang);
        return $date;
    }
}

1;
