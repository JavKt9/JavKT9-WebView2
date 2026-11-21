package GCJavModelLinks;

# JavKT9 0.9.9.1: validar exclusivamente los enlaces de perfiles
# mostrados en la lista de modelos, sin modificar el dato almacenado.
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(is_model_links_list normalize_model_url);

sub is_model_links_list
{
    my ($field, $label, $number) = @_;
    return 0 unless defined($number) && $number == 1;

    if (defined($label) && !ref($label))
    {
        return 1 if $label =~ /^\s*(?:Enlaces\s+de\s+modelos|Model\s+links)\s*$/i;
    }

    # Nombres de campo conocidos, solo como respaldo para otros idiomas.
    if (defined($field) && !ref($field))
    {
        return 1 if $field =~ /^(?:model_?links|model_?urls|actress_?links)$/i;
    }
    return 0;
}

sub normalize_model_url
{
    my ($raw) = @_;
    return undef if !defined($raw) || ref($raw);
    my $url = $raw;
    $url =~ s/^\s+|\s+$//g;
    return undef unless $url =~ m{\Ahttps?://[^\s<>"']+\z}i;
    return $url;
}

1;
