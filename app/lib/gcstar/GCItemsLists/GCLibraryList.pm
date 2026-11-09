package GCLibraryList;

# JavKT9 0.8.1 RC3 - Biblioteca V9.4 (cache LRU de portadas) - conserva hover y skins.
# No cambia GCImageLists.pm ni GCImageListComponents.pm.
use strict;
use parent -norequire, 'GCImageList';
use Scalar::Util ();

sub new
{
    my ($proto, $parent) = @_;
    my $self = $proto->SUPER::new($parent, 0);
    $self->set_name('GCJavLibraryView');
    $self->{mainList}->set_name('GCJavLibraryMain') if $self->{mainList};

    # Unicamente KT9V1 activa la distribucion del boceto. Los
    # siete temas existentes conservan su cabecera y su comportamiento.
    my $wine = ($parent->{options} && $parent->{options}->view == 4) ? 1 : 0;
    my $header = $wine ? Gtk3::VBox->new(0, 7) : Gtk3::HBox->new(0, 8);
    $header->set_border_width($wine ? 11 : 9);
    $header->set_name('GCJavLibraryToolbar');

    my $title = Gtk3::Label->new('Biblioteca');
    $title->set_name('GCJavLibraryTitle');
    $title->set_xalign(0);

    my $search = Gtk3::Entry->new;
    $search->set_name('GCJavLibrarySearch');
    $search->set_placeholder_text($wine ? 'Buscar codigo, titulo, actriz o estudio...' : 'Buscar codigo...');
    $search->set_tooltip_text('Busqueda local. No modifica ningun dato de la coleccion.');
    $search->set_width_chars($wine ? 36 : 19);
    $search->signal_connect('changed' => sub {
        $self->{javkt9LibraryQuery} = $search->get_text;
        if ($self->{javkt9LibrarySearchTimer})
        {
            Glib::Source->remove($self->{javkt9LibrarySearchTimer});
            $self->{javkt9LibrarySearchTimer} = 0;
        }
        $self->{javkt9LibrarySearchTimer} = Glib::Timeout->add(180, sub {
            $self->{javkt9LibrarySearchTimer} = 0;
            my $window = $self->{parent};
            return 0 if !$window || !$window->{itemsView};
            return 0 if Scalar::Util::refaddr($window->{itemsView})
                     != Scalar::Util::refaddr($self);
            $window->filter(1);
            if ($search->get_mapped)
            {
                $search->grab_focus;
                $search->set_position(-1);
            }
            return 0;
        });
    });

    my $sort = Gtk3::Button->new($self->{sortButton}->get_label || 'Ordenar');
    $sort->set_name('GCJavLibrarySort');
    $sort->set_tooltip_text('Cambiar el orden de las peliculas');
    $sort->signal_connect('clicked' => sub {
        if ($self->{javkt9LibraryRatingButton}
            && $self->{javkt9LibraryRatingButton}->get_active)
        {
            $self->{javkt9LibraryRatingButton}->set_active(0);
        }
        $self->{sortButton}->clicked;
        $sort->set_label($self->{sortButton}->get_label);
    });

    my $favoritesFilter = Gtk3::ToggleButton->new_with_label($wine ? '♡ Favoritas' : 'Solo favoritos');
    $favoritesFilter->set_name('GCJavLibraryFavoritesFilter');
    $favoritesFilter->set_tooltip_text('Mostrar solo peliculas favoritas');
    $favoritesFilter->signal_connect('toggled' => sub {
        $self->{javkt9LibraryFavoritesOnly} = $favoritesFilter->get_active ? 1 : 0;
        my $window = $self->{parent};
        return if !$window || !$window->{itemsView};
        return if Scalar::Util::refaddr($window->{itemsView})
               != Scalar::Util::refaddr($self);
        $window->filter(1);
    });
    my $ratingOrder = Gtk3::ToggleButton->new_with_label($wine ? '★ Rating' : 'Mayor rating');
    $ratingOrder->set_name('GCJavLibraryRatingOrder');
    $ratingOrder->set_tooltip_text('Ordenar por rating, sin alterar el orden guardado');
    $ratingOrder->signal_connect('toggled' => sub {
        $self->{javkt9LibraryRatingOrder} = $ratingOrder->get_active ? 1 : 0;
        my $window = $self->{parent};
        return if !$window || !$window->{itemsView};
        return if Scalar::Util::refaddr($window->{itemsView})
               != Scalar::Util::refaddr($self);
        $window->filter(1);
    });

    if ($wine)
    {
        my $searchRow = Gtk3::HBox->new(0, 9);
        $searchRow->set_name('GCJavLibrarySearchRow');
        $searchRow->pack_start($search, 1, 1, 0);
        my $action = Gtk3::Button->new_with_label('Buscar');
        $action->set_name('GCJavLibraryAction');
        $action->signal_connect('clicked' => sub { $self->{parent}->filter(1) if $self->{parent} && $self->{parent}->{itemsView}; });
        $searchRow->pack_start($action, 0, 0, 0);
        $header->pack_start($searchRow, 0, 0, 0);

        my $filterRow = Gtk3::HBox->new(0, 8);
        $filterRow->set_name('GCJavLibraryFilterRow');
        my @facets = (
            ['format','Todos los formatos'],
            ['studio','Todos los estudios'],
            ['actors','Todas las actrices'],
            ['tags','Todas las etiquetas'],
        );
        foreach my $f (@facets)
        {
            my ($field,$placeholder) = @$f;
            my $combo = Gtk3::ComboBoxText->new;
            $combo->append_text($placeholder);
            $combo->set_active(0);
            $combo->set_tooltip_text('Filtrar por '. $field .' sin modificar la coleccion');
            $combo->signal_connect('changed' => sub {
                return if $self->{obsidianPopulatingFilters};
                my $idx = $combo->get_active;
                $self->{obsidianSelected}->{$field} = ($idx > 0) ? ($combo->get_active_text || '') : '';
                $self->{parent}->filter(1) if $self->{parent} && $self->{parent}->{itemsView};
            });
            $self->{obsidianFacets}->{$field} = { combo => $combo, label => $placeholder };
            $filterRow->pack_start($combo, 0, 0, 0);
        }
        $filterRow->pack_end($ratingOrder, 0, 0, 0);
        $filterRow->pack_end($favoritesFilter, 0, 0, 0);
        $filterRow->pack_end($sort, 0, 0, 0);
        $header->pack_start($filterRow, 0, 0, 0);
        my $count = Gtk3::Label->new('Coleccion');
        $count->set_xalign(0);
        $count->set_name('GCJavLibraryCount');
        $header->pack_start($count, 0, 0, 0);
        $self->{obsidianCountLabel} = $count;
    }
    else
    {
        $header->pack_start($title, 1, 1, 5);
        $header->pack_end($search, 0, 0, 0);
        $header->pack_end($sort, 0, 0, 0);
        $header->pack_end($favoritesFilter, 0, 0, 0);
        $header->pack_end($ratingOrder, 0, 0, 0);
    }
    $self->{obsidianWine} = $wine;

    $self->{javkt9LibrarySearch} = $search;
    $self->{javkt9LibrarySort} = $sort;
    $self->{javkt9LibraryFavoritesFilter} = $favoritesFilter;
    $self->{javkt9LibraryFavoritesOnly} = 0;
    $self->{javkt9LibraryRatingOrder} = 0;
    $self->{javkt9LibraryRatingButton} = $ratingOrder;
    $self->{javkt9LibraryHeader} = $header;

    $self->{sortButton}->set_no_show_all(1);
    $self->{sortButton}->hide;
    $self->pack_start($header, 0, 0, 0);
    $self->reorder_child($header, 0);

    my $css = Gtk3::CssProvider->new;
    $css->load_from_data($wine ? q{ } : q{
        #GCJavLibraryToolbar {
            background-color: #17283B;
            border-bottom: 1px solid #30465B;
        }
        #GCJavLibraryTitle {
            color: #F1F5FB;
            font-weight: bold;
            font-size: 16px;
        }
        #GCJavLibrarySearch, #GCJavLibrarySort, #GCJavLibraryFavoritesFilter, #GCJavLibraryRatingOrder {
            background-color: #22394F;
            color: #F1F5FB;
            border-color: #355774;
        }
        #GCJavLibraryFavoritesFilter:checked, #GCJavLibraryRatingOrder:checked {
            background-color: #415B78;
            color: #FFDB83;
            border-color: #D5AE57;
        }
        #GCJavLibraryCard {
            background-color: #1A2A3C;
            border: 1px solid #30465B;
            border-radius: 8px;
        }
        #GCJavLibraryPoster {
            background-color: #102033;
            border-radius: 6px;
        }
        #GCJavLibraryCard.gcjav-card-selected {
            background-color: #2C4D6B;
            border: 2px solid #6BA8DB;
        }
        #GCJavLibraryCardCode {
            color: #91B2D0;
            font-size: 13px;
            font-weight: bold;
        }
        #GCJavLibraryCardTitle {
            color: #F1F5FB;
            font-size: 13px;
        }
        #GCJavLibraryCardDivider {
            background-color: #30465B;
        }
        /* V8: la estrella de favorito es un boton real, independiente
           del rating y de los colores de seleccion del skin. */
        #GCJavLibraryFavoriteButton {
            color: #9499A5;
            background-color: rgba(17, 22, 32, 0.80);
            background-image: none;
            border: 1px solid rgba(220, 225, 235, 0.18);
            border-radius: 14px;
            padding: 0px;
            min-height: 26px;
            min-width: 27px;
            box-shadow: none;
            font-size: 19px;
        }
        #GCJavLibraryFavoriteButton.gcjav-favorite-active {
            color: #FFCB56;
            border-color: rgba(255, 203, 86, 0.55);
        }
        #GCJavLibraryFavoriteButton:hover {
            background-color: rgba(38, 44, 64, 0.94);
        }
        #GCJavLibraryRating {
            color: #F4C65F;
            font-weight: bold;
            font-size: 12px;
        }
        /* V9.2: brillo sutil SOLO para el rating perfecto.
           La insignia de favoritos no se altera. */
        #GCJavLibraryRating.gcjav-rating-perfect {
            text-shadow: 0 0 5px rgba(255, 210, 95, 0.90);
        }
    });
    Gtk3::StyleContext::add_provider_for_screen($self->get_screen, $css, 620);
    $self->{javkt9LibraryCss} = $css;
    return $self;
}

# Recibir el filtro oficial de JavKT9 y combinarlo con nuestro texto.
# El motor original sigue decidiendo cuales peliculas estan permitidas
# por el filtro general de la aplicacion. Nunca alteramos los registros.
# En KT9V1, los filtros son funcionales y usan solamente
# valores reales de la coleccion. No se agregan campos ficticios.
sub _obsidianText
{
    my ($value) = @_;
    return '' if !defined $value;
    if (ref($value) eq 'ARRAY') {
        return join(', ', map { _obsidianText($_) } @$value);
    }
    return '' if ref($value);
    return "$value";
}

sub _obsidianPopulateFilters
{
    my ($self, $items) = @_;
    return if !$self->{obsidianWine} || !$self->{obsidianFacets};
    return if ref($items) ne 'ARRAY';
    my %values;
    foreach my $raw (@$items) {
        next if ref($raw) ne 'HASH';
        foreach my $field (qw(format studio actors tags)) {
            my $text = _obsidianText($raw->{$field});
            foreach my $entry (split /[,;\n]+/, $text) {
                $entry =~ s/^\s+|\s+$//g;
                next if !length($entry) || length($entry) > 80;
                $values{$field}->{$entry} = 1;
            }
        }
    }
    $self->{obsidianPopulatingFilters} = 1;
    foreach my $field (qw(format studio actors tags)) {
        my $cfg = $self->{obsidianFacets}->{$field};
        next if !$cfg;
        my $combo = $cfg->{combo};
        my @new = sort { lc($a) cmp lc($b) } keys %{$values{$field} || {}};
        splice @new, 250 if @new > 250;
        my $signature = join("\x1e", @new);
        next if defined($cfg->{signature}) && $cfg->{signature} eq $signature;
        my $selected = $self->{obsidianSelected}->{$field} || '';
        $combo->remove_all;
        $combo->append_text($cfg->{label});
        my $i = 0;
        my $selectedIndex = 0;
        foreach my $value (@new) {
            $i++;
            $combo->append_text($value);
            $selectedIndex = $i if $value eq $selected;
        }
        $combo->set_active($selectedIndex);
        $self->{obsidianSelected}->{$field} = '' if !$selectedIndex;
        $cfg->{signature} = $signature;
    }
    $self->{obsidianPopulatingFilters} = 0;
}

sub setFilter
{
    my ($self, $filter, $items, $refresh, $splash) = @_;
    $self->_obsidianPopulateFilters($items) if $self->{obsidianWine};
    my $query = $self->{javkt9LibraryQuery} || '';
    $query =~ s/^\s+|\s+$//g;
    my $onlyFavorites = $self->{javkt9LibraryFavoritesOnly} ? 1 : 0;
    my $facets = $self->{obsidianWine} ? ($self->{obsidianSelected} || {}) : {};
    my $activeFacet = grep { length($facets->{$_} || '') } keys %$facets;
    my $combined = (length($query) || $onlyFavorites || $activeFacet)
        ? GCLibrarySearchFilter->new($filter, $query, $onlyFavorites, $facets, $self->{obsidianWine})
        : $filter;
    my $result = $self->SUPER::setFilter($combined, $items, $refresh, $splash);
    if ($self->{obsidianCountLabel}) {
        my $count = eval { $self->getNbItems };
        $count = scalar(@$items) if !defined($count) && ref($items) eq 'ARRAY';
        $count = 0 if !defined($count);
        $self->{obsidianCountLabel}->set_text($count.' elementos');
    }
    return $result;
}

# Dimension exclusiva V3: el calculo de columnas heredado se mantiene.
# Ninguna preferencia de la vista Imagen se modifica.
sub initStyle
{
    my $self = shift;
    $self->SUPER::initStyle(@_);
    $self->{style}->{factor} = 1;
    $self->{style}->{withAnimation} = 0;
    my $wine = $self->{obsidianWine} || ($self->{parent} && $self->{parent}->{options} && $self->{parent}->{options}->view == 4);
    $self->{style}->{obsidianWine} = $wine;
    $self->{style}->{imgWidth} = $wine ? 182 : 380;
    $self->{style}->{imgHeight} = $wine ? 221 : 354;
    $self->{style}->{vboxWidth} = $wine ? 220 : 440;
    # El contenido compacto permite cinco columnas a partir de 1440 px.
    $self->{style}->{vboxHeight} = $wine ? 380 : 534;
    $self->{style}->{pageCount} = 2;
}

# Copia restringida de addGroup: solamente cambia el tipo de lista interna.
sub addGroup
{
    my ($self, $group, $refGroup, $immediate) = @_;
    my $listBox = Gtk3::VBox->new(0, 0);
    my $list = GCLibraryBaseList->new($self, $self->{columns});
    if ($self->{groupItems})
    {
        my $label = $self->createHeader(
            ($refGroup eq 'GCMAINDEFAULTGROUP') ? '' : $group
        );
        $listBox->pack_start($label, 0, 0, 0);
        $list->setHeader($label);
        $list->{refGroup} = $refGroup;
        $label->show_all;
    }
    my $eventBox = Gtk3::EventBox->new;
    $eventBox->add($list);
    $listBox->pack_start($eventBox, 0, 0, 0);
    $self->{mainList}->pack_start($listBox, 0, 0, 0);
    push @{$self->{orderedLists}}, $refGroup
        if $refGroup ne 'GCMAINDEFAULTGROUP';
    if ($immediate && $self->{groupItems})
    {
        my $place = $self->sortAndFind($refGroup);
        $self->{mainList}->reorder_child($listBox, $place) if $place;
    }
    $listBox->show_all;
    $self->initListStyle($list);
    $self->{lists}->{$refGroup} = $list;
    $self->{listBoxes}->{$refGroup} = $listBox;
    $self->{currentList} = $list if !$self->{currentList};
    $list->done(undef, 1) if $immediate;
    return $list;
}

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
    $self->{javkt9LibraryHeader}->show_all
        if $self->{javkt9LibraryHeader};
    $self->{sortButton}->hide if $self->{sortButton};
}


# Filtro auxiliar V8.2: codigo + favoritas + filtros oficiales de JavKT9.
# "test" es la interfaz de filtro que ya utiliza GCBaseImageList.
package GCLibrarySearchFilter;
use strict;

sub new
{
    my ($class, $base, $query, $onlyFavorites, $facets, $wine) = @_;
    return bless {
        facets => $facets || {},
        wine => $wine ? 1 : 0,
        base => $base,
        needle => _normalize($query),
        onlyFavorites => $onlyFavorites ? 1 : 0,
    }, $class;
}

sub _normalize
{
    my ($value) = @_;
    return '' if !defined($value) || ref($value);
    $value = lc($value);
    # Comparar codigos sin importar guiones, espacios ni mayusculas.
    $value =~ s/[^a-z0-9]+//g;
    $value =~ s/^\s+|\s+$//g;
    return $value;
}

sub test
{
    my ($self, $raw) = @_;
    return 0 if !$self->{base}->test($raw);
    return 0 if !defined($raw) || ref($raw) ne 'HASH';
    if ($self->{onlyFavorites}) {
        my $favorite = $raw->{favourite};
        return 0 if !defined($favorite) || ref($favorite) || $favorite !~ /^1$/;
    }
    foreach my $field (keys %{$self->{facets}}) {
        my $needed = $self->{facets}->{$field} || '';
        next if !length($needed);
        my $available = lc(GCLibraryList::_obsidianText($raw->{$field}));
        return 0 if index($available, lc($needed)) < 0;
    }
    my $needle = $self->{needle};
    return 1 if !length $needle;
    if ($self->{wine}) {
        my $fields = join(' ', map { GCLibraryList::_obsidianText($raw->{$_}) }
                                  qw(title original actors studio director code));
        return index(_normalize($fields), $needle) >= 0 ? 1 : 0;
    }
    return index(_normalize($raw->{title}), $needle) >= 0 ? 1 : 0;
}

package GCLibraryBaseList;
use strict;
use parent -norequire, 'GCBaseImageList';

# V9.4: cache LRU PEQUENA de pixbufs, compartida solo por las tarjetas
# de esta lista Biblioteca. GCImageCache heredado mantiene copias en
# DISCO; no comparte por si mismo el pixbuf decodificado entre tarjetas.
# Nunca se cambia el pixbuf ni la caratula de la coleccion original.
# Con mas de 16 caratulas distintas, se descartan las menos recientes.
# Gtk3::Image mantiene su propia referencia a las imagenes ya asignadas.
sub _javkt9SharedCoverPixbuf
{
    my ($self, $signature, $localSource, $forceRefresh) = @_;
    return if !length($signature);

    my $cache = $self->{javkt9CoverPixbufCache} ||= {};
    my $lru = $self->{javkt9CoverPixbufLru} ||= [];

    if (!$forceRefresh && exists $cache->{$signature})
    {
        # Actualizar LRU, sin volver a abrir/decodificar la caratula.
        @{$lru} = grep { $_ ne $signature } @{$lru};
        push @{$lru}, $signature;
        return $cache->{$signature};
    }

    my $pixbuf = eval {
        Gtk3::Gdk::Pixbuf->new_from_file_at_scale(
            $localSource,
            $self->{style}->{obsidianWine} ? 182 : 380,
            $self->{style}->{obsidianWine} ? 221 : 354, 1
        );
    };
    return if !$pixbuf;

    # ForceRefresh (edicion de caratula) reemplaza el elemento compartido;
    # las tarjetas existentes siguen siendo validas hasta su refresh.
    $cache->{$signature} = $pixbuf;
    @{$lru} = grep { $_ ne $signature } @{$lru};
    push @{$lru}, $signature;
    while (@{$lru} > 16)
    {
        my $obsolete = shift @{$lru};
        delete $cache->{$obsolete};
    }
    return $pixbuf;
}


# La ficha conserva su propio campo Original; no modificamos el modelo.
# Adjuntamos ese texto solo a la representacion de Biblioteca.
sub createItemInfo
{
    my ($self, $idx, $raw) = @_;
    my $item = $self->SUPER::createItemInfo($idx, $raw);
    $item->{javkt9OriginalTitle} =
        defined($raw->{original}) && !ref($raw->{original})
            ? $raw->{original} : '';
    return $item;
}

# V8.3: solo reordenamos la matriz de tarjetas de esta lista visual.
# Los registros, sus ID, los campos de rating y las preferencias de
# orden de JavKT9 nunca se alteran. El motor recompone las posiciones
# de las tarjetas desde idx en el siguiente refresh.
sub _javkt9RatingValue
{
    my ($raw) = @_;
    return -1 if ref($raw) ne 'HASH';
    my $rating = $raw->{rating};
    return -1 if !defined($rating) || ref($rating);
    return -1 if $rating !~ /^\s*(?:\d+(?:\.\d+)?|\.\d+)\s*$/;
    return -1 if $rating <= 0 || $rating > 10;
    return 0 + $rating;
}

sub _javkt9ApplyRatingOrder
{
    my $self = shift;
    return if ref($self->{itemsArray}) ne 'ARRAY';
    my $library = $self->{container};
    my $ratingMode = $library && $library->{javkt9LibraryRatingOrder};
    if ($ratingMode)
    {
        my $items = $self->{parent}->{items}->getItemsListFiltered;
        return if ref($items) ne 'ARRAY';
        my %ratingByIdx;
        foreach my $entry (@{$self->{itemsArray}})
        {
            my $idx = $entry->{idx};
            $ratingByIdx{$idx} = _javkt9RatingValue($items->[$idx]);
        }
        @{$self->{itemsArray}} = sort {
            ($ratingByIdx{$b->{idx}} <=> $ratingByIdx{$a->{idx}})
            || GCUtils::gccmpe($a->{sortValue}, $b->{sortValue})
            || ($a->{idx} <=> $b->{idx})
        } @{$self->{itemsArray}};
        $self->{javkt9RatingOrderApplied} = 1;
    }
    elsif ($self->{javkt9RatingOrderApplied})
    {
        # Al desactivar Mayor rating, restaurar el sentido real del
        # orden habitual (que ya controla el boton Ordenar existente).
        my $asc = defined($self->{currentOrder})
            ? $self->{currentOrder}
            : $self->{preferences}->sortOrder;
        @{$self->{itemsArray}} = $asc == 1
            ? sort {GCUtils::gccmpe($a->{sortValue}, $b->{sortValue})}
                   @{$self->{itemsArray}}
            : reverse sort {GCUtils::gccmpe($a->{sortValue}, $b->{sortValue})}
                   @{$self->{itemsArray}};
        $self->{javkt9RatingOrderApplied} = 0;
    }
}

# V9.3: setFilter necesita el orden ANTES de calcular indices visibles.
# El motor heredado llama a refresh desde setFilter(refresh=1):
# no repetir el mismo ordenamiento O(n log n) en esa segunda llamada.
# "local" limita la marca a esta operacion y la restaura incluso si falla.
sub setFilter
{
    my $self = shift;
    $self->_javkt9ApplyRatingOrder;
    local $self->{javkt9OrderPreparedForSetFilter} = 1;
    return $self->SUPER::setFilter(@_);
}

# refresh independiente (abrir coleccion/cambiar columnas) si recalcula.
sub refresh
{
    my $self = shift;
    $self->_javkt9ApplyRatingOrder
        if !$self->{javkt9OrderPreparedForSetFilter};
    return $self->SUPER::refresh(@_);
}

# V8.4: el motor base ya refresca las insignias (rating y favorito)
# mediante refreshPopup, y la imagen si cambia el campo cover. Solo
# reforzamos titulo/original, que antes no volvian a pasar por refreshInfo,
# y el orden dinamico si se edita rating desde la ficha con Mayor rating.
sub _javkt9FieldChanged
{
    my ($previous, $new, $field) = @_;
    my $before = defined($previous->{$field}) && !ref($previous->{$field})
        ? $previous->{$field} : '';
    my $after = defined($new->{$field}) && !ref($new->{$field})
        ? $new->{$field} : '';
    return $before ne $after;
}

sub changeCurrent
{
    my ($self, $previous, $new, $idx, $wantSelect) = @_;
    my $titleChanged = _javkt9FieldChanged($previous, $new, 'title')
                    || _javkt9FieldChanged($previous, $new, 'original');
    my $ratingChanged = _javkt9FieldChanged($previous, $new, 'rating');

    # El motor original mantiene los indices, seleccion, filtros,
    # thumbnails y la marca de cambios sin ninguna alteracion.
    my $result = $self->SUPER::changeCurrent($previous, $new, $idx, $wantSelect);

    # La ficha tiene titulo descriptivo en Original: reconstruir ambas
    # etiquetas sin redibujar todas las tarjetas ni cambiar la coleccion.
    if ($titleChanged && defined($result) && $result >= 0
        && ref($self->{cache}) eq 'ARRAY')
    {
        my $entry = $self->{cache}->[$result];
        my $card = $entry && $entry->{imageBox};
        if ($card)
        {
            my $item = $self->createItemInfo($result, $new);
            $card->refreshInfo($item);
        }
    }

    # Cambiar un rating debe modificar tambien la POSICION si esta
    # activado Mayor rating. Hacerlo en idle: no destruir/recrear tarjetas
    # mientras GCData procesa el cambio de la ficha.
    my $library = $self->{container};
    if ($ratingChanged && $library
        && $library->{javkt9LibraryRatingOrder}
        && !$library->{javkt9LibraryPendingOrderRefresh})
    {
        $library->{javkt9LibraryPendingOrderRefresh} = 1;
        Glib::Idle->add(sub {
            $library->{javkt9LibraryPendingOrderRefresh} = 0;
            my $window = $library->{parent};
            return 0 if !$window || !$window->{itemsView};
            return 0 if !Scalar::Util::refaddr($window->{itemsView})
                     || Scalar::Util::refaddr($window->{itemsView})
                        != Scalar::Util::refaddr($library);
            return 0 if !$library->{javkt9LibraryRatingOrder};
            $window->filter(1);
            return 0;
        });
    }
    return $result;
}

sub createImageBox
{
    my ($self, $info) = @_;
    return GCLibraryCard->new($self, $info);
}


package GCLibraryCard;
use strict;
use parent -norequire, 'GCImageListItem';

sub new
{
    my ($proto, $container, $info) = @_;
    my $class = ref($proto) || $proto;
    my $self = Gtk3::EventBox->new;
    bless($self, $class);

    # Campos del motor original: sus callbacks trabajan con estos datos.
    $self->{info}          = $info;
    $self->{container}     = $container;
    $self->{style}         = $container->{style};
    $self->{file}          = $container->{parent}->{options}->file;
    $self->{collectionDir} = $container->{collectionDir};
    $self->{model}         = $container->{parent}->{model};
    $self->{imageCache}    = $container->{imageCache};
    $self->{dataManager}   = $container->{parent}->{items};

    $self->set_can_focus(1);
    $self->set_name('GCJavLibraryCard');
    my $wine = $self->{style}->{obsidianWine} ? 1 : 0;
    $self->set_size_request($wine ? 204 : 420, $wine ? 368 : 516);
    $self->set_margin_start($wine ? 6 : 10);
    $self->set_margin_end($wine ? 6 : 10);
    $self->set_margin_bottom($wine ? 10 : 18);

    my $box = Gtk3::VBox->new(0, $wine ? 3 : 5);
    $box->set_border_width($wine ? 8 : 14);
    my $poster = Gtk3::VBox->new(0, 0);
    $poster->set_name('GCJavLibraryPoster');
    $poster->set_size_request($wine ? 182 : 380, $wine ? 221 : 354);
    $self->{javkt9CardImage} = Gtk3::Image->new;
    $self->{javkt9CardImage}->set_size_request($wine ? 182 : 380, $wine ? 221 : 354);
    $poster->pack_start($self->{javkt9CardImage}, 1, 1, 0);

    # V8: insignia de favorito sobre la caratula, sin cambiar el recorte.
    # Gtk3::Overlay permite que el boton ocupe solo la esquina: el resto
    # de la caratula conserva seleccion, doble clic y tooltip de V7.2.1.
    my $overlay = Gtk3::Overlay->new;
    $overlay->add($poster);
    # V8.1: etiqueta Pango propia; el color no depende del color
    # predeterminado de GtkButton definido por el skin activo.
    my $favoriteButton = Gtk3::Button->new;
    $favoriteButton->set_name('GCJavLibraryFavoriteButton');
    my $favoriteStar = Gtk3::Label->new('');
    $favoriteStar->set_use_markup(1);
    $favoriteButton->add($favoriteStar);
    $self->{javkt9FavoriteStar} = $favoriteStar;
    $favoriteButton->set_halign('end');
    $favoriteButton->set_valign('start');
    $favoriteButton->set_margin_top(7);
    $favoriteButton->set_margin_end(7);
    $favoriteButton->set_tooltip_text('Marcar como favorita');
    $self->{javkt9FavoriteButton} = $favoriteButton;
    $overlay->add_overlay($favoriteButton) if !$wine;
    $box->pack_start($overlay, 0, 0, 0);

    # V8.1: en la tarjeta completa hay un EventBox que procesa el
    # button-press para seleccionar peliculas. Consumimos el click IZQUIERDO
    # directamente en el boton antes de que llegue a ese contenedor.
    # "clicked" queda para activacion con teclado/accesibilidad.
    my $toggleFavorite = sub {
        my $manager = $self->{dataManager};
        my $idx = $self->{info}->{idx};
        return if !defined($idx) || !$manager;
        my $items = $manager->getItemsListFiltered;
        return if ref($items) ne 'ARRAY';
        my $raw = $items->[$idx];
        return if ref($raw) ne 'HASH';
        my $value = (defined $raw->{favourite} && $raw->{favourite} eq '1') ? 0 : 1;
        $manager->setValue($idx, 'favourite', $value);
        # Estado visible al instante, antes de guardar la coleccion.
        $self->refreshBadges($raw);
        $self->{container}->{parent}->markAsUpdated;

        # Si Solo favoritos esta activo, quitar la estrella debe retirar
        # esa tarjeta de la vista (no de la coleccion). Refiltrar en idle
        # evita destruir la tarjeta mientras GTK procesa su click.
        my $library = $self->{container}->{container};
        if ($library && $library->{javkt9LibraryFavoritesOnly})
        {
            Glib::Idle->add(sub {
                my $window = $library->{parent};
                return 0 if !$window || !$window->{itemsView};
                return 0 if Scalar::Util::refaddr($window->{itemsView})
                         != Scalar::Util::refaddr($library);
                $window->filter(1);
                return 0;
            });
        }
    };
    $favoriteButton->add_events(['button-press-mask']);
    $favoriteButton->signal_connect('button-press-event' => sub {
        my ($button, $event) = @_;
        return 0 if $event->button != 1;
        $toggleFavorite->();
        return 1;
    });
    $favoriteButton->signal_connect('clicked' => sub {
        $toggleFavorite->();
    });

    # V6: separacion discreta entre caratula e informacion.
    my $divider = Gtk3::Separator->new('horizontal');
    $divider->set_name('GCJavLibraryCardDivider');
    $divider->set_margin_top($wine ? 0 : 3);
    $divider->set_margin_bottom(2);
    $box->pack_start($divider, 0, 0, 0);

    $self->{javkt9CardCode} = Gtk3::Label->new('');
    $self->{javkt9CardCode}->set_name('GCJavLibraryCardCode');
    $self->{javkt9CardCode}->set_xalign($wine ? 0 : 0.5);
    $self->{javkt9CardCode}->set_justify('center');
    $self->{javkt9CardCode}->set_ellipsize('end');
    $self->{javkt9CardCode}->set_max_width_chars(30);
    if ($wine) {
        my $codeRow = Gtk3::HBox->new(0, 0);
        $codeRow->pack_start($self->{javkt9CardCode}, 1, 1, 0);
        $favoriteButton->set_margin_top(0);
        $favoriteButton->set_margin_end(0);
        $favoriteButton->set_valign('center');
        $codeRow->pack_end($favoriteButton, 0, 0, 0);
        $box->pack_start($codeRow, 0, 0, 0);
    } else {
        $box->pack_start($self->{javkt9CardCode}, 0, 0, 0);
    }

    # V8: valor unico ★ N/10. Se oculta si la ficha no tiene puntuacion.
    # No se confunde con la estrella de favorito de la caratula.
    $self->{javkt9RatingLabel} = Gtk3::Label->new('');
    $self->{javkt9RatingLabel}->set_name('GCJavLibraryRating');
    $self->{javkt9RatingLabel}->set_xalign($wine ? 0 : 0.5);
    $self->{javkt9RatingLabel}->set_no_show_all(1);
    $box->pack_start($self->{javkt9RatingLabel}, 0, 0, 0);

    $self->{javkt9CardTitle} = Gtk3::Label->new('');
    $self->{javkt9CardTitle}->set_name('GCJavLibraryCardTitle');
    $self->{javkt9CardTitle}->set_xalign($wine ? 0 : 0.5);
    $self->{javkt9CardTitle}->set_justify($wine ? 'left' : 'center');
    $self->{javkt9CardTitle}->set_ellipsize('end');
    $self->{javkt9CardTitle}->set_max_width_chars(32);
    $self->{javkt9CardTitle}->set_line_wrap(1);
    $self->{javkt9CardTitle}->set_lines($wine ? 1 : 2);
    $box->pack_start($self->{javkt9CardTitle}, 0, 0, 0);
    if ($wine) {
        foreach my $spec (
            ['javkt9CastLabel','GCJavLibraryCardCast'],
            ['javkt9StudioLabel','GCJavLibraryCardStudio'],
            ['javkt9TagsLabel','GCJavLibraryCardTags'],
        ) {
            my ($property,$name) = @$spec;
            my $label = Gtk3::Label->new('');
            $label->set_name($name);
            $label->set_xalign(0);
            $label->set_ellipsize('end');
            $label->set_max_width_chars(29);
            $label->set_no_show_all(1);
            $self->{$property} = $label;
            $box->pack_start($label, 0, 0, 0);
        }
    }

    $self->add($box);

    # V7.2.1: tooltip nativo de GTK3. Su espera habitual evita
    # apariciones mientras se recorre rapido la cuadricula. No usamos
    # timers para habilitar/deshabilitar la ayuda en cada cruce de mouse,
    # pues esos cruces incluyen widgets hijos y pueden resetear la espera.
    # refreshPopup prepara el texto real al finalizar la construccion.

    # V7: brillo de portada y borde al pasar el mouse, sin zoom ni recortes.
    # No se altera la logica heredada de seleccion, clic derecho o doble clic.
    $self->add_events(['enter-notify-mask', 'leave-notify-mask']);
    $self->signal_connect('enter-notify-event' => sub {
        my ($widget, $event) = @_;
        $self->get_style_context->add_class('gcjav-card-hover');
        $poster->get_style_context->add_class('gcjav-poster-hover');
        return 0;
    });
    $self->signal_connect('leave-notify-event' => sub {
        my ($widget, $event) = @_;
        # Un cruce de la tarjeta hacia un widget hijo (imagen, etiqueta)
        # no es una salida real de la tarjeta.
        my $detail = eval { $event->detail };
        return 0 if defined($detail) && "$detail" =~ /inferior/i;
        $self->get_style_context->remove_class('gcjav-card-hover');
        $poster->get_style_context->remove_class('gcjav-poster-hover');
        return 0;
    });

    $self->refreshInfo($info);
    $self->show_all;
    return $self;
}


# V8: los dos indicadores leen exclusivamente favourite y rating
# existentes en el registro. El tooltip conserva su propio contenido.
sub refreshBadges
{
    my ($self, $raw) = @_;
    return if !$raw || ref($raw) ne 'HASH';
    if ($self->{javkt9FavoriteButton})
    {
        my $button = $self->{javkt9FavoriteButton};
        my $active = defined($raw->{favourite}) && !ref($raw->{favourite})
                  && $raw->{favourite} =~ /^1$/;
        # ☆ gris = normal, ★ dorada = favorita. El marcado Pango se
        # impone al color general del skin sin modificar otros controles.
        if ($active)
        {
            $button->get_style_context->add_class('gcjav-favorite-active');
            $button->set_tooltip_text('Quitar de favoritas');
            $self->{javkt9FavoriteStar}->set_markup(
                $self->{style}->{obsidianWine}
                  ? "<span size=\"large\">\x{2665}</span>"
                  : "<span foreground=\"#FFCB56\" size=\"x-large\">\x{2605}</span>");
        }
        else
        {
            $button->get_style_context->remove_class('gcjav-favorite-active');
            $button->set_tooltip_text('Marcar como favorita');
            $self->{javkt9FavoriteStar}->set_markup(
                $self->{style}->{obsidianWine}
                  ? "<span size=\"large\">\x{2661}</span>"
                  : "<span foreground=\"#9BA0AF\" size=\"x-large\">\x{2606}</span>");
        }
    }
    if ($self->{javkt9RatingLabel})
    {
        my $label = $self->{javkt9RatingLabel};
        my $rating = $raw->{rating};
        # V9.2: paleta del rating de la ficha (independiente de favorito):
        # 1-4 rojo, 5-6 ambar, 7-9 verde, 10 dorado mas luminoso.
        # 0 es "sin calificacion"; nunca inventamos estrellas ni puntajes.
        my $style = $label->get_style_context;
        $style->remove_class('gcjav-rating-perfect');
        if (defined($rating) && !ref($rating)
            && $rating =~ /^\s*(?:\d+(?:\.\d+)?|\.\d+)\s*$/
            && $rating > 0 && $rating <= 10)
        {
            my $display = 0 + $rating;
            if ($display == 10)
            {
                # El 10/10 tiene una estrella ligeramente mayor y glow CSS.
                $style->add_class('gcjav-rating-perfect');
                $label->set_markup(
                    "<span foreground=\"#FFE6A0\" weight=\"bold\" size=\"large\">\x{2605}</span>"
                  . "<span foreground=\"#FFDF78\" weight=\"bold\"> $display/10</span>");
            }
            else
            {
                # Umbrales amplios que admiten tambien ratings decimales.
                my $color = $display < 5 ? '#FF6B71'
                          : $display < 7 ? '#F7C95C'
                          :                '#78DE91';
                $label->set_markup(
                    "<span foreground=\"$color\" weight=\"bold\">\x{2605} $display/10</span>");
            }
            $label->show;
        }
        else
        {
            $label->set_text('');
            $label->hide;
        }
    }
}

# V7.2: resumen exclusivo de Biblioteca.
# No cambia el resumen del resto de vistas ni los campos guardados.
# En la ficha flotante omitimos Date / Assigned Tags y mostramos Cast.
sub refreshPopup
{
    my $self = shift;
    my $manager = $self->{dataManager};
    my $model = $self->{model};
    my $idx = $self->{info}->{idx};
    my $items = $manager->getItemsListFiltered;
    my $raw = defined($idx) && ref($items) eq 'ARRAY'
            ? $items->[$idx] : undef;
    return $self->SUPER::refreshPopup
        if !$raw || ref($raw) ne 'HASH';

    # Se llama tambien al guardar cambios desde la ficha; el rating
    # se actualiza aunque el motor no tenga que recargar la portada.
    $self->refreshBadges($raw);

    my $titleField = $model->{commonFields}->{title};
    my $title = $raw->{$titleField};
    $title = '' if !defined($title) || ref($title);
    my $markup = '<b>'.GCUtils::encodeEntities($title).'</b>';
    my $separator = $self->{container}->{parent}->{lang}->{Separator};
    $separator = ': ' if !defined $separator;

    my $cast = eval { $manager->transformValue($raw->{actors}, 'actors') };
    $cast = '' if !defined($cast) || ref($cast);
    $cast =~ s/^\s+|\s+$//g;
    my $castRow = length($cast)
        ? "\n<b>Cast$separator</b>".GCUtils::encodeEntities($cast) : '';
    my $castShown = 0;

    # Respetamos el orden y las traducciones de los otros campos del modelo.
    foreach my $field (@{$model->getSummaryFields})
    {
        next if $field eq 'date' || $field eq 'tags' || $field eq 'actors' || $field eq 'format';
        my $value = eval { $manager->transformValue($raw->{$field}, $field) };
        $value = '' if !defined($value) || ref($value);
        my $label = $model->getDisplayedLabel($field);
        $markup .= "\n<b>".GCUtils::encodeEntities($label).$separator
                 ."</b>".GCUtils::encodeEntities($value);
        if ($field eq 'director' && length $castRow)
        {
            $markup .= $castRow;
            $castShown = 1;
        }
    }
    $markup .= $castRow if length($castRow) && !$castShown;

    eval { $self->set_tooltip_markup($markup); 1 }
        or $self->set_tooltip_text($title);
}

sub refreshInfo
{
    my ($self, $info, $cacheRefresh) = @_;
    $self->setInfo($info);
    $self->refreshPopup;

    my $title = defined $info->{title} ? $info->{title} : '';
    my $code = '';
    my $displayTitle = $title;

    # Si el nombre empieza por un codigo (p.ej. GVH-110),
    # mostrarlo una sola vez y separar el titulo cuando exista.
    if ($title =~ /^\s*([A-Za-z]{2,10}[- ]?\d{2,7})\b/)
    {
        $code = uc($1);
        $displayTitle =~ s/^\s*\Q$1\E[\s:|\-]*//i;
        $displayTitle =~ s/^\s+|\s+$//g;
    }
    # En JavKT9 muchas peliculas tienen solo el codigo como Title;
    # el nombre descriptivo suele estar en Original (Alternative titles).
    my $original = $info->{javkt9OriginalTitle} || '';
    $original =~ s/\s+/ /g;
    $original =~ s/^\s+|\s+$//g;
    # Algunos titulos alternativos empiezan otra vez por GVH-100.
    # Evitar duplicar el codigo ya visible en la linea superior.
    $original =~ s/^\s*\Q$code\E(?:\s*[-:|]\s*|\s+)*//i if length($code);
    if (!length($displayTitle) && length($original))
    {
        $displayTitle = $original;
    }
    # Si el titulo no tenia un codigo con patron, usarlo como titulo,
    # sin inventar un ID nuevo ni duplicar el mismo texto.
    $self->{javkt9CardCode}->set_text($code);
    $self->{javkt9CardTitle}->set_text($displayTitle);
    if ($self->{style}->{obsidianWine}) {
        my $data = $self->{dataManager}->getItemsListFiltered;
        my $raw = ref($data) eq 'ARRAY' ? $data->[$self->{info}->{idx}] : undef;
        if (ref($raw) eq 'HASH') {
            my %fields = (
                javkt9CastLabel => GCLibraryList::_obsidianText($raw->{actors}),
                javkt9StudioLabel => GCLibraryList::_obsidianText($raw->{studio}),
                javkt9TagsLabel => GCLibraryList::_obsidianText($raw->{tags}),
            );
            foreach my $prop (keys %fields) {
                next if !$self->{$prop};
                my $value = $fields{$prop};
                $value =~ s/\s+/ /g;
                $value =~ s/^\s+|\s+$//g;
                $self->{$prop}->set_text($value);
                length($value) ? $self->{$prop}->show : $self->{$prop}->hide;
            }
        }
    }
    # Sin tooltip propio en el label: evitar competir con el resumen
    # de la tarjeta cuando el cursor pasa por la linea del titulo.
    # refreshPopup() ya registro el resumen completo como tooltip;
    # GTK3 administra su visibilidad con el retraso nativo.

    # V9.1: conservar el pixbuf de esta tarjeta si no cambio la portada.
    # V9.4: ademas reutilizar el mismo pixbuf decodificado entre tarjetas
    # que muestran el mismo archivo, con una cache LRU maxima de 16.
    my $source = $info->{picture};
    my $localSource = $source ? GCUtils::localName($source) : '';
    if (!$localSource || !-f $localSource)
    {
        $source = $self->{container}->{parent}->{defaultImage};
        $localSource = $source ? GCUtils::localName($source) : '';
    }
    my $signature = _javkt9CoverSignature($localSource);
    if (!$cacheRefresh && length($signature)
        && defined($self->{javkt9CoverSignature})
        && $self->{javkt9CoverSignature} eq $signature)
    {
        # Etiquetas, rating y tooltip ya quedaron actualizados arriba.
        return;
    }
    my $pixbuf;
    if (length($signature))
    {
        $pixbuf = $self->{container}->_javkt9SharedCoverPixbuf(
            $signature, $localSource, $cacheRefresh
        );
    }
    if ($pixbuf)
    {
        $self->{javkt9CardImage}->set_from_pixbuf($pixbuf);
        $self->{javkt9CoverSignature} = $signature;
    }
    else
    {
        $self->{javkt9CardImage}->clear;
        delete $self->{javkt9CoverSignature};
    }
}

# La marca contiene ruta + tamano + fecha de modificacion + inode.
# Si una imagen es reemplazada, el siguiente refresco la recarga.
# Un refresh de portada solicitado expresamente (cacheRefresh) fuerza
# la recarga incluso si la firma coincide.
sub _javkt9CoverSignature
{
    my ($path) = @_;
    return '' if !defined($path) || ref($path) || !length($path);
    my @st = stat($path);
    return '' if !@st || !-f _;
    return join("\x1f", $path, $st[0], $st[1], $st[7], $st[9]);
}

# El motor heredado llama estos metodos al seleccionar/desmarcar.
sub highlight
{
    my ($self) = @_;
    return if $self->{selected};
    $self->{selected} = 1;
    $self->get_style_context->add_class('gcjav-card-selected');
}

sub unhighlight
{
    my ($self) = @_;
    $self->{selected} = 0;
    $self->get_style_context->remove_class('gcjav-card-selected');
}

# Sin animaciones; la seleccion se hace con borde, no distorsionando la portada.
sub savePicture { }
sub restorePicture { }
sub startZoomAnimation { }
sub stopZoomAnimation { }

1;
