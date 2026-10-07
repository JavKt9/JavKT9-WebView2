package GCJavPersonFavoritesAdapter;
use strict;
use warnings;
use utf8;
use Exporter 'import';
our @EXPORT_OK = qw(people_from_film favorites_for_film);

# GCfilms: director is a short text field; actors is a single-list field.
# Accept the list as an array reference or as a plain string.
sub people_from_film {
    my ($film) = @_;
    die 'film must be a hash reference' unless ref($film) eq 'HASH';
    my $director = $film->{director};
    $director = '' if !defined $director || ref $director;
    $director =~ s/^\s+|\s+$//g;
    my $raw = $film->{actors};
    my @actors = ref($raw) eq 'ARRAY' ? @$raw :
                 !defined($raw) || ref($raw) ? () : split(/\s*(?:,|;|\n)\s*/, $raw);
    my %seen;
    @actors = grep {
        defined($_) && !ref($_) && do {
            s/^\s+|\s+$//g;
            length($_) && !$seen{lc($_)}++;
        }
    } @actors;
    return { directors => ($director eq '' ? [] : [$director]), actors => \@actors };
}

sub favorites_for_film {
    my ($store, $film) = @_;
    my $people = people_from_film($film);
    my %result;
    for my $kind (qw(actors directors)) {
        $result{$kind} = [grep { $store->is_favorite($kind, $_) } @{$people->{$kind}}];
    }
    return \%result;
}
1;
