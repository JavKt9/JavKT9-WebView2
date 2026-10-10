package GCPlugins::GCgames::GCAmazonDE;

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

use GCPlugins::GCgames::GCgamesAmazonCommon;

{
    package GCPlugins::GCgames::GCPluginAmazonDE;

    use base 'GCPlugins::GCgames::GCgamesAmazonPluginsBase';
    use Encode;
    use URI::Escape;

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{suffix} = 'de';

        $self->initTranslations;
        
        return $self;
    }

    sub initTranslations
    {
        my $self = shift;
        
        $self->{translations} = {
            publisher     => "Verlag:",
            publication   => "Audible.de Erscheinungsdatum:",
            language      => "Sprache:",
            isbn          => "ISBN",
            dimensions    => "e und/oder Gewicht",
            series        => "Series",
            pages         => "Seiten",
            by            => "von",
            product       => "Produktinformation",
            details       => "Technische Details",
            additional    => "Zusätzliche Produktinformationen",
            end           => "Feedback",
            sponsored     => "Gesponsert",
            description   => "Produktbeschreibungen",
            author        => "Autor",
            translator    => "bersetzer",  # Übersetzer
            artist        => "Illustrator"
        };
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->initVariables;

        if ($self->{parsingList})
        {
            $html =~ s/.*s-search-results"/<span /s;
            $html =~ s/<div class="s-result-list-placeholder.*//s;
        }
        else
        {
            #$html =~ s/Produktbeschreibungen/<tpfdescription>/;
            # Le descriptif pouvant contenir des balises html je le repere maintenant
            #my $found = index($html,"<tpfdescription>");
            my $found = index($html,"ProductDescriptionIframeResize");
            if ( $found >= 0 )
            {
               my $foundScriptStart = rindex($html, '<script', $found);
               my $foundScriptEnd   = index($html, '</script>',$found);
               my $foundIframeStart = index($html, 'iframeContent', $found);
               my $html2 = substr($html, $foundIframeStart, 400);
               $foundIframeStart = index($html, '"', $foundIframeStart);
               $html2 = substr($html, $foundIframeStart, 400);
               my $foundIframeEnd   = index($html, '"', $foundIframeStart+1);
               $html2 = substr($html, $foundIframeStart+1,$foundIframeEnd - $foundIframeStart -1);
               my $html3 = Encode::decode('utf8', uri_unescape($html2));
                
               my $foundDescriptionStart = index($html3, 'dir="auto" >');
               my $foundDescriptionEnd   = index($html3, '<div class="emptyClear"> </div>',$foundDescriptionStart);
               $html2 = substr($html3, $foundDescriptionStart+12,$foundDescriptionEnd - $foundDescriptionStart -12);
               $html2 =~ s|</li>||gi;
               $html2 =~ s|<p>|\n\n|gi;
               $html2 =~ s|</p>||gi;
               $html2 =~ s|<ul>|\n|gi;
               $html2 =~ s|</ul>|\n\n|gi;
               $html2 =~ s|<strong>||gi;
               $html2 =~ s|</strong>||gi;
               $html2 =~ s|<em>||gi;
               $html2 =~ s|</em>||gi;
               $html2 =~ s|%20| |gi;

               $html = substr($html, 0, $foundScriptStart) . '<tpfdescription>' . $html2."</tpfdescription>" ;
            }

            $html =~ s/Erscheinungsdatum&nbsp;:</<tpfdateparution></gi;
            $html =~ s/Erscheinungsdatum:</<tpfdateparution></gi;
            $html =~ s/<b>Plattform:<\/b> &nbsp;</<tpfplateforme><\/tpfplateforme></gi;
            $html =~ s/<b>Plattform:<\/b>/<tpfplateforme><\/tpfplateforme>/gi;
            $html =~ s/registerImage\("original_image",/<\/script><tpfcouverture src=/gi;
            $html =~ s/registerImage\("alt_image_1",/<\/script><tpfscreenshot1 src=/gi;
            $html =~ s/registerImage\("alt_image_2",/<\/script><tpfscreenshot2 src=/gi;
            $html =~ s|<b>||gi;
            $html =~ s|</b>||gi;
            $html =~ s|<i>||gi;
            $html =~ s|</i>||gi;
            $html =~ s|<li>|*|gi;
            $html =~ s|<br>|\n|gi;
            $html =~ s|<br />|\n|gi;
            $html =~ s|\x{92}|'|gi;
            $html =~ s|&#146;|'|gi;
            $html =~ s|&#149;|*|gi;
            $html =~ s|&#133;|...|gi;
            $html =~ s|\x{85}|...|gi;
            $html =~ s|\x{8C}|OE|gi;
            $html =~ s|\x{9C}|oe|gi;
        }
        return $html;
    }

    sub getName
    {
        return 'Amazon (DE)';
    }
    
    sub getLang
    {
        return 'DE';
    }

}

1;
