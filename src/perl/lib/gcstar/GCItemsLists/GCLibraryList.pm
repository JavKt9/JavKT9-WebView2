package GCLibraryList;

###################################################
# JavKT9 0.8.1 RC3 - Biblioteca (vista experimental)
#
# No modifica la vista Imagen. Reutiliza su motor de
# seleccion, portadas y orden, pero con cabecera propia.
# Cada widget nuevo pertenece a esta vista; evitamos
# sacar hijos de la lista antigua (Gtk3::Container->remove
# podria destruirlos y dejar la cabecera incompleta).
###################################################

use strict;
use parent -norequire, 'GCImageList';

sub new
{
    my ($proto, $parent) = @_;
    my $self = $proto->SUPER::new($parent, 0);

    my $header = Gtk3::HBox->new(0, 8);
    $header->set_border_width(9);
    $header->set_name('GCJavLibraryToolbar');

    my $title = Gtk3::Label->new('Biblioteca');
    $title->set_name('GCJavLibraryTitle');
    $title->set_xalign(0);
    $header->pack_start($title, 1, 1, 5);

    # Campo independiente: sincroniza con la busqueda incremental existente.
    # No es todavia un filtro que oculte tarjetas.
    my $search = Gtk3::Entry->new;
    $search->set_name('GCJavLibrarySearch');
    $search->set_placeholder_text('Buscar pelicula...');
    $search->set_tooltip_text('Buscar y seleccionar una pelicula de la lista');
    $search->set_width_chars(19);
    $search->signal_connect('changed' => sub {
        $self->{searchEntry}->set_text($search->get_text);
    });
    $header->pack_end($search, 0, 0, 0);

    # Boton de orden propio; comunica el clic al boton heredado sin moverlo.
    my $sort = Gtk3::Button->new($self->{sortButton}->get_label || 'Ordenar');
    $sort->set_name('GCJavLibrarySort');
    $sort->set_tooltip_text('Cambiar el orden de las peliculas');
    $sort->signal_connect('clicked' => sub {
        $self->{sortButton}->clicked;
        $sort->set_label($self->{sortButton}->get_label);
    });
    $header->pack_end($sort, 0, 0, 0);

    $self->{javkt9LibrarySearch} = $search;
    $self->{javkt9LibrarySort} = $sort;
    $self->{javkt9LibraryHeader} = $header;

    # El selector heredado solo tiene sentido en la vista Imagen.
    $self->{sortButton}->set_no_show_all(1);
    $self->{sortButton}->hide;

    # Gtk3::VBox ya contiene el scroll; cabecera arriba del catalogo.
    $self->pack_start($header, 0, 0, 0);
    $self->reorder_child($header, 0);

    # CSS acotado a los IDs de esta vista; no afecta las anteriores.
    my $css = Gtk3::CssProvider->new;
    $css->load_from_data(q{
        #GCJavLibraryToolbar {
            background-color: #17283B;
            border-bottom: 1px solid #30465B;
        }
        #GCJavLibraryTitle {
            color: #F1F5FB;
            font-weight: bold;
            font-size: 16px;
        }
        #GCJavLibrarySearch {
            background-color: #22394F;
            color: #F1F5FB;
            border-color: #355774;
        }
        #GCJavLibrarySort {
            background-color: #22394F;
            color: #F1F5FB;
            border-color: #355774;
        }
    });
    Gtk3::StyleContext::add_provider_for_screen(
        $self->get_screen, $css, 620
    );
    $self->{javkt9LibraryCss} = $css;

    return $self;
}

# Mantiene la busqueda de seleccion heredada de Imagen.
sub internalSearch
{
    my $self = shift;
    return if !$self->{currentList};
    $self->{currentList}->internalSearch;
}

sub show_all
{
    my $self = shift;
    $self->SUPER::show_all;
    # GCImageList oculta su entrada temporal. Nuestra busqueda sigue visible.
    $self->{javkt9LibraryHeader}->show_all
        if $self->{javkt9LibraryHeader};
    $self->{sortButton}->hide if $self->{sortButton};
}

1;
