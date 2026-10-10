package GCPlugins::GCfilms::GCJavLibrary;

use strict;
use utf8;
use GCPlugins::GCfilms::GCfilmsCommon;

{
    package GCPlugins::GCfilms::GCPluginJavLibrary;

    use base qw(GCPlugins::GCfilms::GCfilmsPluginsBase);
    use File::Basename qw(dirname);
    use File::Spec;
    use File::Path qw(make_path);
    use File::Copy qw(copy);
    use GCUtils;
    use JSON::PP qw(decode_json);
    use URI::Escape qw(uri_escape);

    my $DEFAULT_PORT = 53118;
    my $DEFAULT_WAIT = 90;

    sub _readConfig
    {
        my ($self) = @_;
        my %cfg = (port => $DEFAULT_PORT, wait_seconds => $DEFAULT_WAIT);
        my $path = File::Spec->catfile(dirname(__FILE__), 'GCJavLibrary.conf');
        if (open(my $fh, '<', $path))
        {
            while (my $line = <$fh>)
            {
                $line =~ s/^\x{FEFF}//;
                $line =~ s/[\r\n]+$//;
                next if $line =~ /^\s*(?:#|;|$)/;
                next unless $line =~ /^\s*([A-Za-z_]+)\s*=\s*(.*?)\s*$/;
                my ($k,$v) = (lc($1),$2);
                $cfg{$k} = $v if exists $cfg{$k};
            }
            close $fh;
        }
        $cfg{port} = int($cfg{port}) || $DEFAULT_PORT;
        $cfg{wait_seconds} = int($cfg{wait_seconds}) || $DEFAULT_WAIT;
        $self->{javCfg} = \%cfg;
    }

    sub _bridgeBase
    {
        my ($self) = @_;
        return 'http://127.0.0.1:'.($self->{javCfg}->{port} || $DEFAULT_PORT);
    }

    sub _trim
    {
        my ($s) = @_;
        $s = '' unless defined $s;
        $s =~ s/&nbsp;/ /gi;
        $s =~ s/&#160;/ /g;
        $s =~ s/&amp;/&/g;
        $s =~ s/&quot;/"/g;
        $s =~ s/&#39;/'/g;
        $s =~ s/^\s+|\s+$//g;
        $s =~ s/\s+/ /g;
        return $s;
    }

    sub _normCode
    {
        my ($s) = @_;
        $s = _trim($s);
        $s =~ tr/a-z/A-Z/;
        $s =~ s/[\x{2010}-\x{2015}\x{2212}]/-/g;
        $s =~ s/\s+//g;
        return $s;
    }

    sub _debug
    {
        my ($self,$msg) = @_;
        eval {
            my $base = $ENV{LOCALAPPDATA} || File::Spec->tmpdir();
            my $dir = File::Spec->catdir($base, 'JavKT9');
            make_path($dir) unless -d $dir;
            my $p = File::Spec->catfile($dir, 'JavKT9-plugin.log');
            open(my $fh, '>>', $p) or return;
            my @t = localtime();
            printf $fh "%04d-%02d-%02d %02d:%02d:%02d %s\n",
                $t[5]+1900,$t[4]+1,$t[3],$t[2],$t[1],$t[0],$msg;
            close $fh;
        };
    }

    sub _appRoot
    {
        my $d = dirname(__FILE__);
        for (1..4) { $d = dirname($d); }
        return $d;
    }

    sub _bridgeInterpreter
    {
        my ($self) = @_;
        my $root = $self->_appRoot();
        my @candidates = (
            File::Spec->catfile($root, 'bin', 'wperl.exe'),
            File::Spec->catfile($root, 'bin', 'perl.exe'),
        );
        for my $p (@candidates) { return $p if -f $p; }
        return '';
    }

    sub _bridgeGet
    {
        my ($self,$path) = @_;
        my $url = $self->_bridgeBase.$path;
        my $res = eval { $self->{ua}->get($url) };
        return '' unless $res && $res->is_success;
        return $res->decoded_content;
    }

    sub _ensureBridge
    {
        my ($self) = @_;
        return 1 if $self->_bridgeGet('/ping') eq 'OK';

        my $script = File::Spec->catfile(dirname(__FILE__), 'GCJavLibraryBridge.pl');
        if (!-f $script)
        {
            $self->_debug("bridge script missing: $script");
            return 0;
        }

        $self->_debug("starting bridge: $script");
        if ($^O eq 'MSWin32')
        {
            my $interp = $self->_bridgeInterpreter();
            $self->_debug("perl current=[$^X]");
            if (!$interp)
            {
                $self->_debug("bridge interpreter missing under ".$self->_appRoot()."\\bin");
                return 0;
            }
            $self->_debug("bridge interpreter: $interp");
            my $rc = eval { system(1, $interp, $script); };
            $self->_debug("bridge spawn rc=".(defined($rc) ? $rc : 'undef')." err=".($@ || $! || ''));
        }
        else
        {
            my $pid = fork();
            if (defined $pid && $pid == 0)
            {
                exec($^X, $script);
                exit 1;
            }
        }

        for (1..20)
        {
            select(undef, undef, undef, 0.25);
            return 1 if $self->_bridgeGet('/ping') eq 'OK';
        }
        $self->_debug('bridge did not answer /ping');
        return 0;
    }

    sub _appendList
    {
        my ($self,$field,$value) = @_;
        $value = _trim($value);
        return 0 if $value eq '';
        my @cur = ();
        @cur = split(/\s*,\s*/, $self->{curInfo}->{$field})
            if defined $self->{curInfo}->{$field} && $self->{curInfo}->{$field} ne '';
        for my $x (@cur)
        {
            return 0 if lc($x) eq lc($value);
        }
        $self->{curInfo}->{$field} .= ',' if $self->{curInfo}->{$field};
        $self->{curInfo}->{$field} .= $value;
        return 1;
    }

    sub start
    {
        my ($self,$tagname,$attr,$attrseq,$origtext) = @_;
        $self->{inside}->{$tagname}++;
        my $class = $attr->{class} || '';
        my $id = $attr->{id} || '';

        if ($self->{parsingList})
        {
            if ($tagname eq 'div' && $class =~ /(?:^|\s)gcjav-result(?:\s|$)/)
            {
                $self->{itemIdx}++;
                $self->{itemsList}[$self->{itemIdx}] = {};
                $self->{insideResult} = $self->{inside}->{div};
            }
            elsif ($self->{insideResult} && $tagname eq 'a' && $class =~ /(?:^|\s)gcjav-link(?:\s|$)/)
            {
                $self->{itemsList}[$self->{itemIdx}]->{url} = $attr->{href} || '';
            }
            elsif ($self->{insideResult} && $tagname eq 'span' && $class =~ /(?:^|\s)gcjav-code(?:\s|$)/)
            {
                $self->{insideResultCode} = $self->{inside}->{span};
            }
            elsif ($self->{insideResult} && $tagname eq 'span' && $class =~ /(?:^|\s)gcjav-title(?:\s|$)/)
            {
                $self->{insideResultTitle} = $self->{inside}->{span};
            }
            return;
        }

        if ($tagname eq 'link' && ($attr->{rel} || '') =~ /canonical/i)
        {
            $self->{curInfo}->{webPage} = $attr->{href} || '';
        }
        elsif ($tagname eq 'img' && $id eq 'video_jacket_img')
        {
            my $src = $attr->{src} || '';
            $src = 'https:'.$src if $src =~ m{^//};
            $src = 'https://www.javlibrary.com'.$src if $src =~ m{^/};
            $self->{curInfo}->{image} = $src;
            $self->_debug("parser image src=$src");
        }
        elsif ($tagname eq 'div' && $id eq 'video_title')
        {
            $self->{insideVideoTitle} = $self->{inside}->{div};
        }
        elsif ($tagname eq 'h3' && $self->{insideVideoTitle})
        {
            $self->{insideTitle} = $self->{inside}->{h3};
        }
        elsif ($tagname eq 'div' && $id =~ /^(video_id|video_date|video_length|video_director)$/)
        {
            $self->{section} = $id;
            $self->{sectionDepth} = $self->{inside}->{div};
            $self->{sectionText} = '';
        }
        elsif ($self->{section} && $class =~ /(?:^|\s)text(?:\s|$)/)
        {
            $self->{insideSectionText} = $self->{inside}->{$tagname};
            $self->{sectionTextTag} = $tagname;
        }
        elsif ($tagname eq 'div' && $id eq 'video_genres')
        {
            $self->{insideGenres} = $self->{inside}->{div};
        }
        elsif ($self->{insideGenres} && $tagname eq 'a')
        {
            $self->{insideGenre} = $self->{inside}->{a};
            $self->{genreText} = '';
        }
        elsif ($tagname eq 'div' && $id eq 'video_cast')
        {
            $self->{insideCast} = $self->{inside}->{div};
            $self->_debug('parser video_cast found');
        }
        elsif ($self->{insideCast} && $tagname eq 'a')
        {
            $self->{insideActor} = $self->{inside}->{a};
            $self->{actorText} = '';
            $self->{actorHref} = $attr->{href} || '';
        }
    }

    sub text
    {
        my ($self,$orig) = @_;
        my $text = _trim($orig);
        return if $text eq '';

        if ($self->{parsingList})
        {
            if ($self->{insideResultCode})
            {
                $self->{itemsList}[$self->{itemIdx}]->{original} = $text;
                $self->{itemsList}[$self->{itemIdx}]->{title} ||= $text;
            }
            elsif ($self->{insideResultTitle})
            {
                $self->{itemsList}[$self->{itemIdx}]->{title} = $text;
            }
            return;
        }

        if ($self->{insideTitle})
        {
            # GCJav: JavLibrary's visible movie title belongs in "original".
            # The main GCstar title remains the product code for searching,
            # sorting and bridge lookups.
            $self->{curInfo}->{original} = $text if $text ne '';
        }
        if ($self->{insideSectionText} && $self->{section})
        {
            $self->{sectionText} .= ' ' if $self->{sectionText};
            $self->{sectionText} .= $text;
        }
        if ($self->{insideGenre})
        {
            $self->{genreText} .= ' ' if $self->{genreText};
            $self->{genreText} .= $text;
        }
        if ($self->{insideActor})
        {
            $self->{actorText} .= ' ' if $self->{actorText};
            $self->{actorText} .= $text;
        }
    }

    sub _finishSection
    {
        my ($self) = @_;
        my $s = $self->{section} || '';
        my $text = _trim($self->{sectionText});
        if ($s eq 'video_id')
        {
            my $code = _normCode($text);

            # Main title/search key = product code.
            $self->{curInfo}->{title} = $code;

            # If JavLibrary did not provide a visible title, fall back to code.
            $self->{curInfo}->{original} ||= $code;

            # GCJav: infer the series/studio prefix from the product code.
            # GVH-110 -> GVH, START-644 -> START, FC2-PPV-1234567 -> FC2-PPV.
            my $serie = $code;
            $serie =~ s/-[0-9]+[A-Z]*$//i;
            $self->{curInfo}->{serie} = $serie if $serie ne '' && $serie ne $code;
        }
        elsif ($s eq 'video_date')
        {
            if ($text =~ /^\d{4}-\d{2}-\d{2}$/)
            {
                my $date = eval { GCDates::strToTime($text, '%Y-%m-%d', 'EN') };
                $self->{curInfo}->{date} = $date || $text;
            }
            else
            {
                $self->{curInfo}->{date} = $text;
            }
        }
        elsif ($s eq 'video_length')
        {
            $self->{curInfo}->{time} = $1 if $text =~ /(\d+)/;
        }
        elsif ($s eq 'video_director')
        {
            # JavKT9 0.7.11: an empty JavLibrary director is not a parser error.
            # Make the absence explicit in the scalar field consumed by GCstar.
            $self->{curInfo}->{director} = ($text eq '' || $text =~ /^-+$/)
                ? 'No publicado' : $text;
        }
        $self->{section} = '';
        $self->{sectionText} = '';
        $self->{sectionDepth} = 0;
        $self->{insideSectionText} = 0;
    }

    sub end
    {
        my ($self,$tagname) = @_;
        my $depth = $self->{inside}->{$tagname} || 0;

        if ($self->{parsingList})
        {
            $self->{insideResultCode} = 0 if $tagname eq 'span' && $self->{insideResultCode} && $depth == $self->{insideResultCode};
            $self->{insideResultTitle} = 0 if $tagname eq 'span' && $self->{insideResultTitle} && $depth == $self->{insideResultTitle};
            $self->{insideResult} = 0 if $tagname eq 'div' && $self->{insideResult} && $depth == $self->{insideResult};
            $self->{inside}->{$tagname}-- if $self->{inside}->{$tagname};
            return;
        }

        if ($tagname eq 'a' && $self->{insideGenre} && $depth == $self->{insideGenre})
        {
            $self->_appendList('genre',$self->{genreText});
            $self->{insideGenre}=0;
            $self->{genreText}='';
        }
        if ($tagname eq 'a' && $self->{insideActor} && $depth == $self->{insideActor})
        {
            my $name = _trim($self->{actorText});
            if ($name ne '')
            {
                my $added = $self->_appendList('actors',$name);
                if ($added) {
                    my $href = _trim($self->{actorHref} || '');
                    # JavKT9 0.7.13: JavLibrary may publish star links as
                    # vl_star.php?s=..., /en/vl_star.php?s=..., //host/... or absolute.
                    # Store one canonical absolute URL in every case.
                    if ($href =~ m{^//})
                    {
                        $href = 'https:'.$href;
                    }
                    elsif ($href =~ m{^/})
                    {
                        $href = 'https://www.javlibrary.com'.$href;
                    }
                    elsif ($href ne '' && $href !~ m{^[A-Za-z][A-Za-z0-9+.-]*://})
                    {
                        $href =~ s{^\./}{};
                        $href = 'https://www.javlibrary.com/en/'.$href;
                    }
                    $self->_appendList('modelLinks',$href) if $href;
                    $self->_debug("parser actor name=$name href=$href");
                }
            }
            $self->{insideActor}=0;
            $self->{actorText}='';
            $self->{actorHref}='';
        }
        if ($self->{insideSectionText} && $tagname eq ($self->{sectionTextTag} || '') && $depth == $self->{insideSectionText})
        {
            $self->{insideSectionText}=0;
        }
        if ($tagname eq 'div' && $self->{sectionDepth} && $depth == $self->{sectionDepth})
        {
            $self->_finishSection();
        }
        $self->{insideTitle}=0 if $tagname eq 'h3' && $self->{insideTitle} && $depth == $self->{insideTitle};
        $self->{insideVideoTitle}=0 if $tagname eq 'div' && $self->{insideVideoTitle} && $depth == $self->{insideVideoTitle};
        $self->{insideGenres}=0 if $tagname eq 'div' && $self->{insideGenres} && $depth == $self->{insideGenres};
        if ($tagname eq 'div' && $self->{insideCast} && $depth == $self->{insideCast})
        {
            # JavKT9 0.7.11: if JavLibrary publishes an empty Cast block, put an
            # explicit UI value in both list fields.  Real actors/links always win.
            if (!defined($self->{curInfo}->{actors}) || $self->{curInfo}->{actors} eq '')
            {
                $self->{curInfo}->{actors} = 'No publicado en JavLibrary';
            }
            if (!defined($self->{curInfo}->{modelLinks}) || $self->{curInfo}->{modelLinks} eq '')
            {
                $self->{curInfo}->{modelLinks} = 'No publicados';
            }
            $self->{insideCast}=0;
        }

        $self->{inside}->{$tagname}-- if $self->{inside}->{$tagname};
    }

    sub preProcess
    {
        my ($self,$html) = @_;

        # JavKT9 0.7.9: make genuinely unpublished metadata explicit.
        # This does not invent a person/director; it only labels an empty
        # JavLibrary field so the UI does not look broken.
        if (defined $html)
        {
            $html =~ s{(<div\b[^>]*\bid=["']video_director["'][^>]*>.*?<td\b[^>]*\bclass=["']text["'][^>]*>)\s*(</td>)}{$1No publicado$2}is;
            $html =~ s{(<div\b[^>]*\bid=["']video_cast["'][^>]*>.*?<td\b[^>]*\bclass=["']text["'][^>]*>)\s*(</td>)}{$1<a class="javkt9-unpublished">No publicado en JavLibrary</a>$2}is;
        }

        # JavKT9 0.7.6 diagnostics: preserve exactly the HTML handed to the
        # parser. One file is overwritten on every item, so it cannot grow
        # into a per-movie archive.
        eval {
            my $base = $ENV{LOCALAPPDATA} || File::Spec->tmpdir();
            my $dir = File::Spec->catdir($base, 'JavKT9', 'Diagnostics');
            make_path($dir) unless -d $dir;
            my $p = File::Spec->catfile($dir, 'last-parser-input.html');
            open(my $fh, '>:raw', $p) or die $!;
            print $fh (defined($html) ? $html : '');
            close $fh;
            $self->_debug("parser input saved path=$p bytes=".length($html || ''));
        };
        $self->{insideResult}=0;
        $self->{insideResultCode}=0;
        $self->{insideResultTitle}=0;
        $self->{insideVideoTitle}=0;
        $self->{insideTitle}=0;
        $self->{section}='';
        $self->{sectionDepth}=0;
        $self->{sectionText}='';
        $self->{insideSectionText}=0;
        $self->{insideGenres}=0;
        $self->{insideGenre}=0;
        $self->{insideCast}=0;
        $self->{insideActor}=0;
        return $html;
    }

    sub getSearchUrl
    {
        my ($self,$word) = @_;
        my $code = _normCode($word);
        $self->{searchCode} = $code;
        $self->_ensureBridge();
        my $url = $self->_bridgeBase.'/search?code='.uri_escape($code);
        $self->_debug("search code=$code url=$url");
        return $url;
    }

    sub getItemUrl
    {
        my ($self,$url) = @_;
        return $url if defined($url) && $url =~ m{^https?://127\.0\.0\.1:};

        if (defined($url) && $url =~ /^bridge-code:(.*)$/)
        {
            my $code = _normCode($1);
            return $self->_bridgeBase.'/item?token=missing' unless $self->_ensureBridge();

            my $begin = $self->_bridgeGet('/begin?code='.uri_escape($code));
            my $obj = eval { decode_json($begin) } || {};
            my $token = $obj->{token} || '';
            if (!$token)
            {
                $self->_debug("begin failed for code=$code body=$begin");
                return $self->_bridgeBase.'/item?token=missing';
            }

            my $wait = $self->{javCfg}->{wait_seconds} || $DEFAULT_WAIT;
            $self->_debug("waiting browser token=$token code=$code max=${wait}s");
            for (1..($wait*2))
            {
                my $ready = $self->_bridgeGet('/ready?token='.uri_escape($token));
                my $r = eval { decode_json($ready) } || {};
                if ($r->{ready})
                {
                    $self->_debug("browser data ready token=$token");
                    return $self->_bridgeBase.'/item?token='.uri_escape($token);
                }
                select(undef, undef, undef, 0.5);
            }
            $self->_debug("timeout waiting browser token=$token code=$code");
            return $self->_bridgeBase.'/item?token='.uri_escape($token);
        }

        return $self->_bridgeBase.'/';
    }

    sub getName { return 'JavLibrary (WebView2)'; }
    sub getAuthor { return 'GCstar / GCJav WebView2 integration'; }
    sub getLang { return 'EN'; }
    sub getCharset { return 'UTF-8'; }

    sub new
    {
        my $proto = shift;
        my $class = ref($proto) || $proto;
        my $self = $class->SUPER::new();
        bless($self,$class);
        $self->_readConfig();
        $self->{hasField} = {
            title => 1,
            original => 1,
            image => 1,
            date => 1,
            director => 1,
            time => 1,
            genre => 1,
            actors => 1,
            modelLinks => 1,
            serie => 1,
            webPage => 1,
        };
        $self->_debug('plugin instantiated');
        return $self;
    }
}

1;
