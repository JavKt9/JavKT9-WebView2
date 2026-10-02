package GCJavPersonFavoritesDialog;
use strict;
use warnings;
use utf8;
use Gtk3;

# Standalone GTK3 manager, ready for integration into the main menu.
# Parent is the JAVkt9 main window; storage is GCJavPersonFavorites.
sub show {
    my ($class, $parent, $store, $film) = @_;
    die 'Favorites store required' unless $store;
    my $dialog = Gtk3::Dialog->new('Favoritos de personas', $parent,
        [qw/modal destroy-with-parent/], 'gtk-close' => 'close');
    $dialog->set_default_size(520, 390);
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
        my $row = Gtk3::Box->new('horizontal',6);
        my $entry = Gtk3::Entry->new;
        $entry->set_placeholder_text('Nombre de la persona');
        my $add = Gtk3::Button->new_with_label('★ Agregar');
        my $remove = Gtk3::Button->new_with_label('Quitar seleccionado');
        $row->pack_start($entry,1,1,0);
        $row->pack_start($add,0,0,0);
        $row->pack_start($remove,0,0,0);
        $vbox->pack_start($row,0,0,0);
        if ($suggested->{$kind} && @{$suggested->{$kind}}) {
            my $hint = Gtk3::Label->new('Personas de la película actual:');
            $hint->set_xalign(0);
            $vbox->pack_start($hint,0,0,0);
            my $suggestions = Gtk3::ComboBoxText->new;
            $suggestions->append_text($_) for @{$suggested->{$kind}};
            $suggestions->signal_connect(changed => sub {
                my $name = $suggestions->get_active_text;
                $entry->set_text($name) if defined $name;
            });
            $vbox->pack_start($suggestions,0,0,0);
        }
        my $refresh = sub {
            $model->clear;
            for my $name (@{$store->list($kind)}) {
                my $iter = $model->append;
                $model->set($iter, 0, $name);
            }
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
