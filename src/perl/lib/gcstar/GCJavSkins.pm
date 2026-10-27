package GCJavSkins;
use strict;
use warnings;
use utf8;
use Gtk3;
use File::Spec;
use File::Path qw(make_path);

my @ORDER = (
    'Dark Purple',
    'Midnight Blue',
    'Silver Light',
    'Pink Pulse',
    'Obsidian Cyan',
    'Noir Gold',
    'Sakura Crimson',
);

my %PALETTES = (
    'Dark Purple'   => ['#17121F','#211A2D','#2A2139','#EDE8F5','#8F5BC8','#AF82E5','#3A3049','#16111E','#B7A8C9'],
    'Midnight Blue' => ['#101925','#19283A','#21354A','#EAF1F9','#428BD4','#76B5EE','#30465B','#101F2E','#AFC1D5'],
    'Silver Light'  => ['#F3F6FB','#E7EEF6','#FFFFFF','#203246','#2B7DE9','#67A9FF','#C2D1E0','#FFFFFF','#66798F'],
    'Pink Pulse'    => ['#120B16','#241127','#2A1730','#FCECF8','#FF2E93','#FF66B2','#6A2452','#110914','#D4B2C5'],
    'Obsidian Cyan' => ['#071018','#0D1823','#111F2C','#E8F6FF','#18BFEA','#48D5FF','#26384A','#09131C','#8CB1C8'],
    'Noir Gold'     => ['#090909','#141414','#1C1C1C','#F6F1CF','#E7C64A','#FFD95E','#4B421E','#0D0D0D','#BDAF71'],
    'Sakura Crimson'=> ['#120708','#1F0D12','#2A1118','#FFF1F4','#E63E63','#FF7DA1','#6E2435','#14080A','#D8A4B0'],
);

my %PANEL_PROFILES = (
    'Dark Purple' => {
        page     => { bg => '#1A1423' },
        label    => { bg => '#8F5BC8', color => '#FFFFFF' },
        field    => { bg => '#241B31', color => '#EFEAFA' },
        expander => { bg => '#20182C', color => '#EFEAFA', arrow => '#C8AEF6', prelight => '#2A2038' },
    },
    'Midnight Blue' => {
        page     => { bg => '#121B27' },
        label    => { bg => '#428BD4', color => '#FFFFFF' },
        field    => { bg => '#1A2837', color => '#EAF1F9' },
        expander => { bg => '#162231', color => '#EAF1F9', arrow => '#84BFF4', prelight => '#203247' },
    },
    'Silver Light' => {
        page     => { bg => '#F5F8FC' },
        label    => { bg => '#DDE8F4', color => '#203246' },
        field    => { bg => '#FFFFFF', color => '#203246' },
        expander => { bg => '#EAF1F8', color => '#203246', arrow => '#2B7DE9', prelight => '#DCE8F5' },
    },
    'Pink Pulse' => {
        page     => { bg => '#160C18' },
        label    => { bg => '#FF2E93', color => '#FFFFFF' },
        field    => { bg => '#25122A', color => '#FCECF8' },
        expander => { bg => '#1E0F22', color => '#FCECF8', arrow => '#FF9CCC', prelight => '#2A1530' },
    },
    'Obsidian Cyan' => {
        page     => { bg => '#0A131C' },
        label    => { bg => '#18BFEA', color => '#05131A' },
        field    => { bg => '#12212F', color => '#E8F6FF' },
        expander => { bg => '#0E1A25', color => '#E8F6FF', arrow => '#65DEFF', prelight => '#162736' },
    },
    'Noir Gold' => {
        page     => { bg => '#0C0C0C' },
        label    => { bg => '#E7C64A', color => '#16120A' },
        field    => { bg => '#1A1A1A', color => '#F6F1CF' },
        expander => { bg => '#141414', color => '#F6F1CF', arrow => '#FFD95E', prelight => '#202020' },
    },
    'Sakura Crimson' => {
        page     => { bg => '#15080B' },
        label    => { bg => '#E63E63', color => '#FFFFFF' },
        field    => { bg => '#241015', color => '#FFF1F4' },
        expander => { bg => '#1D0C10', color => '#FFF1F4', arrow => '#FF9BB4', prelight => '#2A1118' },
    },
);

my $provider;
my $active = 'Dark Purple';

sub _file {
    my $profile = $ENV{JAVKT9_PROFILE_DIR} || 'JavKT9-081-RC1-Publica-Publica';
    my $home = File::Spec->catdir($ENV{APPDATA} || $ENV{LOCALAPPDATA} || '.', $profile);
    return File::Spec->catfile($home, 'GCJavSkin.conf');
}

sub current {
    my $path = _file();
    if (open(my $fh, '<', $path)) {
        my $name = <$fh> // '';
        close $fh;
        $name =~ s/[
]+$//;
        return $name if exists $PALETTES{$name};
    }
    return 'Dark Purple';
}

sub available { return @ORDER; }

sub adjust_panel_styles {
    my ($styles, $choice) = @_;
    return $styles if ! $styles;
    $choice = current() unless defined $choice;
    my $profile = $PANEL_PROFILES{$choice};
    return $styles if ! $profile;

    foreach my $comp (keys %{$profile}) {
        $styles->{$comp} ||= {};
        foreach my $k (keys %{$profile->{$comp}}) {
            $styles->{$comp}->{$k} = $profile->{$comp}->{$k};
        }
    }

    foreach my $comp (keys %{$styles}) {
        if (exists $styles->{$comp}->{bg}) {
            $styles->{$comp}->{bgColor} = Gtk3::Gdk::RGBA::parse($styles->{$comp}->{bg});
        }
        if (exists $styles->{$comp}->{color}) {
            my $style = $styles->{$comp}->{style} || '';
            $style =~ s/\s*foreground='[^']*'//g;
            $styles->{$comp}->{style} = $style . " foreground='" . $styles->{$comp}->{color} . "'";
        }
    }
    return $styles;
}

sub _css {
    my ($name) = @_;
    my ($bg,$panel,$field,$fg,$accent,$hover,$border,$list,$muted) = @{$PALETTES{$name}};
    my $silver_fields = '';
    if ($name eq 'Silver Light') {
        $silver_fields = q{
          entry, spinbutton, spinbutton entry, textview, textview text {
              background-image: none;
              background-color: #FFFFFF;
              color: #203246;
              border-color: #B8CADC;
          }
          entry selection, textview text selection {
              background-color: #2B7DE9;
              color: #FFFFFF;
          }
        };
    }
    # Like the custom chrome on Favorites / Preview / About, but scoped to Appearance.
    my $accent_text = ($name eq 'Obsidian Cyan' || $name eq 'Noir Gold') ? '#101317' : '#FFFFFF';
    return qq{
      * { font-family: "Segoe UI", "Arial", sans-serif; font-size: 10.5pt; color: $fg; }
      window, dialog, .background, #GCFormPanel, #GCReadOnlyPanel, viewport, paned, stack { background-color: $bg; color: $fg; }
      box, grid { color: $fg; }
      menubar, toolbar, statusbar, #GCMenubar { background-image: none; background-color: $panel; border-color: $border; }
      menubar > menuitem { padding: 6px 10px; }
      menu, popover { background-color: $panel; border: 1px solid $border; }
      menuitem { padding: 6px 12px; }
      menuitem:hover { background-color: $accent; color: #FFFFFF; }
      toolbar { padding: 6px; border-bottom: 1px solid $border; }
      button, toolbar button { background-image: none; background-color: $field; color: $fg; border: 1px solid $border; border-radius: 5px; padding: 5px 9px; }
      button:hover { background-color: $hover; border-color: $accent; color: #FFFFFF; }
      button:active, button:checked { background-color: $accent; color: #FFFFFF; }
      entry, spinbutton, combobox, textview, treeview, .view { background-color: $field; color: $fg; border-color: $border; }
      entry, spinbutton { min-height: 28px; border-radius: 4px; padding: 2px 7px; }
      textview text { background-color: $field; color: $fg; }
      treeview { background-color: $list; color: $fg; }
      treeview:selected, treeview row:selected { background-color: $accent; color: #FFFFFF; }
      treeview header button { background-color: $panel; border-radius: 0; border-color: $border; }
      notebook { background-color: $bg; }
      notebook > header { background-color: $panel; border-bottom: 1px solid $border; }
      notebook > header > tabs > tab { background-color: $panel; border: 0; padding: 8px 14px; min-height: 28px; }
      notebook > header > tabs > tab:checked { background-color: $accent; color: #FFFFFF; border-bottom: 3px solid $hover; }
      notebook > header > tabs > tab:hover { background-color: $field; }
      frame { border-color: $border; }
      expander { padding: 3px; }
      scrollbar trough { background-color: $bg; }
      scrollbar slider { background-color: $border; border-radius: 8px; min-width: 8px; min-height: 8px; }
      separator { background-color: $border; }
      progressbar progress { background-color: $accent; }
      label:disabled, menuitem:disabled, .dim-label { color: $muted; }
      $silver_fields
      #GCJavTitleBar { background-image: none; background-color: $accent; color: #FFFFFF; border: 0; box-shadow: none; }
      #GCJavTitleBar label { color: #FFFFFF; font-weight: bold; }
      #GCJavTitleBar button { background-image: none; background-color: $panel; color: #FFFFFF; border-color: $border; }
      #GCJavTitleBar button:hover { background-color: $hover; }

      /* RC2-A1: dedicated Appearance-dialog styling. No global selectors changed. */
      #GCJavAppearanceDialog { background-color: $bg; color: $fg; }
      #GCJavAppearanceDialog box, #GCJavAppearanceDialog grid,
      #GCJavAppearanceDialog label { color: $fg; }
      #GCJavAppearanceDialog combobox,
      #GCJavAppearanceDialog combobox button {
          background-image: none; background-color: $field;
          color: $fg; border-color: $border;
      }
      #GCJavAppearanceDialog combobox button label,
      #GCJavAppearanceDialog combobox arrow { color: $fg; }
      #GCJavAppearanceDialog button {
          background-image: none; background-color: $field;
          color: $fg; border: 1px solid $border;
      }
      #GCJavAppearanceDialog button:hover {
          background-color: $hover; color: $accent_text; border-color: $accent;
      }
      #GCJavAppearanceDialog button:active {
          background-color: $accent; color: $accent_text;
      }
      #GCJavAppearanceTitleBar {
          background-image: none; background-color: $accent;
          color: $accent_text; border: 0; box-shadow: none;
      }
      #GCJavAppearanceTitleBar label { color: $accent_text; font-weight: bold; }
      #GCJavAppearanceTitleBar button {
          background-image: none; background-color: $panel;
          color: $fg; border: 1px solid $border;
      }
      #GCJavAppearanceTitleBar button:hover {
          background-color: $hover; color: $accent_text;
      }
    };
}

sub apply {
    my ($window, $choice) = @_;
    $choice = current() unless defined $choice;
    $choice = 'Dark Purple' unless exists $PALETTES{$choice};
    my $screen = $window->get_screen;
    if ($provider) { Gtk3::StyleContext::remove_provider_for_screen($screen, $provider); }
    my $new_provider = Gtk3::CssProvider->new;
    $new_provider->load_from_data(_css($choice));
    Gtk3::StyleContext::add_provider_for_screen($screen, $new_provider, 900);
    $provider = $new_provider;
    $active = $choice;
    return 1;
}

sub _save {
    my ($name) = @_;
    my $path = _file();
    my ($volume, $dir) = (File::Spec->splitpath($path))[0,1];
    make_path(File::Spec->catpath($volume,$dir,'')) unless -d File::Spec->catpath($volume,$dir,'');
    my $tmp = "$path.tmp";
    open(my $fh,'>',$tmp) or die "No se puede guardar configuración: $!";
    print {$fh} "$name
";
    close($fh) or die "Error al guardar configuración: $!";
    unlink($path) if -e $path;
    rename($tmp,$path) or die "No se puede actualizar configuración: $!";
}

sub choose {
    my ($window) = @_;
    my $dialog = Gtk3::Dialog->new('Apariencia de JAVkt9', $window, [qw/modal destroy-with-parent/], 'Cancelar'=>'cancel', 'Aplicar'=>'ok');
    $dialog->set_default_size(430,220);
    $dialog->set_name('GCJavAppearanceDialog');

    # Use the same proven Gtk3 HeaderBar approach as the other skinned dialogs.
    # If a particular GTK build lacks this feature, keep the native titlebar.
    if ($^O =~ /win32/i) {
        eval {
            my $header = Gtk3::HeaderBar->new;
            $header->set_show_close_button(1);
            $header->set_has_subtitle(0);
            $header->set_size_request(-1, 36);
            $header->set_name('GCJavAppearanceTitleBar');
            $header->set_title('Apariencia de JAVkt9');
            $dialog->set_titlebar($header);
            1;
        } or warn "RC2-A1 appearance titlebar unavailable: $@";
    }

    my $box = $dialog->get_content_area;
    $box->set_border_width(16);
    $box->set_spacing(12);

    my $label = Gtk3::Label->new('Elegí un skin para toda la aplicación:');
    $label->set_xalign(0);
    $box->pack_start($label,0,0,0);

    my $hint = Gtk3::Label->new('Se aplicará a la ventana principal, Favoritos y Vista previa.');
    $hint->set_xalign(0);
    $box->pack_start($hint,0,0,0);

    my $combo = Gtk3::ComboBoxText->new;
    my @names = available();
    $combo->append_text($_) for @names;
    my $selected = current();
    for my $i (0..$#names) { $combo->set_active($i) if $names[$i] eq $selected; }
    $box->pack_start($combo,0,0,0);

    $dialog->show_all;
    if ($dialog->run eq 'ok') {
        my $name = $combo->get_active_text;
        if (defined $name && exists $PALETTES{$name}) {
            eval { _save($name); apply($window,$name); 1 } or do {
                my $error = $@ || 'Error desconocido';
                my $warning = Gtk3::MessageDialog->new($dialog,[qw/modal destroy-with-parent/],'error','ok',"No se pudo aplicar el skin: $error");
                $warning->run;
                $warning->destroy;
            };
        }
    }
    $dialog->destroy;
}

1;
