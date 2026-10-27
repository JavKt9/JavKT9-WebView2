package GCLibraryList;

###################################################
# JavKT9 0.8.1 RC3 - Biblioteca (vista experimental)
#
# Vista independiente de Texto, Imagen y Detallada.
# Primera etapa: reutiliza la seleccion, las caratulas
# y la navegacion probadas de GCImageList; presenta
# cabecera propia y una paleta azul sin skin decorativo.
# La cuadrícula de tarjetas completa se desarrollara
# en etapas posteriores, sin reemplazar las vistas previas.
###################################################

use strict;
use parent -norequire, 'GCImageList';

sub new
{
    my ($proto, $parent) = @_;
    my $self = $proto->SUPER::new($parent, 0);

    my $header = Gtk3::HBox->new(0, 8);
    $header->set_border_width(9);

    my $title = Gtk3::Label->new('Biblioteca');
    $title->set_xalign(0);
    $header->pack_start($title, 1, 1, 5);

    # Reutilizamos la busqueda incremental del catalogo existente,
    # por ahora no es un filtro de resultados.
    my $search = $self->{searchEntry};
    $self->remove($search);
    $search->set_placeholder_text('Buscar titulo...') if $search->can('set_placeholder_text');
    $search->set_tooltip_text('Selecciona un titulo coincidente en la biblioteca');
    $search->set_width_chars(19);

    my $sort = $self->{sortButton};
    $self->remove($sort);
    $header->pack_end($sort, 0, 0, 0);
    $header->pack_end($search, 0, 0, 0);

    $self->pack_start($header, 0, 0, 0);
    $self->reorder_child($header, 0);
    $self->{javkt9LibraryHeader} = $header;

    return $self;
}

# El Gtk3::Entry heredado comparte estado con la lista de imagenes
# que contiene los registros. Enviamos alli la busqueda incremental.
sub internalSearch
{
    my $self = shift;
    return if !$self->{currentList};
    $self->{currentList}->internalSearch;
}

sub hideSearch
{
    my $self = shift;
    $self->{searchEntry}->set_text('');
    $self->{searchEntry}->show;
    $self->{previousSearch} = '';
}

sub show_all
{
    my $self = shift;
    $self->SUPER::show_all;
    # GCImageList oculta la busqueda temporal; Biblioteca la deja visible.
    $self->{searchEntry}->show;
}

1;
