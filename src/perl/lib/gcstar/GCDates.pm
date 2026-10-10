package GCDates;

use strict;
use warnings;
use Time::Piece;

my $dateFormat = '%d/%m/%Y';

sub setDateFormat {
    my ($format) = @_;
    $dateFormat = $format if defined $format && $format ne '';
    return $dateFormat;
}

sub timeToStr {
    my ($date, $format) = @_;
    return '' if !defined $date;
    $format ||= $dateFormat;
    my @a = split('/', $date);
    return $date if @a != 3;
    my ($d,$m,$y) = @a;
    my $t;
    eval { $t = Time::Piece->strptime(sprintf('%02d/%02d/%04d',$d,$m,$y), '%d/%m/%Y'); };
    return $date if $@ || !$t;
    return $t->strftime($format);
}

sub strToTime {
    my ($date, $format, $lang) = @_;
    return '' if !defined $date;
    return $date if !defined $format || $format eq '';
    my $out = $date;
    eval {
        local $SIG{__WARN__} = sub { die @_ };
        my $t = Time::Piece->strptime($date, $format);
        $out = $t->strftime('%d/%m/%Y');
    };
    return $out;
}

sub numericDate {
    my ($date) = @_;
    return 0 if !defined $date || $date eq '';
    if ($date =~ m{^\s*(\d{1,2})/(\d{1,2})/(\d{4})\s*$}) {
        return sprintf('%04d%02d%02d', $3, $2, $1);
    }
    if ($date =~ m{^\s*(\d{4})-(\d{1,2})-(\d{1,2})\s*$}) {
        return sprintf('%04d%02d%02d', $1, $2, $3);
    }
    return $date;
}
1;
