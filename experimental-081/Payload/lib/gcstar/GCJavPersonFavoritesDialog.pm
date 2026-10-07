package GCJavPersonFavoritesDialog;
use strict;
use warnings;
use utf8;
use Gtk3;

# Standalone GTK3 manager, ready for integration into the main menu.
# Parent is the JAVkt9 main window; storage is GCJavPersonFavorites.
sub show {
    my ($class, $parent, $store, $film, $all_films) = @_;
    $all_films = [] unless ref($all_films) eq 'ARRAY';
    die 'Favorites store required' unless $store;
    my $dialog = Gtk3::Dialog->new('Favoritos de personas', $parent,
        [qw/modal destroy-with-parent/], 'gtk-close' => 'close');
    $dialog->set_default_size(740, 620);
    my $area = $dialog->get_content_area;
    my $notebook = Gtk3::Notebook->new;
    my $suggested = {};
    if ($film && ref($film) eq 'HASH') {
        require GCJavPersonFavoritesAdapter;
        $suggested = GCJavPersonFavoritesAdapter::people_from_film($film);
    }
    $area->pack_start($notebook, 1, 1, 8);
    for my $tab (['actors','Actores favoritos'], ['directors','Directores favoritos']) {
        my ($kind,$title) = @$tab;
        my $vbox = Gtk3::Box->new('vertical', 8);
        $vbox->set_border_width(10);
        my $model = Gtk3::ListStore->new('Glib::String');
        my $view = Gtk3::TreeView->new($model);
        my $renderer = Gtk3::CellRendererText->new;
        $view->append_column(Gtk3::TreeViewColumn->new_with_attributes(
            'Nombre', $renderer, text => 0));
        my $scroll = Gtk3::ScrolledWindow->new;
        $scroll->set_policy('automatic','automatic');
        $scroll->add($view);
        $vbox->pack_start($scroll,1,1,0);
        my $matches_label = Gtk3::Label->new('Seleccioná una persona para ver sus películas en la colección');
        $matches_label->set_xalign(0);
        $vbox->pack_start($matches_label,0,0,0);
        my $films_model = Gtk3::ListStore->new('Glib::String', 'Glib::String', 'Glib::String');
        my $films_view = Gtk3::TreeView->new($films_model);
        for my $column (['Nº registro',0], ['Código JAV',1], ['Estado',2]) {
            my $r = Gtk3::CellRendererText->new;
            $films_view->append_column(Gtk3::TreeViewColumn->new_with_attributes($column->[0], $r, text => $column->[1]));
        }
        my $films_scroll = Gtk3::ScrolledWindow->new;
        $films_scroll->set_policy('automatic','automatic');
        $films_scroll->set_min_content_height(130);
        $films_scroll->add($films_view);
        $vbox->pack_start($films_scroll,1,1,0);

        # P9.2: doble clic en una película de Favoritos -> ir a su ficha.
        $films_view->signal_connect('row-activated' => sub {
            my ($tree,$path,$column)=@_;
            my $model=$tree->get_model;
            my $iter=$model->get_iter($path);
            return unless $iter;
            my $wanted_id=$model->get($iter,0);
            my $wanted_title=$model->get($iter,1);
            eval {
                my $items=$parent->{items}->getItemsListFiltered;
                my $target;
                for (my $i=0; $i<@$items; $i++) {
                    my $r=$items->[$i];
                    next unless ref($r) eq 'HASH';
                    my $rid=defined($r->{id}) && !ref($r->{id}) ? $r->{id} : '';
                    my $rtitle=defined($r->{title}) && !ref($r->{title}) ? $r->{title} : '';
                    if ((length($wanted_id) && $rid eq $wanted_id) ||
                        (length($wanted_title) && $rtitle eq $wanted_title)) {
                        $target=$i;
                        last;
                    }
                }
                die "No se encontró la película en la vista actual" unless defined $target;
                $parent->{items}->display($target);
                $parent->{itemsView}->select($target,1);
                $dialog->response('close');
                1;
            } or _error($dialog,$@);
        });

        $view->get_selection->signal_connect(changed => sub {
            $films_model->clear;
            my ($selected_model, $selected_iter) = $view->get_selection->get_selected;
            if (!$selected_iter) {
                $matches_label->set_text('Seleccioná una persona para ver sus películas en la colección');
                return;
            }
            my $person = $selected_model->get($selected_iter,0);
            require GCJavPersonFavoritesAdapter;
            my $count = 0;
            for my $record (@$all_films) {
                next unless ref($record) eq 'HASH';
                my $people = GCJavPersonFavoritesAdapter::people_from_film($record);
                my $normal = sub {
                    my ($s) = @_;
                    return '' if !defined($s) || ref($s);
                    $s = lc($s);
                    $s =~ s/\x{a0}/ /g;
                    $s =~ s/^\s+|\s+$//g;
                    $s =~ s/\s+/ /g;
                    return $s;
                };
                my $wanted = $normal->($person);
                my $found = grep { $normal->($_) eq $wanted } @{$people->{$kind} || []};
                if (!$found && $kind eq 'actors') {
                    my $raw = $record->{actors};
                    my @rows = ref($raw) eq 'ARRAY' ? @$raw : (defined($raw) ? $raw : ());
                    for my $row (@rows) {
                        my @names = ref($row) eq 'ARRAY' ? @$row :
                                    ref($row) eq 'HASH' ? values %$row :
                                    !ref($row) ? split(/[;,\n|]/, $row) : ();
                        if (grep { $normal->($_) eq $wanted } @names) {
                            $found = 1;
                            last;
                        }
                    }
                }
                next unless $found;
                my $iter = $films_model->append;
                my $code = defined($record->{id}) && !ref($record->{id}) ? $record->{id} : '';
                my $title = defined($record->{title}) && !ref($record->{title}) ? $record->{title} : '';
                my $seen = $record->{seen};
                my $is_seen = defined($seen) && !ref($seen) && $seen =~ /^(?:1|true|yes|si|sí)$/i;
                $films_model->set($iter, 0, $code, 1, $title, 2, $is_seen ? 'Vista' : 'Pendiente');
                $count++;
            }
            $matches_label->set_text("$person — $count película(s) en tu colección");
        });

        my $row = Gtk3::Box->new('horizontal',6);
        my $entry = Gtk3::Entry->new;
        $entry->set_placeholder_text('Nombre de la persona');
        my $add = Gtk3::Button->new_with_label('★ Agregar');
        my $remove = Gtk3::Button->new_with_label('Quitar seleccionado');
        $row->pack_start($entry,1,1,0);
        $row->pack_start($add,0,0,0);
        $row->pack_start($remove,0,0,0);
        $vbox->pack_start($row,0,0,0);
        my @star_buttons;
        if ($suggested->{$kind} && @{$suggested->{$kind}}) {
            my $hint = Gtk3::Label->new('Personas de la pelicula seleccionada (clic para marcar o desmarcar):');
            $hint->set_xalign(0);
            $vbox->pack_start($hint,0,0,0);
            for my $person (@{$suggested->{$kind}}) {
                my $button = Gtk3::Button->new;
                $button->set_halign('start');
                my $update_star = sub {
                    my $marked = $store->is_favorite($kind,$person);
                    $button->set_label(($marked ? '★  ' : '☆  ') . $person);
                };
                push @star_buttons, $update_star;
                $button->signal_connect(clicked => sub {
                    eval {
                        my $marked = $store->is_favorite($kind,$person);
                        $store->set_favorite($kind,$person,!$marked);
                        $update_star->();
                        $model->clear;
                        for my $name (@{$store->list($kind)}) {
                            my $iter = $model->append;
                            $model->set($iter, 0, $name);
                        }
                        1;
                    } or _error($dialog,$@);
                });
                eval { $update_star->(); 1 } or _error($dialog,$@);
                $vbox->pack_start($button,0,0,0);
            }
        }
        my $refresh = sub {
            $model->clear;
            for my $name (@{$store->list($kind)}) {
                my $iter = $model->append;
                $model->set($iter, 0, $name);
            }
            for my $update (@star_buttons) { $update->(); }
        };
        $add->signal_connect(clicked => sub {
            my $name = $entry->get_text;
            $name =~ s/^\s+|\s+$//g;
            return unless length $name;
            eval { $store->set_favorite($kind,$name,1); $refresh->(); $entry->set_text(''); 1 }
                or _error($dialog, $@);
        });
        $remove->signal_connect(clicked => sub {
            my ($model_selected,$iter) = $view->get_selection->get_selected;
            return unless $iter;
            my $name = $model_selected->get($iter,0);
            eval { $store->set_favorite($kind,$name,0); $refresh->(); 1 }
                or _error($dialog, $@);
        });
        eval { $refresh->(); 1 } or _error($dialog,$@);
        $notebook->append_page($vbox,Gtk3::Label->new($title));
    }
    $dialog->show_all;
    $dialog->run;
    $dialog->destroy;
}
sub _error {
    my ($parent,$message)=@_;
    my $d = Gtk3::MessageDialog->new($parent,[qw/modal destroy-with-parent/],
        'error','ok',"No se pudieron actualizar los favoritos:\n$message");
    $d->run;
    $d->destroy;
}
1;
