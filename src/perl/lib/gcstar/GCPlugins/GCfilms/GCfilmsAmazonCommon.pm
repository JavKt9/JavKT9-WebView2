package GCPlugins::GCfilms::GCfilmsAmazonCommon;

###################################################
#
#  Copyright 2005-2010 Christian Jodar
#  Copyright 2019 Kerenoc
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

use GCPlugins::GCfilms::GCfilmsCommon;
use GCPlugins::GCstar::GCAmazonCommon;

{
    package GCPlugins::GCfilms::GCfilmsAmazonPluginsBase;

    use base ('GCPlugins::GCfilms::GCfilmsPluginsBase', 'GCPlugins::GCstar::GCPluginAmazonCommon');

    use GCUtils;

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

            $self->{beginParsing} = 1
                if ($tagname eq 'span' && $attr->{'data-component-type'} =~ m/s-search-results/);

            return if ! $self->{beginParsing};

            if ($tagname eq 'h2')
            {
                $self->{isTitle} = 1;
            }
            elsif ($self->{isTitle} && $tagname eq 'a' && $attr->{class} =~ /a-link-normal a-text-normal/)
            {
                if ($self->{isSponsored} eq 1)
                {
                    $self->{isSponsored} = 2;
                    return;
                }
                elsif ($self->{isSponsored} eq 2)
                {
                    $self->{isSponsored} = 0;
                }
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = "https://www.amazon.".$self->{suffix}.$attr->{href};
                $self->{isTitle} = 2;
            }
            return if $self->{isSponsored};
            if ($tagname eq 'span' && $attr->{'data-component-type'} =~ m/sp-sponsored-result/)
            {
            	$self->{isSponsored} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{'data-asin'})
            {
                $self->{isSponsored} = 0;
            }
            elsif ($tagname eq 'span' && $attr->{class} eq "a-size-small a-color-secondary")
            {
                $self->{isPublication} = 1
                    if ($self->{itemIdx} && !$self->{itemsList}[$self->{itemIdx}]->{date});
                $self->{isActors} = 1
                    if ($self->{itemIdx} && !$self->{itemsList}[$self->{itemIdx}]->{actors});
            }
        }
        else
        {
            if (($tagname eq "img") && ($attr->{id} eq 'landingImage' || $attr->{id} eq 'atf-full') && (!$self->{curInfo}->{image}))
            {
		        if ($attr->{src} =~ m/data:image/)
		        {
		            # image sent in HTML (film 2010)
		            $self->{curInfo}->{image} = $attr->{"data-a-dynamic-image"} if ($attr->{"data-a-dynamic-image"});
		        }
		        $self->{curInfo}->{image} = $attr->{src} if (! ($attr->{src} =~ m/data:image/));
            }
            elsif ($attr->{'data-automation-id'} =~ /synopsis/i && $self->{insideSynopsis} eq 0) # US Prime video
            {
                $self->{insideSynopsis} = 2;
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'descriptionAndDetails')
            {
                $self->{insideSynopsis} = 2;
            }
            elsif ( $self->{insideSynopsis}
                    && ($tagname eq 'style' || $tagname eq 'script' || $attr->{class} =~ /celwidget/))
            {
                $self->{insideSynopsis} = 3;
            }
            elsif (($tagname eq 'h3' || $tagname eq 'br'|| $tagname eq 'p') && $self->{insideSynopsis} eq 2)
            {
                $self->{curInfo}->{synopsis} .= "\n" if $self->{curInfo}->{synopsis};
            }
            elsif ($tagname eq 'span' && $attr->{'data-automation-id'} =~  m/maturity-rating/ && ! $self->{curInfo}->{age})
            {
                $attr->{title} =~ s/\s*$//;
                $self->{curInfo}->{age} = $self->decodeAge($attr->{title});
            }
            elsif ($tagname eq 'div' && ($attr->{class} =~  m/bgimg-desktop/ || $attr->{class} =~  m/fallback-packshot/) )
            {
                $self->{insideImage} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{class} =~ m/bgimg__div/ && $self->{insideImage})
            {
                if ($attr->{style} =~ m/url\((.*)\)/)
                {
                    $self->{curInfo}->{image} = $1;
                    $self->{insideImage} = 0;
                }
            }
            elsif ($tagname eq 'img' && $self->{insideImage})
            {
                $self->{curInfo}->{image} = $attr->{src};
                $self->{insideImage} = 0;
            }
            elsif ($tagname eq 'div' && $attr->{id} =~ m/detailBullets/) # Products Details zone
            {
                $self->{insideField} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{id} eq 'bylineInfo') # Detail line after title
            {
                $self->{insideField} = 1;
            }
            elsif ($tagname eq 'div' && $attr->{'data-automation-id'} =~ m/meta-info/) # US Prime video
            {
                $self->{insideField} = 1;
                $self->{insideSynopsis} = 3; # stop scanning for synopsis
            }
            elsif ($tagname eq "span")
            {
		        $self->{insideGenre} = 1 if ($attr->{class} eq "zg_hrsr_ladder");
		        $self->{isTitle} = 1 if ($attr->{id} eq 'productTitle');
                $self->{insideDate} = 1 if ($attr->{'data-automation-id'} =~ m/release-year/); # US Prime video
                $self->{insideTime} = 1 if ($attr->{'data-automation-id'} =~ m/runtime/);      # US Prime video
                $self->{insideAge}  = 1
                    if ($attr->{'data-automation-id'} =~ m/^rating-badge/ && !$self->{curInfo}->{age}); # US Prime video
                $self->{insideDate} = 1 if ($attr->{id} =~ /tmmSpinnerDiv_/);
            }
            elsif ($tagname eq "h1" && $attr->{'data-automation-id'} eq "title")
            {
                # US Prim video
                $self->{fieldEnd} = '';
                $self->{isTitle} = 1;
            }
            elsif ($tagname eq 'li' && $attr->{class} eq "swatchElement selected")
            {
                $self->{insideFormat} = 1;
            }
            elsif ($tagname eq 'i' && $attr->{class} =~ m/a-icon-star/ && ! $self->{curInfo}->{ratingpress})
            {
                $self->{insideField} = 0;
                $self->{insideRatingPress} = 1;
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        if ($tagname eq "li")
        {
            $self->{insideActors} = 0;
            $self->{insideDirector} = 0;
            $self->{insideGenre} = 0;
        }
        elsif ($tagname eq 'h3' && $self->{insideSynopsis} eq 2)
        {
            $self->{curInfo}->{synopsis} .= "\n";
        }
	    elsif ($tagname eq 'table' || $tagname eq 'script')
	    {
	        $self->{insideField} = 0;
	    }
	    elsif ($tagname eq 'dl')   # US Prime Video
	    {
            $self->resetFields();
	    }
	    elsif ($tagname eq 'h2')
	    {
	        $self->{isTitle} = 0;
	    }
    }

    sub text
    {
        my ($self, $origtext) = @_;

        $origtext =~ s/[\n\s]*$//s;
        $origtext =~ s/^[\n\s]*//s;
        return if $origtext eq '';

        if ($self->{parsingList})
        {
            return if ! $self->{beginParsing};

            if ($self->{isTitle} eq 2)
            {
            	$self->{itemsList}[$self->{itemIdx}]->{title} = $origtext;
            	$self->{isTitle} = 0;
            }
            elsif (($self->{inside}->{title})
             && ($origtext !~ /^$self->{translations}->{site}/))
            {
                $self->{parsingEnded} = 1;
            }
            elsif ($self->{isPublication} eq 1 && $origtext =~ m/^[0-9]{4}$/)
            {
                $origtext =~ m/([0-9]{4})/;
                $self->{itemsList}[$self->{itemIdx}]->{date} = $1;
                $self->{isPublication} = 0;
                return;
            }
            elsif ($self->{isActors} eq 1)
	        {
	           $self->{isActors} = 2 if ($origtext =~ m/$self->{translations}->{distribution}/);
	        }
            elsif ($self->{isActors} eq 2)
            {
                $self->{itemsList}[$self->{itemIdx}]->{actors} = $origtext
                    if ! $self->{itemsList}[$self->{itemIdx}]->{actors};
                $self->{isActors} = 0;
                return;
            }
            elsif ($origtext =~ m/^$self->{translations}->{sponsored}/)
            {
                $self->{isSponsored} = 1;
            }
        }
        else
        {
            $origtext =~ s/\s{2,}/ /g;
            $origtext =~ s/\s+,/,/;
            $origtext =~ s/^\s*//;
            $origtext =~ s/\s*$//;

            return if ! $origtext;

            if (($self->{insideActors}) && ($origtext !~ /^,/))
            {
                foreach my $actor (split /,/,$origtext)
                {
                    if ($self->{actorsCounter} < $GCPlugins::GCfilms::GCfilmsCommon::MAX_ACTORS)
                    {
                        push @{$self->{curInfo}->{actors}}, [$actor];
                        $self->{actorsCounter}++;
                    }
                }
            }
            elsif (($self->{insideDirector}) && ($origtext !~ /^,/))
            {
                $origtext =~ s/,.$//;
                $self->{curInfo}->{director} .= ", "
                    if $self->{curInfo}->{director};
                $self->{curInfo}->{director} .= $origtext;
            }
            elsif ($self->{insideTime} && ! $self->{curInfo}->{time})
            {
                $self->{curInfo}->{time} =~ s/.*:\s*//i;
                $self->{curInfo}->{time} = $origtext;
                $self->{curInfo}->{time} =~ /(\d+)[^0-9]*(\d+)\s*(m|min|minutes|Minuten).*/;
                if ($2)
                {
                    $self->{curInfo}->{time} = 60*$1 + $2;
                }
                $self->{curInfo}->{time} =~ s/\..*//i;
                $self->{curInfo}->{time} =~ s/ [a-z]+//i;
                $self->{insideTime} = 0;
            }
            elsif ($self->{insideDate} && ! $self->{curInfo}->{date})
            {
                $origtext =~ s/\-$//;
                $self->{curInfo}->{date} = $self->decodeDate($origtext);
                $self->{insideDate} = 0;
            }
            elsif ($self->{insideVideo})
            {
                $self->{curInfo}->{video} = $origtext;
                $self->{insideVideo} = 0;
            }
            elsif ($self->{insideFormat})
            {
                $self->{curInfo}->{format} = $origtext;
                $self->{insideFormat} = 0;
            }
            elsif (($self->{insideOriginal} eq 1) && ($origtext =~ m/$self->{translations}->{description}/i ))
            {
                $self->{insideOriginal} = 2;
            }
            elsif (($self->{insideOriginal} eq 2) && ($origtext ne ''))
            {
		        if ($origtext =~ m/\(.*\),.*,.*$self->{translations}->{minutes}/)
		        {
		            $origtext =~ s/.*\(//;
		            $origtext =~ s/\).*//;
		            $origtext =~ s/\..*//;
		            $self->{curInfo}->{original} .= $origtext;
		        }
		        $self->{insideOriginal} = 0;
            }
            elsif (($self->{insideSynopsis} eq 1) && ($origtext eq 'Synopsis' || $origtext eq $self->{translations}->{description}))
            {
                $self->{insideSynopsis} = 2;
            }
            elsif (($self->{insideSynopsis} eq 2) && ($origtext ne '') && ! $self->{inside}->{h2})
            {
                $self->{curInfo}->{synopsis} .= $origtext;
            }
            elsif ($self->{insideAudio})
            {
                $self->{curInfo}->{audio} .= ', ' if $self->{curInfo}->{audio};
                $self->{curInfo}->{audio} .= $origtext;
                $self->{insideAudio} = 0;
            }
            elsif ($self->{insideSubTitle})
            {
                $self->{curInfo}->{subt} = $origtext;
                $self->{insideSubTitle} = 0;
            }
	        elsif ($self->{insideGenre} eq 1)
	        {
		        if (! ($origtext =~ m/^Blu-ray/i || $origtext =~ m/[>,]/ || $origtext =~ m/^$self->{translations}->{in}/))
		        {
		            $origtext =~ s/\s*\(DVD.*Blu-ray\)//;
		            $origtext = ", ".$origtext if ($self->{curInfo}->{genre});
		            $self->{curInfo}->{genre} .= $origtext;
		        }
	        }
            elsif ($self->{insideAge} eq 1)
            {
                $self->{curInfo}->{age} = $self->decodeAge($origtext) if ! $self->{curInfo}->{age};
                $self->{insideAge} = 0;
            }
            elsif ($self->{insideField})
            {
                $self->{insideActors}   = 1 if $origtext =~ /^$self->{translations}->{actors}$self->{fieldEnd}/i;
                $self->{insideDirector} = 1 if $origtext =~ /^$self->{translations}->{director}$self->{fieldEnd}/i;
                $self->{insideDate}     = 1 if $origtext =~ /^$self->{translations}->{date}$self->{fieldEnd}/i;
                $self->{insideTime}     = 1 if $origtext =~ /^$self->{translations}->{duration}$self->{fieldEnd}/i;
                $self->{insideAudio}    = 1 if $origtext =~ /^$self->{translations}->{audio}$self->{fieldEnd}/i;
                $self->{insideSubTitle} = 1 if $origtext =~ /^$self->{translations}->{subtitles}$self->{fieldEnd}/i;
                $self->{insideVideo}    = 1 if $origtext =~ /^$self->{translations}->{video}$self->{fieldEnd}/i;
                $self->{insideGenre}    = 1 if $origtext =~ /^$self->{translations}->{genre}$self->{fieldEnd}/i;
                $self->{insideAge}      = 1 if $origtext =~ /^$self->{translations}->{age}$self->{fieldEnd}/i;
            }
	        elsif ($self->{isTitle} eq 1)
	        {
		        $self->{curInfo}->{title} = $origtext;
		        $self->{isTitle} = 0;
	        }
	        elsif ($self->{insideRatingPress})
	        {
	            return if (! ($origtext =~ m/$self->{translations}->{stars}/));
                $origtext =~ s/\s*$self->{translations}->{stars}//;
                $origtext =~ s/,/./;
                $self->{curInfo}->{ratingpress} = $origtext * 2;
                $self->{insideRatingPress} = 0;
	        }
        }
    }

    sub resetFields
    {
        my $self = shift;

        $self->{insideActors} = 0;
        $self->{insideDirector} = 0;
        $self->{insideDate} = 0;
        $self->{insideTime} = 0;
        $self->{insideAudio} = 0;
        $self->{insideSubTitle} = 0;
        $self->{insideFormat} = 0;
        $self->{insideOriginal} = 0;
        $self->{insideGenre} = 0;
        $self->{insideVideo} = 0;
        $self->{insideFormat} = 0;
        $self->{insideRatingPress} = 0;
        $self->{insideImage} = 0;
        $self->{insideAge} = 0;
        $self->{currentName} = 0;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $html = $self->SUPER::preProcess($html);

        $self->resetFields();
        $self->{insideSynopsis} = 0;
        $self->{insideField} = 0;
        $self->{fieldEnd} = ".*:"; # ending of the field name (different for US Prime videos)

        if ($self->{parsingList})
        {
            $html =~ s|~(.*?)<span class="bindingBlock">\(<span class="binding">(.*?)</span>( - .*?[0-9]{4})?\)</span>|<actors>$1</actors><format>$2</format><publication>$3</publication>|gsm;
        }
        else
        {
            # problem when an image is embedded in the HTML (film 2010)
            # the attribute data-a-dynamic-image="{&quote;http would return {
            $html =~ s/data-a-dynamic-image="\{&quot;/data-a-dynamic-image="/;
        }

        $self->{parsingEnded} = 0;
        $self->{currentRetrieved} = '';
        $self->{beginParsing} = 0;

        return $html;
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{codeField} = '';
        $self->{searchType} = 'dvd';

        return $self;
    }

    sub getSearchFieldsArray
    {
        return ['title','ean'];
    }

    sub getEanField
    {
        return 'ean';
    }

    sub decodeAge()
    {
        my ($self, $age) = @_;

        my $resultAge;
        $resultAge = 1 if ($age eq 'NR'); # not rated
        $resultAge = 2 if $age =~ m/^$self->{translations}->{ratedG}/i;
        $resultAge = 5 if $age =~ m/^$self->{translations}->{ratedPG}/i;
        $resultAge = 13 if $age =~ m/^$self->{translations}->{ratedPG13}/i;
        $resultAge = 18 if $age =~ m/^$self->{translations}->{ratedR}/i;
        $resultAge = $1 if ($age =~ m/(\d+)/);
        $resultAge = $age if ! $resultAge;
        return $resultAge;
    }
}

1;
