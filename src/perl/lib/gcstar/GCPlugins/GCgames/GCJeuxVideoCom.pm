package GCPlugins::GCgames::GCJeuxVideoCom;

###################################################
#
#  Copyright 2005-2020 Tian - TPF
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

use GCPlugins::GCgames::GCgamesCommon;

{
    package GCPlugins::GCgames::GCPluginJeuxVideoCom;

    use base 'GCPlugins::GCgames::GCgamesPluginsBase';

    use GCUtils;

    sub decryptUrl
    {
        my ($self, $src) = @_;
        my $n = '0A12B34C56D78E9F';
        my $res = 'http://www.jeuxvideo.com';
        my $s = reverse $src;
        my ($c, $l);
        while (length $s)
        {
            $l = index $n, chop $s;
            $c = index $n, chop $s;
            my $car = $l * 16 + $c;
            $res .= chr $car;
        }
        return $res;
    }

    sub getPlatformName
    {
        my ($self, $platform) = @_;
        $platform =~ s/^32X$/Mega Drive 32X/;
        $platform =~ s/^360$/Xbox 360/;
        # 3DO
        $platform =~ s/^3DS$/Nintendo 3DS/;
        $platform =~ s/^5200$/Atari 5200/;
        $platform =~ s/^7800$/Atari 7800/;
        # Amiga
        # Android
        $platform =~ s/^Apple 2$/Apple II/;
        # Arcade
        # Box Bouygues
        # Box Free
        # Box Orange
        # Box SFR
        $platform =~ s/^C64$/Commodore 64/;
        $platform =~ s/^CDI$/CD-i/;
        $platform =~ s/^ColecoV$/ColecoVision/;
        $platform =~ s/^CPC$/Amstrad CPC/;
        $platform =~ s/^DCAST$/Dreamcast/;
        $platform =~ s/^DS$/Nintendo DS/;
        $platform =~ s/^FDS$/Famicom Disk System/;
        $platform =~ s/^G&W$/Game & Watch/;
        $platform =~ s/^G.GEAR$/Game Gear/;
        $platform =~ s/^GB$/Game Boy/;
        $platform =~ s/^GBA$/Game Boy Advance/;
        $platform =~ s/^GBC$/Game Boy Color/;
        $platform =~ s/^Giz$/Gizmondo/;
        # GP32
        # ? GX-4000
        $platform =~ s/^IntelliV$/Intellivision/;
        # Intellivision Amico
        # iOS
        # Jaguar
        # Linux
        # Lynx
        # Mac
        $platform =~ s/^MD$/Mega Drive/;
        # Mega-CD
        $platform =~ s/^MS$/Master System/;
        # MSX
        $platform =~ s/^N64$/Nintendo 64/;
        $platform =~ s/^NEO$/Neo Geo/;
        # Nes
        $platform =~ s/^New 3DS$/New Nintendo 3DS/;
        $platform =~ s/^NGAGE$/N-Gage/;
        $platform =~ s/^NGC$/Gamecube/;
        $platform =~ s/^NGPocket$/Neo Geo Pocket/;
        # ? Odyssey
        $platform =~ s/^ONE$/Xbox One/;
        # OUYA
        # PC
        $platform =~ s/^PC ENG$/PC Engine/;
        $platform =~ s/^PS1$/PlayStation/;
        $platform =~ s/^PS2$/PlayStation 2/;
        $platform =~ s/^PS3$/PlayStation 3/;
        $platform =~ s/^PS4$/PlayStation 4/;
        $platform =~ s/^PS5$/PlayStation 5/;
        # PSP
        # Saturn
        # Shield TV
        $platform =~ s/^SNES$/Super Nintendo/;
        $platform =~ s/^ST$/Atari ST/;
        # Stadia
        # Steam Machine
        # Switch
        $platform =~ s/^V.BOY$/Virtual Boy/;
        # ? Vectrex
        $platform =~ s/^VCS$/Atari 2600/;
        $platform =~ s/^Vita$/PS Vita/;
        $platform =~ s/^VPAC$/Videopac/;
        # Web
        # Wii
        $platform =~ s/^WiiU$/Wii U/;
        $platform =~ s/^WSwan$/WonderSwan/;
        # ? WonderSwan Color
        # Xbox
        $platform =~ s/^Xbox Series$/Xbox Series X/;
        $platform =~ s/^ZXS$/ZX Spectrum/;
        return $platform;
    }

    sub loadMultipleResults
    {
        my ($self, $url) = @_;
        my $page = $self->loadPage($url);
        # C est la date de la premiere sortie quelque soit la plateforme
        $page =~ /class="gameCharacteristicsMain__infoLabel">Sortie\s+:\s+<\/span>(.*?)<\/div>/s;
        my $released = $1;
        # Enleve les blancs en debut de chaine
        $released =~ s/^\s+//;
        # Enleve les blancs en fin de chaine
        $released =~ s/\s+$//;
        $page =~ m/Banner__title">([^<]*)</s;
        my $name = $1;
        $name =~ s/&#039;/'/g;
        $name =~ s/&amp;/&/g;
        $page =~ s/.*Banner__platforms[^<]*</</s;
        $page =~ s/<\/ul>.*//s;
        my @lines = split /href="/, $page;
        my $platform = '';
        foreach my $line (@lines)
        {
            if ($line =~ /(\/jeux[^"]*)".*Link *">\n* *([0-9a-zA-Z_. -]*).*<\/a>/s)
            {
                my $url = $1;
                my $platform = $self->getPlatformName($2);
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}]->{url} = 'http://www.jeuxvideo.com'.$url;
                $self->{itemsList}[$self->{itemIdx}]->{name} = $name;
                $self->{itemsList}[$self->{itemIdx}]->{platform} = $platform;
                $self->{itemsList}[$self->{itemIdx}]->{released} = $released;
            }
            elsif ($line =~ /<span class="label-support active-mach-version label-.*" itemprop="device" content=".*">([0-9a-zA-Z_. -]*)<\/span>/)
            {
                # for some reason, it ends with a / but it's not a multi-platform game
                $self->{itemIdx}++;
                $name =~ s/ sur $1$//e;
                $self->{itemsList}[$self->{itemIdx}]->{url} = $url;
                $self->{itemsList}[$self->{itemIdx}]->{name} = $name;
                $self->{itemsList}[$self->{itemIdx}]->{platform} = $self->getPlatformName($1);
                $self->{itemsList}[$self->{itemIdx}]->{released} = $released;
            }
        }
    }

    sub start
    {
        my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
        $self->{inside}->{$tagname}++;
        if ($self->{parsingList})
        {
            return if $self->{ending};
            if ($tagname eq 'span')
            {
                if (($attr->{class} =~ /JvCare\s+([0-9A-F]*)\s+lien-jv/) && ($attr->{title} ne ""))
                {
                    my $url = $self->decryptUrl($1);
                    print $url, $origtext;
                    if (! exists $self->{urls}->{$url})
                    {
                        if ($url =~ /\/$/)
                        {
                            #If it ends with a /, it means it's a multi-platform game, and the link points to a common page
                            $self->loadMultipleResults($url);
                            $self->{urls}->{$url} = 1;
                        }
                        else
                        {
                            $self->{itemIdx}++;
                            $self->{itemsList}[$self->{itemIdx}]->{url} = $url;
                            $self->{isGame} = 1;
                            # Note : some game's name contains '-' => not use $attr->{title}
                            $self->{isName} = 1;

                            my @array = split(/-/,$attr->{title});
                            if (scalar(@array) ge 3 )
                            {
                                if (!($array[$#array] =~ /date/i))
                                {
                            $self->{itemsList}[$self->{itemIdx}]->{released} = $array[$#array];
                                }
                            }

                            $self->{urls}->{$url} = 1;
                        }
                    }
                }
                return if !$self->{isGame};
                if ($attr->{class} =~ /recherche-aphabetique-item-machine/)
                {
                    $self->{isPlatform} = 1;
                }
            }
            elsif ($tagname eq 'div' && $attr->{class} eq 'recherche-aphabetique-sous-titre')
            {
                $self->{ending} = 1;
            }
        }
        elsif ($self->{parsingTips})
        {
            if ($attr->{class} eq 'rubrique-asl')
            {
                $self->{isTip} = 1;
            }
            elsif (($tagname eq 'tpfdebuttpf') && ($self->{isTip} eq 2))
            {
                $self->{isTip} = 3;
            }
            elsif ( (($tagname eq 'p') || ($tagname eq 'h2') || ($tagname eq 'h3') || ($tagname eq 'pre')) && (($self->{isTip} eq 3) || ($self->{isTip} eq 4)) )
            {
                $self->{curInfo}->{secrets} .= "\n" if $self->{curInfo}->{secrets};
            }
            elsif (($tagname eq 'tpffintpf') && ($self->{isTip} ne 0))
            {
                $self->{isTip} = 2;
            }
            elsif ($tagname eq 'head')
            {
                $self->{isTip} = 0;
                $self->{urlTips} = '';
            }
        }
        else
        {
            if ($tagname eq 'span')
            {
                if ($attr->{class} =~ m/platformLink--active/)
                {
                    $self->{is} = 'platform';
                }
                elsif ($attr->{class} eq 'verso-jaquette actif')
                {
                    $self->{is} = 'backpic'; # A REVOIR => pour l instant le verso des jaquettes n a plus l air d etre sur le site
                }
                elsif (($attr->{'data-modal'} eq 'image') && $self->{is})
                {
                    $self->{curInfo}->{$self->{is}} = 'http:'.$attr->{'data-selector'};
                    $self->{is} = '';
                }
                elsif ($attr->{class} =~ m/Banner__title/)
                {
                    $self->{is} = 'name';
                }
               elsif ($attr->{class} =~ m/gameHeaderBanner__platformLink/)
               {
                    $self->{isExclu} = 1;
                }
            }
            elsif ($tagname eq 'div')
            {
                if ($attr->{class} eq 'latestImages__inner')
                {
                    $self->{isScreenshot} = 1;
                }
                elsif ($attr->{class} eq 'latestImages__bottom')
                {
                    $self->{isScreenshot} = 0;
                }
                elsif (($self->{isScreenshot}) && (exists $attr->{'data-srcset-background'}))
                {
                    if ($self->{curInfo}->{screenshot1} eq '')
                    {
                        $self->{curInfo}->{screenshot1} = $attr->{'data-srcset-background'};
                        if ($self->{bigPics})
                        {
                           $self->{curInfo}->{screenshot1} =~ s|/medias-sm/|/medias/|gi;
                        }
                    }
                    elsif ($self->{curInfo}->{screenshot2} eq '')
                    {
                        $self->{curInfo}->{screenshot2} = $attr->{'data-srcset-background'};
                        if ($self->{bigPics})
                        {
                           $self->{curInfo}->{screenshot2} =~ s|/medias-sm/|/medias/|gi;
                        }
                    }
                }
                elsif ($attr->{class} =~ m/CharacteristicsDetailed__tr/)
                {
                    $self->{is} = undef;
                }
            }
            elsif ($tagname eq 'text' && $attr->{class} =~ m/gameCharacteristicsMain__gaugeText/)
            {
                $self->{is} = 'ratingpress';
            }
            elsif ($tagname eq 'img')
            {
                if (($attr->{class} =~ m/_coverImage/) && ! ($self->{curInfo}->{boxpic}) && ! ($attr->{src} =~ m|/no-img/|))
                {
                   if ( ($self->{bigPics}) && (exists $attr->{'data-selector'}) )
                   {
                       $self->{curInfo}->{boxpic} = $attr->{'data-selector'};
                   }
                   else
                   {
                       $self->{curInfo}->{boxpic} = $attr->{src};
                   }
                   # Ne fonctionne pas a tous les coups mais pour l instant pas trouve mieux
                   if ($self->{curInfo}->{boxpic} =~ m/-avant-/)
                   {
                      $self->{curInfo}->{backpic} = $self->{curInfo}->{boxpic};
                      $self->{curInfo}->{backpic} =~ s|-avant-|-arriere-|gi;
                   }
                }
            }
            elsif ($tagname eq 'p' && $attr->{class} =~ m/_synopsis/)
            {
                $self->{is} = 'description';
            }
            elsif (($tagname eq 'a') && ($attr->{class} =~ /icon-menu-tips/))
            {
                $self->{urlTips} = "http://www.jeuxvideo.com" . $attr->{href};
            }
        }
    }

    sub end
    {
        my ($self, $tagname) = @_;

        $self->{inside}->{$tagname}--;
        $self->{is} = '' if ($tagname eq 'li');
    }

    sub text
    {
        my ($self, $origtext) = @_;

        if ($self->{parsingList})
        {
            return if !$self->{isGame};
            if ($self->{isPlatform})
            {
                if ($self->{itemsList}[$self->{itemIdx}]->{platform} eq "" )
                {
                    # Enleve le " - " présent en début de chaîne
                    $origtext =~ s/- //;
                    $self->{itemsList}[$self->{itemIdx}]->{platform} = $self->getPlatformName($origtext);
                }
                $self->{isPlatform} = 0;
            }
            elsif ($self->{isName})
            {
                # Enleve les blancs en debut de chaine
                $origtext =~ s/^\s+//;
                # Enleve les blancs en fin de chaine
                $origtext =~ s/\s+$//;
                $self->{itemsList}[$self->{itemIdx}]->{name} = $origtext;
                $self->{isName} = 0;
            }
        }
        elsif ($self->{parsingTips})
        {
            # Enleve les blancs en debut de chaine
            $origtext =~ s/^\s+//;
            # Enleve les blancs en fin de chaine
            #$origtext =~ s/\s+$//;
            # There are problems with some texts if ended blanks are removed
            return if $origtext eq '';

            if ($self->{isTip} eq 1)
            {
                # name must match with getPlatformName list in order to link them
                $origtext =~ s|Gameboy|Game Boy|gi;
                $origtext =~ s|Megadrive|Mega Drive|gi;
                $origtext =~ s|PlayStation Portable|PSP|gi;
                $origtext =~ s|PlayStation Vita|PS Vita|gi;

                if (($origtext =~ /$self->{curInfo}->{platform}/i) || ($origtext =~ /astuce/i) || ($origtext =~ /renseignement/i) || ($origtext =~ /campagne/i))
                {
                    $self->{isTip} = 2;
                }
                else
                {
                    $self->{isTip} = 0;
                }
            }
            elsif ($self->{isTip} eq 4)
            {
                $self->{curInfo}->{secrets} .= $origtext;
            }
            elsif ($self->{isTip} eq 3)
            {
                chomp($origtext);
                if ( ($self->{curInfo}->{secrets}) && ($origtext ne "") )
                {
                   $self->{curInfo}->{secrets} .= "\n\n"
                }
                $self->{curInfo}->{secrets} .= $origtext;
                $self->{isTip} = 4;
            }
        }
        else
        {
            $origtext =~ s/^\s*//;
            $origtext =~ s/[\s\n]*$//;
            return if $origtext eq '';

            if ($self->{is} && $origtext ne 'Haut')
            {
                if ($self->{is} eq 'genre')
                {
                     $self->{curInfo}->{$self->{is}} .= "$origtext,";
                     return;
                }
                else
                {
                    $self->{curInfo}->{$self->{is}} = $origtext;
                }
                if ($self->{is} eq 'players')
                {
                }
                $self->{curInfo}->{$self->{is}} =~ s/Non/1/i if $self->{is} eq 'players';
                $self->{curInfo}->{$self->{is}} = int($self->{curInfo}->{$self->{is}} / 2) if $self->{is} eq 'ratingpress';
                if ($self->{is} eq 'released')
                {
                    $self->{curInfo}->{released} = GCUtils::strToTime($self->{curInfo}->{released},"%e %b %Y", $self->getLang());
                    $self->{curInfo}->{released} = '' if ($self->{curInfo}->{released} =~ /inconnu/);
                }
                $self->{curInfo}->{$self->{is}} = $self->getPlatformName($self->{curInfo}->{$self->{is}}) if $self->{is} eq 'platform';

                # when the developer is also the editor it's only written once:
                # copy it for now, otherwise it should be overwritten afterwards
                $self->{curInfo}->{'developer'} = $origtext if $self->{is} eq 'editor';
                $self->{is} = ''          if $self->{is} ne 'editor';
                # register the next element as 'developer'
                $self->{is} = 'developer' if $self->{is} eq 'editor';

            }
            else
            {
                if ($self->{isTip} eq 1)
                {
                    if (($origtext =~ /wiki/i) || ($origtext =~ /etajv/i))
                    {
                        $self->{isTip} = 2;
                    }
                    else
                    {
                        $self->{isTip} = 0;
                    }
                }
                elsif ($self->{isExclu} eq 1)
                {
                    if ($origtext =~ /Tout support/i)
                    {
                                $self->{curInfo}->{exclusive} = 0;
                    }
                $self->{isExclu} = 0;
                }
                elsif ($origtext eq 'Editeur(s) / Développeur(s)')
                {
                    $self->{is} = 'editor';
                }
                elsif ($origtext eq 'Date de sortie :')
                {
                    $self->{is} = 'released';
                }
                elsif ($origtext eq 'Sortie France')
                {
                    $self->{is} = 'released';
                }
                elsif ($origtext eq 'Nombre maximum de joueurs')
                {
                    $self->{is} = 'players';
                }
                elsif ($origtext =~ /^Genre/)
                {
                    $self->{is} = 'genre';
                }
                elsif ($origtext =~ /^Support/)
                {
                    $self->{is} = undef;
                }
                elsif ($origtext eq 'Haut')
                {
                    # End of info box
                    $self->{is} = '';
                }
            }
        }
    }

    sub getTipsUrl
    {
        my $self = shift;
        return $self->{urlTips};
    }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self  = $class->SUPER::new();
        bless ($self, $class);

        $self->{hasField} = {
            name => 1,
            platform => 1,
            released => 1
        };

        return $self;
    }

    sub preProcess
    {
        my ($self, $html) = @_;

        $self->{isTip} = 0;
        $self->{urlTips} = "";
        $self->{isGame} = 0;
        $self->{isName} = 0;
        $self->{isPlatform} = 0;
        $self->{isExclu} = 0;
        $self->{isScreenshot} = 0;
        $self->{urls} = {};
        $self->{ending} = 0;

        if ($self->{parsingList})
        {
            $html =~ s/<\/?b>//ge;
        }
        elsif ($self->{parsingTips})
        {
            my $found = index($html,"<div class=\"titre-bloc\">");
            if ( $found >= 0 )
            {
                $html = substr($html, $found +length('<div class="titre-bloc">'),length($html)- $found -length('<div class="titre-bloc">'));
                $found = index($html,"<div class=\"bloc-lien-revision\">");
                if ( $found >= 0 )
                {
                    $html = substr($html, 0, $found);
                }
            }
            $html =~ s|<a href="(.+?)">|$self->RecupTips("http://www.jeuxvideo.com" . $1)|ge;
            $html =~ s|Chargement du lecteur vid(.)o...|<p>"Une video est disponible"</p>|gi;
            $html =~ s|Partager sur :||gi;
            $html =~ s|<img src="//www.jeuxvideo.com/img/keys/(.+?).gif" alt="(.+?)" />|$2|gi;
        }
        else
        {
            $self->{is} = '';
            $self->{curInfo}->{exclusive} = 1;
        }
        return $html;
    }

    sub RecupTips
    {
        my ($self, $url) = @_;

        my $html = $self->loadPage($url);

        my $found = index($html,"<h2 class=\"titre-bloc\">");
        if ( $found >= 0 )
        {
            $html = substr($html, $found +length('<h2 class="titre-bloc">'),length($html)- $found -length('<h2 class="titre-bloc">'));
            $found = index($html,"<div class=\"bloc-lien-revision\">");
            if ( $found >= 0 )
            {
                $html = substr($html, 0, $found);
            }
        }
        return "<tpfdebuttpf>" . $html . "<tpffintpf>";
    }

    sub getSearchUrl
    {
        my ($self, $word) = @_;
        $word =~ s/\+/ /g;
        return 'http://www.jeuxvideo.com/rechercher.php?q='.$word.'&m=9';
    }

    sub getItemUrl
    {
        my ($self, $url) = @_;

        return $url if $url;
        return 'http://www.jeuxvideo.com/';
    }

    sub getName
    {
        return 'jeuxvideo.com';
    }

    sub getAuthor
    {
        return 'Tian & TPF';
    }

    sub getLang
    {
        return 'FR';
    }

    sub isPreferred
    {
        return 1;
    }
}

1;
