package GCJavTitleCleanup;

# Limpieza acotada a los metadatos importados. No reescribe colecciones
# existentes ni cambia el formato de almacenamiento de GCstar.
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(clean_alternative_title);

sub clean_alternative_title
{
    my ($title, $alternative) = @_;
    return $alternative if !defined($title) || ref($title);
    return $alternative if !defined($alternative) || ref($alternative);

    # El codigo tiene que ser el mismo que figura al principio del titulo
    # principal. No suprimimos identificadores de otras peliculas.
    my ($code) = $title =~ /^\s*([A-Za-z]{2,10}[- ]?\d{2,7})\b/;
    return $alternative unless defined($code);

    my $clean = $alternative;
    my $changed = $clean =~ s/^\s*\Q$code\E(?:\s*[-:|]\s*|\s+)//i;
    return $alternative unless $changed;

    $clean =~ s/^\s+|\s+$//g;
    # Si no queda un nombre real, preferimos mantener el dato original.
    return length($clean) ? $clean : $alternative;
}

1;
