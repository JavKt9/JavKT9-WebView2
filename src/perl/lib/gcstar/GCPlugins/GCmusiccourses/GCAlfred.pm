package GCPlugins::GCmusiccourses::GCAlfred;

###################################################
#
#  Copyright 2009 by FiXx
#  Copyright 2019 by Kerenoc
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
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################

use strict;
use utf8;

use GCPlugins::GCmusiccourses::GCMusicCoursesCommon;

{

    package GCPlugins::GCmusiccourses::GCPluginAlfred;

    use base qw(GCPlugins::GCmusiccourses::GCMusicCoursesPluginsBase);

    sub start {
        my ( $self, $tagname, $attr, $attrseq, $origtext ) = @_;

        if ( $self->{parsingList} )
		{
            if (  ($tagname eq 'a')
               && ($attr->{class} =~ /product_link/) )
            {
                $self->{itemIdx}++;
                my $url = $attr->{href};
                $self->{itemsList}[ $self->{itemIdx} ]->{url} = $url;
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $attr->{'data-title'};
                # Result display doesn't manage arrays. Simple list fields are managed as texts. No push
				$self->{itemsList}[ $self->{itemIdx} ]->{publisher} = $self->getName();
            }
			if ( !($self->{itemIdx} < 0) )
            {
                if ($attr->{id} =~ /^prodTitle_/)
                {
                    $self->{insideTitle} = 1;
                }
                elsif ($attr->{id} =~ /_PubItem$/)
                {
                    $self->{insideIdentifier} = 1;
                }
                elsif ($attr->{id} =~ /^UPCHidden_/)
                {
                    my $upc = $attr->{value};
                    $self->{itemsList}[ $self->{itemIdx} ]->{upc} = $upc;
                }
                elsif ($attr->{id} =~ /^ISBN10Hidden_/)
                {
                    my $isbn10 = $attr->{value};
                    $self->{itemsList}[ $self->{itemIdx} ]->{isbn10} = $isbn10;
                }
                elsif ($attr->{id} =~ /^ISBN13Hidden_/)
                {
                    my $isbn13 = $attr->{value};
                    $self->{itemsList}[ $self->{itemIdx} ]->{isbn13} = $isbn13;
                }
                elsif ($attr->{id} =~ /^AuthorHidden_/)
                {
                    my $actor = $attr->{value};
					$actor =~ s/^By //g;
# Result display doesn't manage arrays. Simple list fields are managed as texts. Actors are anyway retreived in a single string by Alfred
#					$self->{itemsList}[ $self->{itemIdx} ]->{actors} .= ", " if $self->{itemsList}[ $self->{itemIdx} ]->{actors};
					$self->{itemsList}[ $self->{itemIdx} ]->{actors} .= $actor;
                }
                elsif ($attr->{id} =~ /_Instrument$/)
                {
                    $self->{insideInstrument} = 1;
                }
                elsif ($attr->{id} =~ /_Format$/)
                {
                    $self->{insideVideo1Format} = 1;
                }
            }			
		}
		else {
			if ($attr->{class} =~ /product-title/ || $attr->{id} =~ /_lblTitle$/)
            {
                $self->{insideTitle} = 1;
            }
			elsif ($attr->{class} =~ /product-subtitle/ || $attr->{id} =~ /_lblSubTitle$/)
            {
                $self->{insideSubTitle} = 1;
            }
            elsif ($attr->{id} =~ /_lblAuthor$/)
            {
                $self->{insideActors} = 1;
            }
            elsif ($attr->{id} =~ /_lblInstrument$/)
            {
                $self->{insideInstrument} = 1;
            }
            elsif ($attr->{id} =~ /_lblFormat$/)
            {
                $self->{insideVideo1Format} = 1;
            }
            elsif ($attr->{id} =~ /_lblDifficulty$/)
            {
                $self->{insideLevel} = 1;
            }
			elsif ($tagname eq 'img' || $attr->{id} =~ /_imgProduct$/)
            {
                    my $src = $attr->{src};
					$self->{curInfo}->{image} = $src if length($src) > 0;
            }
        }

	}
	
    sub end {
        my ( $self, $tagname ) = @_;
		
        if ( !$self->{parsingList} )
		{
            if ($tagname eq 'html') # This is the end
	        {
                if ( $self->{subTitle} )
			    {
			        $self->{curInfo}->{title} = $self->{subTitle} . ' - ' . $self->{curInfo}->{title};
			    }
                if ( $self->{curInfo}->{series} )
			    {
			        $self->{curInfo}->{title} = $self->{curInfo}->{series} . ' - ' . $self->{curInfo}->{title};
			    }
				$self->{curInfo}->{title} = $self->getName() . ' - ' . $self->{curInfo}->{title};
			}
        }

    }

    sub text {
        my ( $self, $origtext ) = @_;
		
		# Remove carriage/return as well as starting and ending spaces
        $origtext =~ s/[\r\n]//g;
        $origtext =~ s/^\s*//;
        $origtext =~ s/\s*$//;
		return if ($origtext eq '');
		
        if ( $self->{parsingList} ) 
		{
            if ($self->{insideTitle})
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{title} = $origtext;
                $self->{insideTitle} = 0;
            }
            elsif ($self->{insideIdentifier})
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{identifier} = $origtext;
                $self->{insideIdentifier} = 0;
            }
            elsif ($self->{insideVideo1Format})
            {
                $self->{itemsList}[ $self->{itemIdx} ]->{video1Format} = $origtext;
                $self->{insideVideo1Format} = 0;
            }
		}
		else
        {
            if ($self->{insideTitle})
            {
                $self->{curInfo}->{title} = $origtext;
                $self->{insideTitle} = 0;
            }
            elsif ($self->{insideSubTitle})
            {
                $self->{subTitle} = $origtext;
                $self->{insideSubTitle} = 0;
            }
            elsif ($self->{insideSeries})
            {
                $self->{curInfo}->{series} = $origtext;
                $self->{insideSeries} = 0;
            }
            elsif ($self->{insideArtist})
            {
                $self->{curInfo}->{artist} = $origtext;
                $self->{insideArtist} = 0;
            }
            elsif ($self->{insideIdentifier})
            {
                $self->{curInfo}->{identifier} = $origtext;
                $self->{insideIdentifier} = 0;
            }
            elsif ($self->{insideUpc})
            {
                $self->{curInfo}->{upc} = $origtext;
                $self->{insideUpc} = 0;
            }
            elsif ($self->{insideIsbn10})
            {
                $origtext =~ s/-//g;
                $self->{curInfo}->{isbn10} = $origtext;
                $self->{insideIsbn10} = 0;
            }
            elsif ($self->{insideIsbn13})
            {
                $origtext =~ s/-//g;
                $self->{curInfo}->{isbn13} = $origtext;
                $self->{insideIsbn13} = 0;
            }
            elsif ($self->{insideSynopsis})
            {
                $self->{curInfo}->{synopsis} = $origtext;
				push @{$self->{curInfo}->{publisher}}, [$self->getName()];
                $self->{insideSynopsis} = 0;
            }
            elsif ($self->{insideActors})
            {
				$origtext =~ s/^By //g;
                push @{$self->{curInfo}->{actors}}, [$origtext];
                $self->{insideActors} = 0;
            }
            elsif ($self->{insideInstrument})
            {
				push @{$self->{curInfo}->{instrument}}, [$origtext];
                $self->{insideInstrument} = 0;
            }
            elsif ($self->{insideLevel})
            {
 				push @{$self->{curInfo}->{level}}, [$origtext];
                $self->{insideLevel} = 0;
            }
            elsif ($self->{insideVideo1Format})
            {
                $self->{curInfo}->{video1Format} = $origtext;
                $self->{insideVideo1Format} = 0;
            }
            elsif ($origtext eq 'Additional Information')
            {
                $self->{insideInfos} = 1;
                $self->{insideSongs} = 0;
            }
            elsif ($origtext eq 'Contents')
            {
                $self->{insideSongs} = 1;
            }
            elsif ($origtext eq 'Description')
            {
                $self->{insideSynopsis} = 1;
            }
            elsif ($self->{insideSongs} && $origtext eq 'Title')
            {
                $self->{insideSongs} = 2;
            }
            elsif ($self->{insideSongs} eq 2)
            {
                $origtext = ", ".$origtext if $self->{curInfo}->{song};
                $self->{curInfo}->{song} .= $origtext;
            }
            elsif ($self->{insideInfos})
            {
                $self->{insideSeries}      = 1 if ($origtext eq 'Series:');
                $self->{insideIsbn10}      = 1 if ($origtext eq 'ISBN 10:');
                $self->{insideIsbn13}      = 1 if ($origtext eq 'ISBN 10:');
                $self->{insideUpc}         = 1 if ($origtext eq 'UPC:');
                $self->{insideInstrument}  = 1 if ($origtext eq 'Instrument:');
                $self->{insideArtist}      = 1 if ($origtext eq 'Artist:');
                $self->{insideIdentifier}  = 1 if ($origtext eq 'Item Number:');
                $self->{insideVideoFormat} = 1 if ($origtext eq 'Format:');
            }
		}

    }

    sub new {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless( $self, $class );

        $self->{hasField} = {
			title           => 1,
			publisher       => 1,
	        series          => 0,	
			director        => 0,
			date            => 0,
			time            => 0,
            identifier      => 1,
            upc             => 1,
            isbn10          => 1,
	        isbn13          => 1,
	        synopsis        => 0,
            actors          => 1,
	        instrument      => 1,
	        genre           => 0,
	        level           => 0,
	        video1Format    => 1,
	        ratingPress     => 0,
        };
		
		# Temporary storage of subtitle for inclusion in title
		$self->{subTitle}  = undef;
		
        return $self;
    }

    sub preProcess {
        my ( $self, $html ) = @_;

        $self->{parsingEnded} = 0;

	    if ($self->{parsingList})
	    {

        }
        else
		{
			$self->{curInfo}->{webSource} = $self->{loadedUrl};
		}
		
        return $html;
    }

    sub getSearchUrl {
        my ( $self, $word ) = @_;
		my $searchvalue = 32 ;
		my $strictmatching = 0;
		
		if ($strictmatching)
		{
			$searchvalue = 64 ;
		}
		return "https://www.alfred.com/search/ajax/grid/?q=".$word."&page=1&sort=relevance&grid=view";
		return "https://www.alfred.com/search/products/?query=".$word;
        return "http://www.alfred.com/Search/SearchResults.aspx?q=$word&type=Title";
    }
	
    sub getSearchCharset
    {
        my $self = shift;

        # Need urls to be double character encoded
        return "utf8";
    }

    sub getItemUrl {
        my ( $self, $url ) = @_;
		
        return 'https://www.alfred.com' . $url;
    }

    sub changeUrl {
        my ( $self, $url ) = @_;

        return $url;
    }

    sub getName {
	
        return 'Alfred';
    }

    sub getCharset {
        my $self = shift;

        return 'ISO-8859-1';
    }

    sub getAuthor {
	
        return 'Nle - Kerenoc';
    }

    sub getLang {
        return 'EN';
    }
}

1;
