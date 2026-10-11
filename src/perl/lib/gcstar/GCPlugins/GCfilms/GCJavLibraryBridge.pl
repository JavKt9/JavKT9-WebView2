#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use IO::Socket::INET;
use URI::Escape qw(uri_unescape);
use File::Basename qw(dirname);
use File::Spec;
use File::Path qw(make_path);
use POSIX qw(strftime);
use LWP::UserAgent;

my $VERSION = '2.3.1-webview2-lifecycle';
my $session_token = $ENV{JAVKT9_BRIDGE_SESSION} || '';
my $shutdown_requested = 0;
my %cfg = (port => 53118, wait_seconds => 90);
my $conf = File::Spec->catfile(dirname(__FILE__), 'GCJavLibrary.conf');
if (open(my $fh, '<:encoding(UTF-8)', $conf)) {
    while (my $line = <$fh>) {
        $line =~ s/^\x{FEFF}//; $line =~ s/[\r\n]+$//;
        next if $line =~ /^\s*(?:#|;|$)/;
        next unless $line =~ /^\s*([A-Za-z_]+)\s*=\s*(.*?)\s*$/;
        my ($k,$v)=(lc($1),$2); $cfg{$k}=$v if exists $cfg{$k};
    }
    close $fh;
}
$cfg{port}=int($cfg{port})||53118;
$cfg{wait_seconds}=int($cfg{wait_seconds})||90;

my $local = $ENV{LOCALAPPDATA} || File::Spec->tmpdir();
my $logdir = File::Spec->catdir($local,'JavKT9');
make_path($logdir) unless -d $logdir;
my $logfile = File::Spec->catfile($logdir,'JavKT9-webview2-bridge.log');
my %cache;

sub logmsg { my($m)=@_; if(open(my $f,'>>:encoding(UTF-8)',$logfile)){ print $f strftime('%Y-%m-%d %H:%M:%S',localtime)." $m\n"; close $f; } }
sub norm_code { my($s)=@_; $s='' unless defined $s; $s=uc($s); $s =~ s/[\x{2010}-\x{2015}\x{2212}]/-/g; $s =~ s/\s+//g; $s =~ s/[^A-Z0-9_-]//g; return $s; }
sub esc { my($s)=@_; $s='' unless defined $s; $s =~ s/&/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s =~ s/"/&quot;/g; return $s; }
sub query { my($q)=@_; my %o; for(split /&/,($q//'') ){ my($k,$v)=split /=/,$_,2; next unless defined $k; $o{uri_unescape($k)}=uri_unescape($v//''); } return \%o; }
sub response { my($s,$code,$status,$type,$body)=@_; $body='' unless defined $body; my $b=$body; utf8::encode($b) if utf8::is_utf8($b); print $s "HTTP/1.1 $code $status\r\nContent-Type: $type\r\nContent-Length: ".length($b)."\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n"; print $s $b; }
sub search_html { my($c)=@_; $c=esc($c); return qq{<!doctype html><html><body><div class="gcjav-result"><a class="gcjav-link" href="bridge-code:$c"><span class="gcjav-code">$c</span><span class="gcjav-title">$c</span></a></div></body></html>}; }

sub app_root {
    my $d=dirname(__FILE__);
    for(1..4){ $d=dirname($d); }
    return $d;
}
sub host_exe {
    return $ENV{JAVKT9_WEBVIEW2_EXE} if $ENV{JAVKT9_WEBVIEW2_EXE} && -f $ENV{JAVKT9_WEBVIEW2_EXE};
    my $root=app_root();
    my @c=(
        File::Spec->catfile($root,'bin','WebView2Host','JavKT9WebView2.exe'),
        File::Spec->catfile($root,'bin','JavKT9WebView2.exe'),
    );
    for(@c){ return $_ if -f $_; }
    return '';
}
# The original .NET WebView2 host resolves LocalApplicationData via
# Environment.GetFolderPath(), not the isolated LOCALAPPDATA environment.
# Read only the host capture from its real Windows LocalAppData directory.
# Other Bridge caches and logs remain under the isolated profile.
my $capture_local = $ENV{JAVKT9_WEBVIEW2_CAPTURE_BASE} || $local;
sub capture_path { my($code)=@_; return File::Spec->catfile($capture_local,'JavKT9','WebView2Capture',"$code.html"); }
sub cover_dir {
    my $d=File::Spec->catdir($local,'JavKT9','CoverCache');
    make_path($d) unless -d $d;
    return $d;
}
sub html_unescape_url {
    my($u)=@_; $u='' unless defined $u;
    $u =~ s/&amp;/&/g; $u =~ s/&quot;/"/g; $u =~ s/&#39;/'/g;
    $u='https:'.$u if $u =~ m{^//};
    $u='https://www.javlibrary.com'.$u if $u =~ m{^/};
    return $u;
}
sub acquire_cover {
    my($code,$html)=@_;
    my @urls;
    push @urls, html_unescape_url($1) if $html =~ m{<img\b[^>]*\bid=["']video_jacket_img["'][^>]*\bsrc=["']([^"']+)}is;
    push @urls, html_unescape_url($1) if $html =~ m{<link\b[^>]*\brel=["'][^"']*image_src[^"']*["'][^>]*\bhref=["']([^"']+)}is;
    push @urls, html_unescape_url($1) if $html =~ m{<meta\b[^>]*\bproperty=["']og:image["'][^>]*\bcontent=["']([^"']+)}is;
    my %seen; @urls=grep { $_ ne '' && !$seen{$_}++ } @urls;
    my $ua=LWP::UserAgent->new(timeout=>12, agent=>'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/153 Safari/537.36');
    for my $u (@urls) {
        logmsg("cover try code=$code url=$u");
        my $res=eval { $ua->get($u, 'Referer'=>'https://www.javlibrary.com/', 'Accept'=>'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8') };
        if (!$res) { logmsg("cover request exception code=$code url=$u err=".($@||'unknown')); next; }
        if (!$res->is_success) { logmsg("cover HTTP failure code=$code status=".$res->status_line." url=$u"); next; }
        my $bytes=$res->content || '';
        if (length($bytes)<1000) { logmsg("cover too small code=$code bytes=".length($bytes)." url=$u"); next; }
        my $ct=lc($res->header('Content-Type')||'image/jpeg');
        $ct='image/jpeg' unless $ct =~ m{^image/};
        logmsg("cover ready code=$code bytes=".length($bytes)." type=$ct");
        return ($bytes,$ct);
    }
    logmsg("cover unavailable code=$code");
    return ('','');
}
sub inject_bridge_cover {
    my($html,$token)=@_; return $html unless $token;
    my $url='http://127.0.0.1:53118/cover?token='.$token;
    $html =~ s{(<img\b[^>]*\bid=["']video_jacket_img["'][^>]*\bsrc=["'])[^"']*(["'])}{$1$url$2}is;
    logmsg("cover injected bridge_url=$url");
    return $html;
}
sub acquire_html {
    my($code,$token)=@_;
    my $exe=host_exe();
    if(!$exe){ logmsg("ERROR host executable not found root=".app_root()); return ''; }
    my $cap=capture_path($code);
    unlink $cap if -f $cap;
    logmsg("launch host code=$code exe=$exe");
    my $rc=system($exe,$code,'--hidden');
    my $exit=($rc == -1) ? -1 : ($rc >> 8);
    logmsg("host finished code=$code exit=$exit");
    if($exit != 0 || !-f $cap){ logmsg("ERROR capture missing code=$code path=$cap"); return ''; }
    open(my $fh,'<:raw',$cap) or do { logmsg("ERROR cannot read capture $cap: $!"); return ''; };
    local $/; my $html=<$fh>; close $fh;
    unlink $cap; # Important: no accumulation of one HTML file per movie.
    my ($cover_bytes,$cover_type)=acquire_cover($code,$html||'');
    $html=inject_bridge_cover($html,$token) if $cover_bytes ne '';
    logmsg("capture consumed+deleted code=$code bytes=".length($html||'')." cover_bytes=".length($cover_bytes||''));
    return ($html || '', $cover_bytes || '', $cover_type || 'image/jpeg');
}

my $server=IO::Socket::INET->new(LocalAddr=>'127.0.0.1',LocalPort=>$cfg{port},Proto=>'tcp',Listen=>8,ReuseAddr=>1) or die "Cannot listen 127.0.0.1:$cfg{port}: $!\n";
logmsg("bridge $VERSION listening 127.0.0.1:$cfg{port}");
while(my $client=$server->accept()){
    $client->autoflush(1);
    my $line=<$client>; if(!$line){ close $client; next; }
    $line =~ s/[\r\n]+$//; my($method,$target)=split /\s+/,$line,3;
    while(my $h=<$client>){ last if $h =~ /^\r?\n$/; }
    my($path,$qs)=split /\?/,$target||'/',2; my $q=query($qs);
    if($method eq 'GET' && $path eq '/shutdown'){
        my $provided = $q->{key} // '';
        if (length($session_token) >= 32 && $provided eq $session_token) {
            response($client,200,'OK','text/plain; charset=UTF-8','OK');
            $shutdown_requested = 1;
            logmsg('shutdown requested by matching launcher session');
        } else { response($client,403,'Forbidden','text/plain; charset=UTF-8','Forbidden'); }
    }
    elsif($method eq 'GET' && $path eq '/ping'){ response($client,200,'OK','text/plain; charset=UTF-8','OK'); }
    elsif($method eq 'GET' && $path eq '/search'){ my $c=norm_code($q->{code}); response($client,200,'OK','text/html; charset=UTF-8',search_html($c)); }
    elsif($method eq 'GET' && $path eq '/begin'){
        my $c=norm_code($q->{code}); my $token=time().'-'.int(rand(1000000000));
        my ($html,$cover_bytes,$cover_type)=acquire_html($c,$token);
        $cache{$token}={html=>$html,cover=>$cover_bytes,cover_type=>$cover_type,ts=>time()} if $html ne '';
        my $json='{"ok":'.($html ne ''?'true':'false').',"token":"'.esc($token).'","code":"'.esc($c).'"}';
        response($client,200,'OK','application/json; charset=UTF-8',$json);
    }
    elsif($method eq 'GET' && $path eq '/ready'){ my $t=$q->{token}//''; response($client,200,'OK','application/json; charset=UTF-8','{"ready":'.(exists $cache{$t}?'true':'false').'}'); }
    elsif($method eq 'GET' && $path eq '/item'){ my $t=$q->{token}//''; my $html=exists $cache{$t}?$cache{$t}->{html}:''; $html='<!doctype html><html><body><div id="gcjav_error">No WebView2 data.</div></body></html>' if $html eq ''; response($client,200,'OK','text/html; charset=UTF-8',$html); $cache{$t}->{item_served}=time() if exists $cache{$t}; }
    elsif($method eq 'GET' && $path eq '/cover'){ my $t=$q->{token}//''; if(exists $cache{$t} && length($cache{$t}->{cover}||'')>1000){ my $bytes=$cache{$t}->{cover}; my $ct=$cache{$t}->{cover_type}||'image/jpeg'; response($client,200,'OK',$ct,$bytes); logmsg("cover served token=$t bytes=".length($bytes)); delete $cache{$t}; } else { response($client,404,'Not Found','text/plain; charset=UTF-8','No cover'); logmsg("cover missing token=$t"); } }
    elsif($method eq 'GET' && $path eq '/version'){ response($client,200,'OK','application/json; charset=UTF-8','{"bridge_version":"'.$VERSION.'"}'); }
    else { response($client,404,'Not Found','text/plain; charset=UTF-8','Not Found'); }
    close $client;
    last if $shutdown_requested;
    for my $t(keys %cache){ delete $cache{$t} if time()-($cache{$t}->{ts}||0)>300; }
}
