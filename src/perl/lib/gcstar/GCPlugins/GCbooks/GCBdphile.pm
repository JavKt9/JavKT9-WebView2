package GCPlugins::GCbooks::GCBdphile;

###################################################
#
#  Copyright 2005-2007 Jonas
#  Copyright 2016-2019 Kerenoc
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
    # Replace SiteTemplate with your exporter name
    # It must be the same name as the one used for file and main package name
    package GCPlugins::GCbooks::GCPluginBdphile;

    use base 'GCPlugins::GCbooks::GCbooksPluginsBase';
    
    use URI::Escape;

    use GCUtils;

    # getSearchUrl
    # Used to get the URL that to be used to perform searches.
    # $word is the query
    # Returns the full URL.
    sub getSearchUrl
    {
        my ($self, $word) = @_;

        $word = uri_unescape($word);
        $word = uri_escape_utf8($word);
        $word =~ s/%2B/+/g;

        $self->{searchWord} = $word;
        
        if ($self->{searchField} eq $self->{seriesField})
        {
            return 'https://www.bdphile.info/search/series/?q='.$word
        }
        elsif ($self->{searchField} eq 'title' || $self->{searchField} eq 'isbn')
        {
            return 'https://www.bdphile.info/search/album/?q='.$word;
        }
        else
        {
            return 'https://www.bdphile.info/search/author/?q='.$word;
        }
    }

    # getItemUrl
    # Used to get the full URL of an item page.
    # Useful when url on results pages are relative.
    # $url is the URL as found with a search.
    # Returns the absolute URL.
    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url;
    }

    # getCharset
    # Used to convert charset in web pages.
    # Returns the charset as specified in pages.
    sub getCharset
    {
        my $self = shift;

        return "ISO-8859-1";
    }

    # getName
    # Used to display plugin name in GUI.
    # Returns the plugin name.
    sub getName
    {
        return "Bdphile";
    }

    # getAuthor
    # Used to display the plugin author in GUI.
    # Returns the plugin author name.
    sub getAuthor
    {
        return 'Jonas - Kerenoc';
    }

    # getLang
    # Used to fill in plugin list with user language plugins
    # Return the language used for this site (2 letters code).
    sub getLang
    {
        return 'FR';
    }

    sub getSearchFieldsArray
    {
        my $self = shift;

        return ['title', $self->{seriesField}, $self->{authorField}, 'isbn', ];
    }

    # getNumberPasses
    # Used to set the number of search "passes" the plugin requires. This defaults to
    # a single pass, but for some sites 2 or more searches are required. See the GCTvdb
    # plugin for an example of such a site
    sub getNumberPasses
    {
        my $self = shift;

        # two pass to choose a serie then an album
        return 2 if ($self->{searchField} eq $self->{seriesField});
        # one pass when searching an album
        # unless they are too many results and another pass is needed to select a serie
        return $self->{pass} if ($self->{searchField} eq 'title' && $self->{lastPass});
        # three pass to choose writer then serie then album
        return 3 if ($self->{searchField} eq $self->{authorField});
        return 2;
    }

    sub getReturnedFields
    {
        my $self = shift;

        if ($self->{pass} == 1 && $self->{searchField} eq $self->{seriesField})
        {
            $self->{hasField} = {
            	$self->{seriesField} => 1,
            };
        }
        elsif ($self->{pass} == 1 && $self->{searchField} eq $self->{authorField})
        {
            $self->{hasField} = {
                $self->{authorField} => 1,
            };
        }
        else
        {
            $self->{hasField} = {
                $self->{seriesField} => 1,
                title  => 1,
                volume => 1,
            };
        }
    }

    # changeUrl
    # Can be used to change URL if item URL and the one used to
    # extract information are different.
    # Return the modified URL.
    sub changeUrl
    {
        my ($self, $url) = @_;

        return $url;
    }

    # In processing functions below, self->{parsingList} can be used.
    # If true, we are processing a search results page
    # If false, we are processing a item information page.

    # $self->{inside}->{tagname} (with correct value for tagname) can be used to test
    # if we are in the corresponding tag.

    # You have a counter $self->{itemIdx} that have to be used when processing search results.
    # It is your responsability to increment it!

    # When processing search results, you have to fill the available fields for results
    #
    #  $self->{itemsList}[$self->{movieIdx}]->{field_name}
    #
    # When processing a movie page, you need to fill the fields (if available)
    # in $self->{curInfo}.
    #
    #  $self->{curInfo}->{field_name}

    sub addSearchItem
    {
    	my ($self, $attr) = @_;
    	
        $self->{itemIdx}++ ;
        $self->{isPublication} = 0 ;
        $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href} ;
        $self->{itemsList}[$self->{itemIdx}]->{nextUrl} = $attr->{href} ;
        $self->{itemsList}[$self->{itemIdx}]->{$self->{seriesField}} = $self->{serie};
        #$self->{itemsList}[$self->{itemIdx}]->{cover} = "https://www.bdphile.info/static/images/media/cover/".substr($self->{itemsList}[$self->{itemIdx}]->{url},36,-1).".jpg" ;
        if ($attr->{title})
        {
            if ($attr->{title} =~ /^(\d+|INT|COF)\. (.*)/)
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $2;
                $self->{itemsList}[$self->{itemIdx}]->{volume} = $1;
            }
            else
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{title} ;
            }
        }
        else
        {
        	 $self->{isTitle} = 1 ;
        }
    }
    
    # start
    # Called each time a new HTML tag begins.
    # $tagname is the tag name.
    # $attr is reference to an associative array of tag attributes.
    # $attrseq is an array reference containing all the attributes name.
    # $origtext is the tag text as found in source file
    # Returns nothing
    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;

        if ($self->{parsingList})
        {
            # Your code for processing search results here
            if ($self->{loadedUrl} =~ m|/album/| && ! ($self->{loadedUrl} =~ m|info/search|))
            {
                # album : end of search
                $self->{itemIdx} = 0;
                $self->{itemsList}[0]->{url} = $self->{loadedUrl};
                return;
            }
            return if ($self->{stopSearch});

            if ($tagname eq 'a')
            {
            	return if $self->existsUrl($attr->{href});
            	
	            if (    ($self->{pass} eq 1 && ( $attr->{href} =~ m|info/series/view| || $attr->{href} =~ m|info/author/view| ))
	                 || $attr->{href} =~ m;info/series/(bd|manga); 
	                 || $attr->{href} =~ m;info/album/(view|bd|manga)/; )
	            {
	            	$self->addSearchItem($attr);
	            	$self->{lastPass} = 0 if (! ($attr->{href} =~ m;info/album;)); 
	            }
            }
            elsif ($tagname eq 'h1')
            {
            	$self->{isSerie} = 1;
            }
            elsif ($tagname eq 'img' && $self->{isTitle})
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $attr->{alt};
                $self->{isTitle} = 0;
            }
            elsif ($tagname eq 'h2' && $attr->{class} eq 'menu-series-item')
            {
            	$self->{stopSearch} = 1;
            }
        }
        else
        {
            if (($tagname eq 'div') && ($attr->{id} eq "reeditions"))
            {
                $self->{isReeditions} = 1;
            }
            elsif ($self->{isReeditions} == 0)
            {
                if ($tagname eq 'h1')
                {
                    $self->{isSerie} = 1 ;
                }
                elsif ($tagname eq 'h2')
                {
                    $self->{isTitle} = 1 ;
                }
                elsif (    $tagname eq 'div' && $attr->{id} eq 'album' 
                        && $self->{curInfo}->{title} ne $self->{newTitle}
                        && $self->{curInfo}->{$self->{seriesField}} )
                {
                    $self->{curInfo}->{title} = $self->{curInfo}->{$self->{seriesField}};
                }
                elsif ($tagname eq 'dt')
                {
                    $self->{isFieldName} = 1;
                    $self->{fieldName} = "" ;
                }
                elsif ($tagname eq 'dd')
                {
                    $self->{isFieldValue} = 1;
                }
                elsif (($tagname eq 'div') && ($attr->{id} eq "book-description"))
                {
                    $self->{isDescription} = 1;
                }
                elsif (($tagname eq 'div') && ($attr->{id} eq "book-picture"))
                {
                    $self->{isCover} = 1;
                }
                elsif ($self->{isCover} && ($tagname eq 'a'))
                {
                    $self->{curInfo}->{$self->{coverField}} = $attr->{href};
                    $self->{isCover} = 0 ;
                    $self->{isBackpic} = 1 ;
                }
                elsif ($self->{isBackpic} && ($tagname eq 'a') && ($attr->{href} =~ m/image/))
                {
                    $self->{curInfo}->{backpic} = "https://www.bdphile.info/static/".$attr->{href}
                        if (! ($attr->{href} =~ m/http/));
                    $self->{isBackpic} = 0 ;
                }
            }
        }
    }

    # end
    # Called each time a HTML tag ends.
    # $tagname is the tag name.
    sub end
    {
        my ($self, $tagname) = @_;
        $self->{inside}->{$tagname}--;

        if ($self->{parsingList})
        {
            # Your code for processing search results here
            if (($self->{isTitle}) && ($tagname eq 'a'))
            {
                $self->{isTitle} = 0 ;
                $self->{isPublication} = 1 ;
            }
        }
        else
        {
            if ($self->{isReeditions} == 0)
            {
                if ($tagname eq 'h1' || $tagname eq 'a')
                {
                    $self->{isSerie} = 0
                }
                elsif ($tagname eq 'h2')
                {
                    $self->{isTitle} = 0
                }
                elsif ($tagname eq 'dt')
                {
                    $self->{isFieldName} = 0
                }
                elsif ($tagname eq 'dd')
                {
                    if ($self->{author} ne "")
                    {
                        if ($self->{searchType} eq 'books')
                        {
                            if (! (grep /$self->{author}/, @{$self->{curInfo}{authors}}))
                            {
                                push @{$self->{curInfo}{authors}}, [$self->{author}];
                            }
                        }
                        else
                        {
                            $self->{curInfo}->{writer} .= ', ' if $self->{curInfo}->{writer};
                            $self->{curInfo}->{writer} .= $self->{author};
                        }
                        $self->{author} = "";
                    }
                    $self->{isFieldValue} = 0
                }
                elsif ($tagname eq 'div')
                {
                    $self->{isDescription} = 0;
                }
            }
        }
    }

    # text
    # Called each time some plain text (between tags) is processed.
    # $origtext is the read text.
    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/^[\s\n]+//;
        return if $origtext eq '';
 
        if ($self->{parsingList})
        {
            # Your code for processing search results here
            if ($self->{isTitle})
            {
                if ($origtext =~ /(.*)\s(\d+)\.\s(.*)/)
                {
                    $self->{itemsList}[$self->{itemIdx}]->{title} = $3;
                    $self->{itemsList}[$self->{itemIdx}]->{$self->{seriesField}} = $1;
                    $self->{itemsList}[$self->{itemIdx}]->{volume} = $2;
                }
                elsif ($origtext =~ /(.*)\s\((.*)\)\s(.*)/)
                {
                    $self->{itemsList}[$self->{itemIdx}]->{$self->{seriesField}} = $1 ;
                    $self->{itemsList}[$self->{itemIdx}]->{extra} = $2 ;
                    $self->{itemsList}[$self->{itemIdx}]->{title} = $3 ;
                }
                else
                {
                	$self->{itemsList}[$self->{itemIdx}]->{$self->{authorField}} = $origtext
                       if $self->{itemsList}[$self->{itemIdx}]->{url} =~ m,/author/,;               	
                    $self->{itemsList}[$self->{itemIdx}]->{title} = $origtext
                       if $self->{itemsList}[$self->{itemIdx}]->{url} =~ m,/album/,;                   
                	$self->{itemsList}[$self->{itemIdx}]->{$self->{seriesField}} = $origtext
                	   if $self->{itemsList}[$self->{itemIdx}]->{url} =~ m,/series/,;
                }
                $self->{isTitle} = 0;
            }
            elsif ($self->{isSerie})
            {
            	$self->{serie} = $origtext 
            	   if (!($origtext =~ m/votre recherche/));
            	$self->{isSerie} = 0;
            }
            elsif ($self->{isPublication})
            {
                return if ($self->{itemIdx} < 0);
                $self->{itemsList}[$self->{itemIdx}]->{publication} = substr($origtext, 2);
                $self->{isPublication} = 0;
            }
            elsif ($origtext =~ m/affiner pour afficher/i || $origtext =~ m/Aucun r.*sultat/i )
            {
                # too many results, search for series instead of albums
                $self->{nextUrl} = 'https://www.bdphile.info/search/series/?q='.$self->{searchWord};
            }
        }
        else
        {
            # Enleve les blancs en debut de chaine
            if ($self->{isReeditions} == 0)
            {
                $origtext =~ s/^\s+//;

                if ($self->{isSerie})
                {
                    $self->{curInfo}->{$self->{seriesField}} .= $origtext;
                }
                elsif ($self->{isTitle})
                {
                    $self->{curInfo}->{title} = $origtext;
                    if ($self->{curInfo}->{$self->{seriesField}} ne "")
                    {
                        $self->{curInfo}->{volume} = $1 if ($origtext =~ /Tome *([\d]*)/i);
                        $self->{curInfo}->{title} = $2 if ($origtext =~ /Tome *([\d]*) *: *(.*)/i);
                        $self->{curInfo}->{title} = $self->{curInfo}->{$self->{seriesField}}
                                                    ." - ".$self->{curInfo}->{volume}
                                                    ." - ".$self->{curInfo}->{title}
                            if ($self->{searchType} eq 'books');
                    }
                    $self->{newTitle} = $self->{curInfo}->{title};
                }
                elsif ($self->{isFieldName})
                {
                    $self->{fieldName} = $origtext;
                }
                elsif ($self->{isFieldValue})
                {
                    if (($self->{fieldName} =~ m/Sc.*nario/) || $self->{fieldName} =~ /Auteur/  || $self->{fieldName} =~ /Textes/)
                    {
                        $self->{author} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Dessin")
                    {
                        if ($self->{searchType} eq 'books')
                        {
                            if (! (grep /$origtext/, @{$self->{curInfo}{authors}}))
                            {
                                push @{$self->{curInfo}{authors}}, [$origtext];
                            }
                        }
                        $self->{curInfo}->{$self->{illustratorField}} .= ', ' if $self->{curInfo}->{illustrator};
                        $self->{curInfo}->{$self->{illustratorField}} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Lettrage")
                    {
                        $self->{curInfo}->{$self->{lettererField}} .= ', ' if $self->{curInfo}->{letterer};
                        $self->{curInfo}->{$self->{lettererField}} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Couleurs")
                    {
                        $self->{curInfo}->{$self->{colouristField}} .= ', ' if $self->{curInfo}->{colourist};
                        $self->{curInfo}->{$self->{colouristField}} .= $origtext;
                    }
                    elsif ($self->{fieldName} =~  /diteur/) # Éditeur (potential pb with accent)
                    {
                        $self->{curInfo}->{publisher} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Date de publication")
                    {
                        $origtext = GCUtils::strToTime($origtext,"%d %B %Y",$self->getLang());
                        $origtext = GCUtils::strToTime($origtext,"%d %b %Y",$self->getLang());
                        $origtext = GCUtils::strToTime($origtext,"%B %Y",$self->getLang());
                        $origtext = GCUtils::strToTime($origtext,"%Y",$self->getLang()) if ($origtext =~ /^\d+$/);
                        $self->{curInfo}->{$self->{publicationField}} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Collection" && $self->{searchType} ne 'books')
                    {
                        $self->{curInfo}->{collection} .= $origtext;
                    }
                    elsif ($self->{fieldName} eq "Format")
                    {
                        $self->{curInfo}->{format} .= $origtext;
                        $self->{curInfo}->{pages} = $1 if ($origtext =~ /([\d]*) *Pages/i);
                    }
                    elsif ($self->{fieldName} eq "EAN")
                    {
                        $origtext =~ s/\-//g;
                        $self->{curInfo}->{isbn} = $origtext;
                    }
                }
                elsif (($self->{isDescription}) && ($origtext ne "Synopsis"))
                {
                    $self->{curInfo}->{$self->{descriptionField}} .= $origtext;
                }
                $self->{curInfo}->{web} = $self->{itemsList}[$self->{wantedIdx}]->{url};

            }
        }
    }

    # new
    # Constructor.
    # Returns object reference.
    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();

        bless ($self, $class);

        $self->initParams;
        
        return $self;
    }

    sub initParams
    {
    	my $self = shift;
    	
    	# plugin used for books and comics that use different names for some fields
        $self->{seriesField}      = 'serie';
        $self->{coverField}       = 'cover';
        $self->{illustratorField} = 'artist';
        $self->{colouristField}   = 'artist';
        $self->{lettererField}    = 'artist';
        $self->{publicationField} = 'publication';
        $self->{authorField}      = 'authors';
        $self->{descriptionField} = 'description';

        # This member should be initialized as a reference
        # to a hash. Each keys is a field that could be
        # in results with value 1 or 0 if it is returned
        # or not. For the list of keys, check the model file
        # (.gcm) and search for tags <field> in
        # /collection/options/fields/results
        $self->{hasField} = {
            serie => 1,
            title => 1,
            authors => 0,
            artist => 0,
            publisher => 0,
            publication => 1,
            format => 0,
            edition => 0,
            web => 0,
            description => 0,
            isbn => 0,
        };

        $self->{lastPass} = 0;

        $self->{searchField} = ($self->getSearchFieldsArray())[0][0]
             if (! $self->{searchField});

        @{$self->{curInfo}{authors}} = ();
    }
    
    # preProcess
    # Called before each page is processed. You can use it to do some substitutions.
    # $html is the page content.
    # Returns modified version of page content.
    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{isTitle} = 0;
        $self->{isReeditions} = 0;
        $self->{isPublication} = 0;
        $self->{author} = "";
        $self->{stopSearch} = 0;
        $self->{serie} = "";
       
        $self->{lastPass} = 1 if ($self->{parsingList});
 
        return $html;
    }
}

1;
