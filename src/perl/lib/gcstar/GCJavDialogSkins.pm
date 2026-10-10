package GCJavDialogSkins;
use strict;
use warnings;
use utf8;
use Gtk3;

# Keep palettes identical to GCJavSkins P11.5; first eight colors are used.
my %PALETTES = (
    'Dark Purple'    => ['#17121F','#211A2D','#2A2139','#EDE8F5','#8F5BC8','#AF82E5','#3A3049','#16111E','#B7A8C9'],
    'Midnight Blue'  => ['#101925','#19283A','#21354A','#EAF1F9','#428BD4','#76B5EE','#30465B','#101F2E','#AFC1D5'],
    'Silver Light'   => ['#F3F6FB','#E7EEF6','#FFFFFF','#203246','#2B7DE9','#67A9FF','#C2D1E0','#FFFFFF','#66798F'],
    'Pink Pulse'     => ['#120B16','#241127','#2A1730','#FCECF8','#FF2E93','#FF66B2','#6A2452','#110914','#D4B2C5'],
    'Obsidian Cyan'  => ['#071018','#0D1823','#111F2C','#E8F6FF','#18BFEA','#48D5FF','#26384A','#09131C','#8CB1C8'],
    'Noir Gold'      => ['#090909','#141414','#1C1C1C','#F6F1CF','#E7C64A','#FFD95E','#4B421E','#0D0D0D','#BDAF71'],
    'Sakura Crimson' => ['#120708','#1F0D12','#2A1118','#FFF1F4','#E63E63','#FF7DA1','#6E2435','#14080A','#D8A4B0'],
);

my ($provider, $screen, $choice_applied);

sub _css {
    my ($name) = @_;
    my ($bg,$panel,$field,$fg,$accent,$hover,$border,$list,$muted) = @{$PALETTES{$name}};
    my $accent_text = ($name eq 'Noir Gold' || $name eq 'Obsidian Cyan') ? '#101317' : '#FFFFFF';
    return qq{
      #GCJavFavoritesDialog, #GCJavPreviewDialog, #GCJavAboutDialog {
          background-color: $bg; color: $fg;
      }
      #GCJavFavoritesDialog box, #GCJavPreviewDialog box, #GCJavAboutDialog box,
      #GCJavFavoritesDialog grid, #GCJavPreviewDialog grid, #GCJavAboutDialog grid {
          color: $fg;
      }
      #GCJavFavoritesDialog label, #GCJavPreviewDialog label, #GCJavAboutDialog label {
          color: $fg;
      }
      #GCJavFavoritesDialog notebook, #GCJavPreviewDialog notebook {
          background-color: $bg; color: $fg;
      }
      #GCJavFavoritesDialog notebook > header {
          background-color: $panel; border-bottom: 1px solid $border;
      }
      #GCJavFavoritesDialog notebook > header > tabs > tab {
          background-color: $panel; color: $fg;
          padding: 8px 14px;
      }
      #GCJavFavoritesDialog notebook > header > tabs > tab:checked {
          background-color: $accent; color: $accent_text;
          border-bottom: 2px solid $hover;
      }
      #GCJavFavoritesDialog notebook > header > tabs > tab:checked label {
          color: $accent_text;
      }
      #GCJavFavoritesDialog treeview, #GCJavFavoritesDialog treeview.view {
          background-color: $list; color: $fg;
      }
      #GCJavFavoritesDialog treeview:selected {
          background-color: $accent; color: $accent_text;
      }
      #GCJavFavoritesDialog treeview header button {
          background-color: $panel; color: $fg; border-color: $border;
      }
      #GCJavFavoritesDialog entry, #GCJavPreviewDialog entry {
          background-image: none; background-color: $field;
          color: $fg; border-color: $border;
      }
      #GCJavFavoritesDialog button, #GCJavPreviewDialog button, #GCJavAboutDialog button {
          background-image: none; background-color: $field;
          color: $fg; border: 1px solid $border;
      }
      #GCJavFavoritesDialog button:hover, #GCJavPreviewDialog button:hover, #GCJavAboutDialog button:hover {
          background-color: $hover; color: $accent_text; border-color: $accent;
      }
      #GCJavFavoritesDialog button:active, #GCJavPreviewDialog button:active, #GCJavAboutDialog button:active {
          background-color: $accent; color: $accent_text;
      }
      #GCJavAboutDialog #GCJavAboutBrand {
          color: $accent;
      }
      #GCJavDialogTitleBar {
          background-image: none; background-color: $accent;
          color: $accent_text; border: 0;
      }
      #GCJavDialogTitleBar label {
          color: $accent_text; font-weight: bold;
      }
      #GCJavDialogTitleBar button {
          background-image: none; background-color: $panel;
          color: $fg; border: 1px solid $border;
      }
      #GCJavDialogTitleBar button:hover {
          background-color: $hover; color: $accent_text;
      }
    };
}

sub _apply {
    my ($dialog) = @_;
    require GCJavSkins;
    my $name = GCJavSkins::current();
    $name = 'Dark Purple' unless exists $PALETTES{$name};
    my $display = $dialog->get_screen;

    # Once per screen and current palette. The provider is scoped to the
    # three named dialogs and will not change the main application or other UI.
    return if $provider && $screen == $display && $choice_applied eq $name;
    my $new_provider = Gtk3::CssProvider->new;
    $new_provider->load_from_data(_css($name));
    Gtk3::StyleContext::remove_provider_for_screen($screen, $provider)
        if $provider && $screen;
    Gtk3::StyleContext::add_provider_for_screen($display, $new_provider, 950);
    $provider = $new_provider;
    $screen = $display;
    $choice_applied = $name;
}

sub decorate {
    my ($dialog, $kind) = @_;
    return unless $dialog;
    my $id = $kind eq 'preview' ? 'GCJavPreviewDialog'
           : $kind eq 'about'   ? 'GCJavAboutDialog'
                                : 'GCJavFavoritesDialog';
    $dialog->set_name($id);

    # Windows uses a custom HeaderBar in the main window. Match that here,
    # without changing dialog responses or the action area buttons.
    if ($^O =~ /win32/i && !$dialog->{gcjavSkinTitlebar}) {
        eval {
            my $header = Gtk3::HeaderBar->new;
            $header->set_show_close_button(1);
            $header->set_has_subtitle(0);
            $header->set_size_request(-1, 36);
            $header->set_name('GCJavDialogTitleBar');
            $header->set_title($kind eq 'preview' ? 'Vista previa de película'
                               : $kind eq 'about' ? 'Acerca de JAVkt9'
                                                  : 'Favoritos de personas');
            $dialog->set_titlebar($header);
            $dialog->{gcjavSkinTitlebar} = $header;
            1;
        } or warn "P11.8 custom dialog titlebar not available: $@";
    }
    eval { _apply($dialog); 1 }
        or warn "P11.8 dialog colors not available: $@";
    return 1;
}

1;
