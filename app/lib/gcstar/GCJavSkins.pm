package GCJavSkins;
use strict;
use warnings;
use utf8;
use Gtk3;
use File::Spec;
use File::Path qw(make_path);

my @ORDER = (
    'KT9V1',
    'Obsidiana',
    'Zafiro',
    'Esmeralda',
    'Carmesí',
    'Marfil',
    'Dark Purple',
    'Midnight Blue',
    'Silver Light',
    'Pink Pulse',
    'Obsidian Cyan',
    'Noir Gold',
    'Sakura Crimson',
);

my %PALETTES = (
    'Obsidiana' => ['#120E18','#1D1523','#261B2B','#F6EAF4','#9C2866','#E64C9A','#463249','#120E18','#BEA8BC'],
    'Zafiro'    => ['#06111E','#0A2036','#102D46','#E5F3FF','#1764BD','#40B7F1','#254966','#071A2B','#98B6D0'],
    'Esmeralda' => ['#071710','#0B241A','#103426','#E5FDF2','#018659','#24C997','#21533F','#071B14','#9ACBB7'],
    'Carmesí'   => ['#130A0E','#241015','#31151D','#FFF0F1','#BA2944','#F25169','#67303A','#160A10','#D2AAB0'],
    'Marfil'    => ['#F7F0E8','#EEE2D6','#FFFCF8','#37271F','#8B552D','#C58B62','#D2B8A3','#FCF7F2','#786B62'],
    'KT9V1' => ['#111015','#1B171E','#231D25','#EEEAF0','#85223F','#A83A59','#3E303A','#151217','#AFA3AD'],
    'Dark Purple'   => ['#17121F','#211A2D','#2A2139','#EDE8F5','#8F5BC8','#AF82E5','#3A3049','#16111E','#B7A8C9'],
    'Midnight Blue' => ['#101925','#19283A','#21354A','#EAF1F9','#428BD4','#76B5EE','#30465B','#101F2E','#AFC1D5'],
    'Silver Light'  => ['#F3F6FB','#E7EEF6','#FFFFFF','#203246','#2B7DE9','#67A9FF','#C2D1E0','#FFFFFF','#66798F'],
    'Pink Pulse'    => ['#120B16','#241127','#2A1730','#FCECF8','#FF2E93','#FF66B2','#6A2452','#110914','#D4B2C5'],
    'Obsidian Cyan' => ['#071018','#0D1823','#111F2C','#E8F6FF','#18BFEA','#48D5FF','#26384A','#09131C','#8CB1C8'],
    'Noir Gold'     => ['#090909','#141414','#1C1C1C','#F6F1CF','#E7C64A','#FFD95E','#4B421E','#0D0D0D','#BDAF71'],
    'Sakura Crimson'=> ['#120708','#1F0D12','#2A1118','#FFF1F4','#E63E63','#FF7DA1','#6E2435','#14080A','#D8A4B0'],
);

my %PANEL_PROFILES = (
    'Obsidiana' => {
        page => { bg => '#120E18' },
        label => { bg => '#692047', color => '#FFFFFF' },
        field => { bg => '#261B2B', color => '#F6EAF4' },
        expander => { bg => '#1D1523', color => '#F6EAF4', arrow => '#E64C9A', prelight => '#33243A' },
    },
    'Zafiro' => {
        page => { bg => '#06111E' },
        label => { bg => '#1764BD', color => '#FFFFFF' },
        field => { bg => '#102D46', color => '#E5F3FF' },
        expander => { bg => '#0A2036', color => '#E5F3FF', arrow => '#40B7F1', prelight => '#173B59' },
    },
    'Esmeralda' => {
        page => { bg => '#071710' },
        label => { bg => '#018659', color => '#FFFFFF' },
        field => { bg => '#103426', color => '#E5FDF2' },
        expander => { bg => '#0B241A', color => '#E5FDF2', arrow => '#24C997', prelight => '#1C4835' },
    },
    'Carmesí' => {
        page => { bg => '#130A0E' },
        label => { bg => '#BA2944', color => '#FFFFFF' },
        field => { bg => '#31151D', color => '#FFF0F1' },
        expander => { bg => '#241015', color => '#FFF0F1', arrow => '#F25169', prelight => '#421D29' },
    },
    'Marfil' => {
        page => { bg => '#F7F0E8' },
        label => { bg => '#E6D1BE', color => '#37271F' },
        field => { bg => '#FFFCF8', color => '#37271F' },
        expander => { bg => '#EEE2D6', color => '#37271F', arrow => '#8B552D', prelight => '#E6D1BE' },
    },
    'KT9V1' => {
        page => { bg => '#141116' },
        label => { bg => '#692038', color => '#FFF4F8' },
        field => { bg => '#211C24', color => '#EEEAF0' },
        expander => { bg => '#19151C', color => '#EEEAF0', arrow => '#C77894', prelight => '#30212D' },
    },
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
my $active = 'KT9V1';

sub _file {
    my $profile = 'JavKT9';
    my $appdata = $ENV{APPDATA} || $ENV{LOCALAPPDATA} || '.';
    # Cygwin recibe una ruta de Windows: convertirla antes de File::Spec.
    # Asi el proceso Perl y el lanzador Win32 comparten GCJavSkin.conf.
    if ($^O =~ /cygwin/i && $appdata =~ m{\A[A-Za-z]:[\\/]}) {
        $appdata = Cygwin::win_to_posix_path($appdata);
    }
    my $home = File::Spec->catdir($appdata, $profile);
    return File::Spec->catfile($home, 'GCJavSkin.conf');
}

# JavKT9 0.9.9 - modos de interfaz independientes de la paleta.
# Un mismo programa y una misma biblioteca; cada modo recuerda sus colores.
my %MODE_THEMES = (
    clasico => ['Silver Light', 'Marfil', 'Midnight Blue', 'Dark Purple',
                'Obsidiana', 'Zafiro', 'Esmeralda', 'Carmesí', 'Noir Gold', 'Pink Pulse'],
    v1      => ['Dark Purple', 'Midnight Blue', 'Silver Light', 'Pink Pulse',
                'Obsidian Cyan', 'Noir Gold', 'Sakura Crimson'],
    v2      => ['KT9V1', 'Obsidiana', 'Zafiro', 'Esmeralda', 'Carmesí', 'Marfil'],
);
my %MODE_LABELS = (
    clasico => 'Clásica',
    v1      => 'Moderna V1',
    v2      => 'Moderna V2',
);
# Solo etiquetas visibles; las claves originales permanecen intactas en el perfil.
my %THEME_LABELS = (
    'KT9V1'         => 'Original',
    'Dark Purple'   => 'Púrpura oscuro',
    'Midnight Blue' => 'Azul medianoche',
    'Silver Light'  => 'Plata claro',
    'Pink Pulse'    => 'Rosa intenso',
    'Obsidian Cyan' => 'Cian oscuro',
    'Noir Gold'     => 'Negro y dorado',
    'Sakura Crimson'=> 'Carmesí sakura',
);
my $runtime_mode;

sub _appearance_file {
    my $path = _file();
    $path =~ s/GCJavSkin\.conf\z/GCJavAppearance099.conf/;
    return $path;
}

sub _legacy_current {
    my $path = _file();
    if (open(my $fh, '<:encoding(UTF-8)', $path)) {
        my $name = <$fh> // '';
        close $fh;
        $name =~ s/[\r\n]+\z//;
        return $name if exists $PALETTES{$name};
    }
    return 'KT9V1';
}

sub _mode_for_view {
    my ($view) = @_;
    return 'v2' if defined($view) && $view == 4;
    return 'v1' if defined($view) && $view == 3;
    return 'clasico';
}

sub _mode_theme_valid {
    my ($mode, $name) = @_;
    return 0 unless defined($name) && exists $MODE_THEMES{$mode};
    foreach my $allowed (@{$MODE_THEMES{$mode}}) {
        return 1 if $allowed eq $name;
    }
    return 0;
}

sub _appearance_defaults {
    return {
        mode => 'v2',
        clasico => 'Silver Light',
        v1 => 'Midnight Blue',
        v2 => 'KT9V1',
        classic_view => 2,
    };
}

sub _read_appearance {
    my $path = _appearance_file();
    return undef unless -f $path;
    my $saved = _appearance_defaults();
    open(my $fh, '<:encoding(UTF-8)', $path) or return undef;
    while (my $line = <$fh>) {
        $line =~ s/[\r\n]+\z//;
        my ($key,$value) = split /=/, $line, 2;
        next unless defined($key) && defined($value);
        if ($key eq 'mode' && exists($MODE_THEMES{$value})) {
            $saved->{mode} = $value;
        }
        elsif ($key eq 'classic_view' && $value =~ /^[012]$/) {
            $saved->{classic_view} = $value;
        }
        elsif (exists($MODE_THEMES{$key}) && _mode_theme_valid($key,$value)) {
            $saved->{$key} = $value;
        }
    }
    close $fh;
    return $saved;
}

sub _save_appearance {
    my ($settings) = @_;
    my $path = _appearance_file();
    my ($volume,$dir) = (File::Spec->splitpath($path))[0,1];
    my $folder = File::Spec->catpath($volume,$dir,'');
    make_path($folder) unless -d $folder;
    my $temp = "$path.tmp.$$";
    open(my $fh, '>:encoding(UTF-8)', $temp)
        or die "No se puede guardar apariencia 0.9.9: $!";
    foreach my $key (qw(mode clasico v1 v2 classic_view)) {
        print {$fh} "$key=$settings->{$key}\n";
    }
    close($fh) or die "No se pudo cerrar apariencia 0.9.9: $!";
    if (!rename($temp,$path)) {
        # En Windows, rename no reemplaza el destino: conservar respaldo previo.
        my $old = "$path.previous";
        unlink($old) if -e $old;
        if (-e $path) {
            rename($path,$old)
                or die "No se pudo preparar el perfil anterior: $!";
        }
        if (!rename($temp,$path)) {
            rename($old,$path) if -e $old;
            die "No se pudo activar apariencia 0.9.9: $!";
        }
    }
    return 1;
}

# Se llama al comienzo de GCMainWindow::init, antes de construir las listas.
sub startup_view {
    my ($previous_view) = @_;
    my $stored = _read_appearance();
    if (!$stored) {
        $runtime_mode = _mode_for_view($previous_view);
        return $previous_view;
    }
    $runtime_mode = $stored->{mode};
    return 4 if $runtime_mode eq 'v2';
    return 3 if $runtime_mode eq 'v1';
    return $stored->{classic_view};
}

sub current_mode {
    return $runtime_mode if defined $runtime_mode;
    my $stored = _read_appearance();
    return $stored ? $stored->{mode} : 'v2';
}

sub current {
    my $stored = _read_appearance();
    return $stored->{$stored->{mode}} if $stored;
    return _legacy_current();
}

sub available { return @ORDER; }

sub uses_kt9v1_layout {
    return current_mode() eq 'v2' ? 1 : 0;
}

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
    # Colores de maqueta KT9V1. La distribucion es unica; cambia la paleta.
    my $light = ($name eq 'Marfil') ? 1 : 0;
    my $nav_bg = $light ? '#F5EBE2' : $bg;
    my $nav_hover = $light ? '#EAD4C4' : $field;
    my $nav_active = $light ? '#E6D1BE' : $panel;
    my $card_selected = $light ? '#F4E4D5' : $field;
    my $card_title = $light ? '#37271F' : $fg;
    my $action_text = '#FFFFFF';
    my $wine_css = $name eq 'KT9V1' ? q{
      /* KT9V1 — elementos del diseño de referencia, solo en el skin nuevo. */
      #GCJavSidebar { background-color: #151116; border-right: 1px solid #30252F; }
      #GCJavSidebarHeader { background-color: #151116; color: #C991A4; font-size: 14pt; font-weight: bold; }
      #GCJavSidebar button { background-color: transparent; color: #D8D1DA;
           border: 0; border-radius: 6px; padding: 10px 14px; }
      #GCJavSidebar button:hover { background-color: #30202C; color: #FFFFFF; }
      #GCJavSidebar button.gcjav-nav-active { background-color: #542036; color: #FFFFFF;
           border-left: 3px solid #B94B70; font-weight: bold; }
      #GCJavSidebarSeparator { background-color: #382933; }
      #GCJavSidebarFooter { color: #A698A6; font-size: 9pt; }
      #GCJavLibraryView, #GCJavLibraryMain { background-color: #111015; }
      #GCJavLibraryToolbar { background-color: #141218; border-bottom: 1px solid #382934; padding: 6px; }
      #GCJavLibrarySearchRow, #GCJavLibraryFilterRow { background-color: #141218; }
      #GCJavLibrarySearch { background-color: #211D25; color: #F2ECF2;
           border: 1px solid #40343F; border-radius: 6px; min-height: 33px; }
      #GCJavLibraryAction { background-color: #612038; color: #F8EEF3;
           border: 1px solid #7D2B49; border-radius: 6px; min-height: 32px; }
      #GCJavLibraryAction:hover { background-color: #893453; }
      #GCJavLibrarySort, #GCJavLibraryFavoritesFilter, #GCJavLibraryRatingOrder,
      #GCJavLibraryFilterRow combobox, #GCJavLibraryFilterRow combobox button {
          background-color: #211D25; color: #E6DFE9;
          border: 1px solid #40333D; border-radius: 6px; min-height: 29px;
      }
      #GCJavLibraryFavoritesFilter:checked, #GCJavLibraryRatingOrder:checked {
          background-color: #64243F; color: #FFF4F8; border-color: #AE496B;
      }
      #GCJavLibraryCard { background-color: #1A171F; border: 1px solid #342B35;
          border-radius: 7px; box-shadow: 0 2px 5px alpha(black, 0.24); }
      #GCJavLibraryCard.gcjav-card-hover { border-color: #8E3655;
          box-shadow: 0 0 9px alpha(#A83A59, 0.31); }
      #GCJavLibraryCard.gcjav-card-selected { border: 2px solid #AC4062;
          background-color: #241B25; }
      #GCJavLibraryPoster { background-color: #18131B; border-radius: 5px; }
      #GCJavLibraryCardCode { color: #F6F1F5; font-size: 11pt; font-weight: bold; }
      #GCJavLibraryCardTitle { color: #C9BDC9; font-size: 9pt; }
      #GCJavLibraryCardCast { color: #B8ADB8; font-size: 9pt; }
      #GCJavLibraryCardStudio { color: #998D9C; font-size: 8pt; }
      #GCJavLibraryCardTags { color: #C8A8B6; font-size: 8pt; }
      #GCJavLibraryCardDivider { background-color: #342A34; }
      #GCJavLibraryFavoriteButton { background-color: rgba(23, 17, 25, 0.78);
           border: 1px solid #483443; }
      #GCJavLibraryFavoriteButton.gcjav-favorite-active { color: #C54F76; border-color: #943450; }
      #GCJavLibraryFavoriteButton label { color: #B1A5B1; }
      #GCJavLibraryFavoriteButton.gcjav-favorite-active label { color: #CB4E79; }
      #GCJavLibraryCount { color: #BFB4C0; font-size: 9pt; }
    } : uses_kt9v1_layout($name) ? qq{
      /* KT9V1: misma interfaz, cinco variantes cromaticas reales. */
      #GCJavSidebar { background-color: $nav_bg; border-right: 1px solid $border; }
      #GCJavSidebarHeader { background-color: $nav_bg; color: $accent; font-size: 14pt; font-weight: bold; }
      #GCJavSidebar button { background-image: none; background-color: transparent; color: $fg;
           border: 0; border-radius: 6px; padding: 10px 14px; }
      #GCJavSidebar button:hover { background-color: $nav_hover; color: $fg; }
      #GCJavSidebar button.gcjav-nav-active { background-color: $nav_active; color: $fg;
           border-left: 3px solid $accent; font-weight: bold; }
      #GCJavSidebarSeparator { background-color: $border; }
      #GCJavSidebarFooter { color: $muted; font-size: 9pt; }
      #GCJavLibraryView, #GCJavLibraryMain { background-color: $bg; }
      #GCJavLibraryToolbar { background-color: $bg; border-bottom: 1px solid $border; padding: 6px; }
      #GCJavLibrarySearchRow, #GCJavLibraryFilterRow { background-color: $bg; }
      #GCJavLibrarySearch { background-color: $field; color: $fg;
           border: 1px solid $border; border-radius: 6px; min-height: 33px; }
      #GCJavLibraryAction { background-color: $accent; color: $action_text;
           border: 1px solid $accent; border-radius: 6px; min-height: 32px; }
      #GCJavLibraryAction label { color: $action_text; }
      #GCJavLibraryAction:hover { background-color: $hover; }
      #GCJavLibrarySort, #GCJavLibraryFavoritesFilter, #GCJavLibraryRatingOrder,
      #GCJavLibraryFilterRow combobox, #GCJavLibraryFilterRow combobox button {
          background-color: $field; color: $fg;
          border: 1px solid $border; border-radius: 6px; min-height: 29px;
      }
      #GCJavLibraryFavoritesFilter:checked, #GCJavLibraryRatingOrder:checked {
          background-color: $accent; color: $action_text; border-color: $hover;
      }
      #GCJavLibraryCard { background-image: none; background-color: $panel;
          border: 1px solid $border; border-radius: 7px;
          box-shadow: 0 2px 5px alpha(black, 0.18); }
      #GCJavLibraryCard.gcjav-card-hover { border-color: $accent;
          box-shadow: 0 0 9px alpha($accent, 0.31); }
      #GCJavLibraryCard.gcjav-card-selected { border: 2px solid $accent;
          background-color: $card_selected; }
      #GCJavLibraryPoster { background-color: $list; border-radius: 5px; }
      #GCJavLibraryCardCode { color: $accent; font-size: 11pt; font-weight: bold; }
      #GCJavLibraryCardTitle { color: $card_title; font-size: 9pt; }
      #GCJavLibraryCardCast { color: $fg; font-size: 9pt; }
      #GCJavLibraryCardStudio { color: $muted; font-size: 8pt; }
      #GCJavLibraryCardTags { color: $muted; font-size: 8pt; }
      #GCJavLibraryCardDivider { background-color: $border; }
      #GCJavLibraryFavoriteButton { background-color: $list;
           border: 1px solid $border; }
      #GCJavLibraryFavoriteButton label { color: $muted; }
      #GCJavLibraryFavoriteButton.gcjav-favorite-active { border-color: $accent; }
      #GCJavLibraryFavoriteButton.gcjav-favorite-active label { color: $accent; }
      #GCJavLibraryCount { color: $muted; font-size: 9pt; }
    } : '';
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

      /* JAVKT9 RC3 BIBLIOTECA V6 SKIN: estilos limitados a Biblioteca. */
      #GCJavLibraryView, #GCJavLibraryMain {
          background-color: $bg; color: $fg;
      }
      #GCJavLibraryToolbar {
          background-image: none; background-color: $panel;
          border-bottom: 1px solid $border;
      }
      #GCJavLibraryTitle {
          color: $fg; font-size: 16px; font-weight: bold;
      }
      #GCJavLibrarySearch, #GCJavLibrarySort {
          background-image: none; background-color: $field;
          color: $fg; border-color: $border;
      }
      #GCJavLibraryCard {
          background-image: none; background-color: $panel;
          border: 1px solid $border; border-radius: 10px;
      }
      #GCJavLibraryCard:hover {
          background-color: $field; border-color: $hover;
      }
      #GCJavLibraryCard.gcjav-card-selected,
      #GCJavLibraryCard.gcjav-card-selected:hover {
          background-color: $field;
          border: 2px solid $accent;
      }
      #GCJavLibraryPoster {
          background-color: $list; border-radius: 7px;
      }
      #GCJavLibraryCardDivider {
          background-color: $border;
      }
      #GCJavLibraryCardCode {
          color: $accent; font-size: 14px; font-weight: bold;
      }
      #GCJavLibraryCardTitle {
          color: $fg; font-size: 13px;
      }

/* JAVKT9 RC3 BIBLIOTECA V7 HOVER - halo del color del skin. */
#GCJavLibraryCard {
    box-shadow: 0 2px 6px alpha(black, 0.14);
    transition: box-shadow 150ms ease-out, border-color 150ms ease-out, background-color 150ms ease-out;
}
#GCJavLibraryCard.gcjav-card-hover {
    background-color: mix($panel, $hover, 0.25);
    border-color: $accent;
    box-shadow: 0 0 0 1px alpha($accent, 0.50),
                0 0 16px 2px alpha($accent, 0.32),
                0 5px 14px alpha(black, 0.23);
}
#GCJavLibraryPoster {
    transition: box-shadow 150ms ease-out;
}
#GCJavLibraryPoster.gcjav-poster-hover {
    box-shadow: 0 0 0 1px alpha($accent, 0.65),
                0 0 12px 1px alpha($accent, 0.25);
}
#GCJavLibraryCard.gcjav-card-selected.gcjav-card-hover {
    border: 2px solid $accent;
    box-shadow: 0 0 0 1px alpha($accent, 0.78),
                0 0 18px 2px alpha($accent, 0.44);
}
#GCJavLibraryCard:focus {
    outline: 1px solid alpha($accent, 0.70);
    outline-offset: -3px;
}

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
      $wine_css
    };
}

sub apply {
    my ($window, $choice) = @_;
    $choice = current() unless defined $choice;
    $choice = 'KT9V1' unless exists $PALETTES{$choice};
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
    open(my $fh,'>:encoding(UTF-8)',$tmp) or die "No se puede guardar configuración: $!";
    print {$fh} "$name
";
    close($fh) or die "Error al guardar configuración: $!";
    unlink($path) if -e $path;
    rename($tmp,$path) or die "No se puede actualizar configuración: $!";
}

sub choose {
    my ($window, $requested_mode) = @_;
    $requested_mode = undef unless defined($requested_mode) && exists($MODE_THEMES{$requested_mode});
    my $dialog = Gtk3::Dialog->new('Apariencia de JavKT9 - 0.9.9', $window,
        [qw/modal destroy-with-parent/], 'Cancelar'=>'cancel', 'Aplicar'=>'ok');
    $dialog->set_default_size(515,315);
    $dialog->set_name('GCJavAppearanceDialog');

    if ($^O =~ /win32/i) {
        eval {
            my $header = Gtk3::HeaderBar->new;
            $header->set_show_close_button(1);
            $header->set_has_subtitle(0);
            $header->set_size_request(-1,36);
            $header->set_name('GCJavAppearanceTitleBar');
            $header->set_title('Apariencia de JavKT9');
            $dialog->set_titlebar($header);
            1;
        };
    }

    my $box = $dialog->get_content_area;
    $box->set_border_width(16);
    $box->set_spacing(12);

    my $mode_label = Gtk3::Label->new('1. Elegí la interfaz:');
    $mode_label->set_xalign(0);
    $box->pack_start($mode_label,0,0,0);

    my $mode_combo = Gtk3::ComboBoxText->new;
    my @modes = qw(clasico v1 v2);
    $mode_combo->append_text($MODE_LABELS{$_}) for @modes;
    $box->pack_start($mode_combo,0,0,0);

    my $theme_label = Gtk3::Label->new('2. Elegí los colores de esa interfaz:');
    $theme_label->set_xalign(0);
    $box->pack_start($theme_label,0,0,0);

    my $theme_combo = Gtk3::ComboBoxText->new;
    $box->pack_start($theme_combo,0,0,0);

    my $hint = Gtk3::Label->new(
        'Cada interfaz recuerda su tema. Para cambiar de interfaz, reiniciá JavKT9.');
    $hint->set_line_wrap(1);
    $hint->set_xalign(0);
    $box->pack_start($hint,0,0,0);

    my $old_mode = current_mode();
    my $state = _read_appearance() || _appearance_defaults();
    $state->{mode} = $old_mode;
    my $legacy = _legacy_current();
    $state->{$old_mode} = $legacy if _mode_theme_valid($old_mode,$legacy);
    if ($old_mode eq 'clasico' && $window->{options}) {
        my $view = $window->{options}->view;
        $state->{classic_view} = $view if $view >= 0 && $view <= 2;
    }

    my $updating = 0;
    $mode_combo->signal_connect(changed => sub {
        my $index = $mode_combo->get_active;
        return if $index < 0;
        my $mode = $modes[$index];
        $updating = 1;
        $theme_combo->remove_all;
        my @names = @{$MODE_THEMES{$mode}};
        $theme_combo->append_text($THEME_LABELS{$_} // $_) for @names;
        my $chosen = $state->{$mode};
        for my $i (0..$#names) {
            if ($chosen eq $names[$i]) {
                $theme_combo->set_active($i);
                last;
            }
        }
        $updating = 0;
    });
    $theme_combo->signal_connect(changed => sub {
        return if $updating;
        my $index = $mode_combo->get_active;
        return if $index < 0;
        my $theme_index = $theme_combo->get_active;
        $state->{$modes[$index]} = $MODE_THEMES{$modes[$index]}->[$theme_index]
            if $theme_index >= 0;
    });

    my $initial_mode = defined($requested_mode) ? $requested_mode : $old_mode;
    for my $i (0..$#modes) {
        if ($modes[$i] eq $initial_mode) {
            $mode_combo->set_active($i);
            last;
        }
    }

    $dialog->show_all;
    if ($dialog->run eq 'ok') {
        my $index = $mode_combo->get_active;
        if ($index >= 0) {
            my $new_mode = $modes[$index];
            my $theme_index = $theme_combo->get_active;
            my $theme = $theme_index >= 0
                ? $MODE_THEMES{$new_mode}->[$theme_index] : undef;
            if (defined($theme) && _mode_theme_valid($new_mode,$theme)) {
                $state->{mode} = $new_mode;
                $state->{$new_mode} = $theme;
                my $ok = eval {
                    _save_appearance($state);
                    if ($old_mode eq $new_mode) {
                        _save($theme);  # Compatibilidad con GCJavSkin.conf 0.9.7
                        apply($window,$theme);
                        if ($window && $window->can('_gcjavSyncObsidianSidebar')) {
                            $window->_gcjavSyncObsidianSidebar;
                        }
                    }
                    1;
                };
                if (!$ok) {
                    my $error = $@ || 'Error desconocido';
                    my $warning = Gtk3::MessageDialog->new($dialog,
                        [qw/modal destroy-with-parent/],'error','ok',
                        "No se pudo guardar la apariencia: $error");
                    $warning->run;
                    $warning->destroy;
                }
                elsif ($old_mode ne $new_mode) {
                    my $notice = Gtk3::MessageDialog->new($dialog,
                        [qw/modal destroy-with-parent/],'info','ok',
                        'Interfaz guardada. Cerrá JavKT9 y volvé a abrirlo para aplicar el modo elegido.');
                    $notice->run;
                    $notice->destroy;
                }
            }
        }
    }
    $dialog->destroy;
}

1;
