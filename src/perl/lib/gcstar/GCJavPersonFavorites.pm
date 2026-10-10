package GCJavPersonFavorites;
use strict;
use warnings;
use utf8;
use JSON::PP ();
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec;
use Fcntl qw(:flock);

# Standalone persistence layer. Not yet connected to the GTK interface.
sub new {
    my ($class, %args) = @_;
    # Default to user-owned storage, never the Program Files installation tree.
    my $root = $ENV{LOCALAPPDATA} || $ENV{APPDATA};
    my $file = $args{file};
    if (!defined $file || !length $file) {
        die 'LOCALAPPDATA/APPDATA is required unless file is provided'
            unless defined $root && length $root;
        $file = File::Spec->catfile($root, 'JavKT9-081-RC1-Publica-Publica', 'person-favorites.json');
    }
    return bless {file => $file}, $class;
}
sub _key {
    my ($name) = @_;
    return '' unless defined $name;
    $name =~ s/^\s+|\s+$//g;
    $name =~ s/\s+/ /g;
    return lc $name;
}
sub _kind {
    my ($kind) = @_;
    die 'invalid person kind' unless defined($kind) && ($kind eq 'actors' || $kind eq 'directors');
    return $kind;
}
sub _read {
    my ($self) = @_;
    my $file = $self->{file};
    return {version => 1, actors => {}, directors => {}} unless -e $file;
    open my $fh, '<:raw', $file or die "Cannot open favorites: $!";
    local $/; my $raw = <$fh>; close $fh;
    my $data = JSON::PP->new->utf8->decode($raw);
    die 'Invalid favorites file' unless ref($data) eq 'HASH' && $data->{version} == 1
        && ref($data->{actors}) eq 'HASH' && ref($data->{directors}) eq 'HASH';
    return $data;
}
sub _locked {
    my ($self, $cb) = @_;
    my $dir = dirname($self->{file}); make_path($dir) unless -d $dir;
    open my $lock, '>>', $self->{file}.'.lock' or die "Cannot lock favorites: $!";
    flock($lock, LOCK_EX) or die "Cannot acquire favorites lock: $!";
    my $result = $cb->();
    close $lock;
    return $result;
}
sub list {
    my ($self, $kind) = @_; _kind($kind);
    return $self->_locked(sub { my $d = $self->_read; return [sort {lc($a) cmp lc($b)} values %{$d->{$kind}}] });
}
sub is_favorite {
    my ($self, $kind, $name) = @_; _kind($kind);
    my $key = _key($name); return 0 unless length $key;
    return $self->_locked(sub {my $d = $self->_read; return exists $d->{$kind}{$key} ? 1 : 0});
}
sub set_favorite {
    my ($self, $kind, $name, $enabled) = @_; _kind($kind);
    my $key = _key($name); die 'empty person name' unless length $key;
    return $self->_locked(sub {
        my $d = $self->_read;
        if ($enabled) {my $display = $name; $display =~ s/^\s+|\s+$//g; $display =~ s/\s+/ /g; $d->{$kind}{$key} = $display}
        else {delete $d->{$kind}{$key}}
        my $file = $self->{file}; my $tmp = $file.'.tmp.'.$$;
        open my $fh, '>:raw', $tmp or die "Cannot write favorites: $!";
        print {$fh} JSON::PP->new->utf8->canonical->pretty->encode($d) or die "Cannot write favorites: $!";
        close $fh or die "Cannot close favorites: $!";
        rename($tmp, $file) or die "Cannot replace favorites: $!";
        return $enabled ? 1 : 0;
    });
}
1;
