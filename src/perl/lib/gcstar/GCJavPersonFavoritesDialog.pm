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
    # P11.6: theme only; safe fallback to stock dialog when styling is unavailable.
    eval {
        require GCJavDialogSkins;
        GCJavDialogSkins::decorate($dialog, 'favorites');
        1;
    } or warn "P11.6 favorites appearance: $@";
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

        # P10: doble clic en una película -> vista previa; desde allí se puede ir a la ficha.
        $films_view->signal_connect('row-activated' => sub {
            my ($tree,$path,$column)=@_;
            my $model=$tree->get_model;
            my $iter=$model->get_iter($path);
            return unless $iter;
            my $wanted_id=$model->get($iter,0);
            my $wanted_title=$model->get($iter,1);
            eval {
                # P10.1: preview data comes from the full collection record.
                # The filtered list is used only to preserve P9.2 "Ir a la ficha".
                my $record;
                for my $r (@$all_films) {
                    next unless ref($r) eq 'HASH';
                    my $rid=defined($r->{id}) && !ref($r->{id}) ? $r->{id} : '';
                    my $rtitle=defined($r->{title}) && !ref($r->{title}) ? $r->{title} : '';
                    if ((length($wanted_id) && $rid eq $wanted_id) ||
                        (length($wanted_title) && $rtitle eq $wanted_title)) {
                        $record=$r; last;
                    }
                }
                die "No se encontró la película en la colección" unless $record;

                my $items=$parent->{items}->getItemsListFiltered;
                my $target;
                for (my $i=0; $i<@$items; $i++) {
                    my $r=$items->[$i];
                    next unless ref($r) eq 'HASH';
                    my $rid=defined($r->{id}) && !ref($r->{id}) ? $r->{id} : '';
                    my $rtitle=defined($r->{title}) && !ref($r->{title}) ? $r->{title} : '';
                    if ((length($wanted_id) && $rid eq $wanted_id) ||
                        (length($wanted_title) && $rtitle eq $wanted_title)) {
                        $target=$i; last;
                    }
                }

                my $preview=Gtk3::Dialog->new('Vista previa de película',$dialog,
                    [qw/modal destroy-with-parent/],
                    'Ir a la ficha' => 'apply',
                    'Cerrar' => 'close');
                $preview->set_default_size(580,380);
                # P11.6: apply exactly the same saved skin as the main window.
                eval {
                    require GCJavDialogSkins;
                    GCJavDialogSkins::decorate($preview, 'preview');
                    1;
                } or warn "P11.6 preview appearance: $@";
                my $box=$preview->get_content_area;
                $box->set_border_width(14);
                my $grid=Gtk3::Grid->new;
                $grid->set_row_spacing(9);
                $grid->set_column_spacing(16);
                my $row=0;
                my $add_field=sub {
                    my ($label,$value)=@_;
                    $value='' if !defined($value) || ref($value);
                    my $l=Gtk3::Label->new($label);
                    $l->set_xalign(0);
                    my $v=Gtk3::Label->new($value);
                    $v->set_xalign(0);
                    $v->set_line_wrap(1);
                    $v->set_selectable(1);
                    $grid->attach($l,0,$row,1,1);
                    $grid->attach($v,1,$row,1,1);
                    $row++;
                };
                $add_field->('Código JAV:', $record->{title});
                $add_field->('Nº registro:', $record->{id});
                my $display_title = defined($record->{originalTitle}) && !ref($record->{originalTitle}) ? $record->{originalTitle} :
                                    defined($record->{name}) && !ref($record->{name}) ? $record->{name} : '';
                $add_field->('Título:', $display_title) if length($display_title);
                require GCJavPersonFavoritesAdapter;
                my $people=GCJavPersonFavoritesAdapter::people_from_film($record);

                # Actors in GCfilms can be nested arrays/hashes. Flatten them exactly
                # for display instead of assuming a plain scalar list.
                my @actors;
                my @pending = ($record->{actors});
                while (@pending) {
                    my $v=shift @pending;
                    next unless defined $v;
                    if (ref($v) eq 'ARRAY') { unshift @pending, @$v; next; }
                    if (ref($v) eq 'HASH')  { unshift @pending, values %$v; next; }
                    next if ref($v);
                    push @actors, split(/[;,\n|]/,$v);
                }
                my %actor_seen;
                @actors=grep {
                    s/^\s+|\s+$//g;
                    length($_) && !$actor_seen{lc($_)}++;
                } @actors;

                $add_field->('Director:', join(', ',@{$people->{directors} || []}));
                $add_field->('Actrices / modelos:', join(', ',@actors));
                my $seen=$record->{seen};
                my $is_seen=defined($seen) && !ref($seen) && $seen =~ /^(?:1|true|yes|si|sí)$/i;
                $add_field->('Estado:', $is_seen ? 'Vista' : 'Pendiente');

                # Cover: use the same collection image field and path transformation
                # already used by JAVkt9 itself.
                my $body=Gtk3::Box->new('horizontal',18);
                my $cover_box=Gtk3::Box->new('vertical',0);
                # P10.3: cover field is model-dependent; resolve through the
                # same GCUtils display-image resolver used by JAVkt9.
                my $cover_field=eval { $parent->{model}->{commonFields}->{cover} } || '';
                my @fields=grep { length($_) } ($cover_field, qw(image picture cover));
                my %visited;
                my @paths;
                for my $field (@fields) {
                    next if $visited{$field}++;
                    my $value=$record->{$field};
                    next unless defined $value;
                    my @values=ref($value) eq 'ARRAY' ? @$value : ($value);
                    for my $v (@values) {
                        $v=$v->[0] if ref($v) eq 'ARRAY' && @$v;
                        next if !defined($v) || ref($v) || !length($v);
                        push @paths,$v;
                        my $display=eval {
                            require GCUtils;
                            GCUtils::getDisplayedImage($v,$v,$parent->{options}->file);
                        };
                        push @paths,$display if defined($display) && !ref($display) && length($display);
                        my $transformed=eval { $parent->transformPicturePath($v) };
                        push @paths,$transformed if defined($transformed) && !ref($transformed) && length($transformed);
                    }
                }
                my $pix;
                for my $candidate (@paths) {
                    next unless defined($candidate) && !ref($candidate);
                    my @tries=($candidate);
                    my $file=eval { $parent->{options}->file } || '';
                    if (length($file)) {
                        require File::Basename;
                        require File::Spec;
                        push @tries, File::Spec->catfile(File::Basename::dirname($file),$candidate);
                    }
                    for my $path (@tries) {
                        next unless -f $path;
                        $pix=eval { Gtk3::Gdk::Pixbuf->new_from_file($path) };
                        last if $pix;
                    }
                    last if $pix;
                }
                if ($pix) {

                        my ($w,$h)=($pix->get_width,$pix->get_height);
                        my ($nw,$nh)=($w,$h);
                        my $maxw=220; my $maxh=310;
                        my $ratio=1;
                        $ratio=$maxw/$w if $w>$maxw;
                        $ratio=$maxh/$h if $h*$ratio>$maxh;
                        if ($ratio < 1) {
                            $nw=int($w*$ratio); $nh=int($h*$ratio);
                            $pix=$pix->scale_simple($nw,$nh,'bilinear');
                        }
                        my $img=Gtk3::Image->new_from_pixbuf($pix);
                        $img->set_valign('start');
                        $cover_box->pack_start($img,0,0,0);
                }
                if (!scalar($cover_box->get_children)) {
                    my $no=Gtk3::Label->new('Sin portada');
                    $no->set_valign('start');
                    $cover_box->pack_start($no,0,0,0);
                }
                $body->pack_start($cover_box,0,0,0);
                $body->pack_start($grid,1,1,0);
                $box->pack_start($body,1,1,0);
                $preview->show_all;
                my $response=$preview->run;
                $preview->destroy;
                if ($response eq 'apply') {
                    die "No se encontró la película en la vista actual" unless defined $target;
                    $parent->{items}->display($target);
                    $parent->{itemsView}->select($target,1);
                    $dialog->response('close');
                }
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
