namespace Expidus2048 {
  private const int TILE_SPACING = 10;
  private const int TILE_SIZE = 64;
  private const int TILE_RADIUS = 6;

  [GtkTemplate(ui = "/com/expidus/twentyfortyeight/game-win.glade")]
	public class Window : Hdy.ApplicationWindow {
    private GLib.Settings _settings;
    private Game _game;
    
    [GtkChild]
    private unowned Gtk.Stack stack;
    
    [GtkChild]
    private unowned Gtk.DrawingArea game_area;
    
    public Window(Gtk.Application application) {
      Object(application: application);
    }

    construct {
      this._settings = new GLib.Settings("com.expidus.twentyfortyeight");
      this._settings.changed["board-size"].connect(() => this.reset_game());
      this.reset_game();
    }
    
    private void set_size() {
      this.game_area.set_size_request((TILE_SIZE + TILE_SPACING) * this._game.board_width, (TILE_SIZE + TILE_SPACING) * this._game.board_height);
    }
    
    private void reset_game() {
      var val = this._settings.get_value("board-size");
      
      this._game = new Game(val.get_child_value(0).get_int32(), val.get_child_value(1).get_int32());
      this._game.notify["state"].connect(() => {
        if (this._game.state == GameState.LOST || this._game.state == GameState.WIN) {
          var dialog = new Gtk.Dialog.with_buttons(_("2048"), this, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, _("Ok"), Gtk.ResponseType.NONE);
          var area = dialog.get_content_area();
          area.add(new Gtk.Label(this._game.state == GameState.WIN ? _("You win!") : _("You lost!")));
          dialog.show_all();
          this.reset_game();
        }
      });
      
      this._game.notify["score"].connect(() => this.game_area.queue_draw());
      this._game.draw.connect(() => this.game_area.queue_draw());
    }
    
    private void draw_rounded_rectangle(Cairo.Context cr, double x, double y, double w, double h, double r) {
      const double d = Math.PI / 180.0;
      cr.new_sub_path();
      cr.arc(x + w - r, y + r, r, -90 * d, 0 * d);
      cr.arc(x + w - r, y + h - r, r, 0 * d, 90 * d);
      cr.arc(x + r, y + h - r, r, 90 * d, 180 * d);
      cr.arc(x + r, y + r, r, 180 * d, 270 * d);
      cr.close_path();
      cr.fill();
    }

    [GtkCallback]
    private bool do_key_pressed(Gdk.EventKey ev) {
      switch (ev.keyval) {
        case Gdk.Key.Left:
          this._game.move(Direction.LEFT);
          break;
        case Gdk.Key.Right:
          this._game.move(Direction.RIGHT);
          break;
        case Gdk.Key.Up:
          this._game.move(Direction.UP);
          break;
        case Gdk.Key.Down:
          this._game.move(Direction.DOWN);
          break;
      }
      return true;
    }
    
    [GtkCallback]
    private bool do_draw(Gtk.Widget w, Cairo.Context cr) {
      var color_scheme = this._settings.get_boolean("system-colors") ? new ColorSchemeSystem() : ColorScheme.by_name(this._settings.get_string("color-scheme"));
      GLib.debug("Using %s for color scheme", color_scheme.get_name());

      var bg = color_scheme.get_background_color(false);
      cr.set_source_rgba(bg.red, bg.green, bg.blue, bg.alpha);
      cr.paint();
      
      Gtk.Allocation alloc = {};
      int baseline = 0;
      w.get_allocated_size(out alloc, out baseline);
      
      var text_color = color_scheme.get_foreground_color(0);
      
      var layout = Pango.cairo_create_layout(cr);
      layout.set_font_description(Pango.FontDescription.from_string("Sans Bold 15"));
      var score_txt = _("Score: %llu").printf(this._game.score);
      layout.set_text(score_txt, score_txt.length);

      cr.set_source_rgba(text_color.red, text_color.green, text_color.blue, text_color.alpha);
      Pango.cairo_update_layout(cr, layout);

      int text_width = 0;
      int text_height = 0;
      layout.get_pixel_size(out text_width, out text_height);
      
      var total_width = (this._game.board_width * (TILE_SPACING + TILE_SIZE)) + TILE_SPACING;
      var total_height = ((this._game.board_height * (TILE_SPACING + TILE_SIZE)) + TILE_SPACING) + text_height;
      
      var center_x = (alloc.width / 2) - (total_width / 2);
      var center_y = (alloc.height / 2) - (total_height / 2);
      cr.move_to(center_x, center_y);
      Pango.cairo_show_layout(cr, layout);
      
      center_y += TILE_SPACING + text_height;
      total_height -= text_height;

      var board_bg = color_scheme.get_background_color(true);
      cr.set_source_rgba(board_bg.red, board_bg.green, board_bg.blue, board_bg.alpha);
      this.draw_rounded_rectangle(cr, center_x, center_y, total_width, total_height, 6);
      
      for (var y = 0; y < this._game.board_height; y++) {
        for (var x = 0; x < this._game.board_width; x++) {
          var draw_x = (x * (TILE_SPACING + TILE_SIZE)) + TILE_SPACING;
          var draw_y = (y * (TILE_SPACING + TILE_SIZE)) + TILE_SPACING;
          
          var value = this._game.get_piece(x, y);
          var tile_bg = color_scheme.get_color(value);
          cr.set_source_rgba(tile_bg.red, tile_bg.green, tile_bg.blue, tile_bg.alpha);
          
          this.draw_rounded_rectangle(cr, draw_x + center_x, draw_y + center_y, TILE_SIZE, TILE_SIZE, 6);
          
          if (value > 0) {
            var txt = value.to_string();
            layout.set_text(txt, txt.length);

            text_color = color_scheme.get_foreground_color(value);
            cr.set_source_rgba(text_color.red, text_color.green, text_color.blue, text_color.alpha);
            Pango.cairo_update_layout(cr, layout);
            
            text_width = 0;
            text_height = 0;
            layout.get_pixel_size(out text_width, out text_height);
            cr.move_to(draw_x + center_x + ((TILE_SIZE / 2) - (text_width / 2)), draw_y + center_y + ((TILE_SIZE / 2) - (text_height / 2)));
            Pango.cairo_show_layout(cr, layout);
          }
        }
      }
      return false;
    }
    
    [GtkCallback]
    private void do_size_alloc(Gtk.Widget w, Gtk.Allocation alloc) {
      this.set_size();
    }
    
    [GtkCallback]
    private void do_settings() {
      var win = new SettingsWindow(this);
      win.show_all();
    }
  }
  
  [GtkTemplate(ui = "/com/expidus/twentyfortyeight/settings-win.glade")]
  public class SettingsWindow : Hdy.PreferencesWindow {
    [GtkChild]
    private unowned Gtk.Label build_label;
    
    [GtkChild]
    private unowned Gtk.SpinButton board_width_spin;
    
    [GtkChild]
    private unowned Gtk.SpinButton board_height_spin;
    
    [GtkChild]
    private unowned Gtk.Switch system_theme_switch;
    
    [GtkChild]
    private unowned Hdy.PreferencesRow tile_color_scheme_row;
    
    [GtkChild]
    private unowned Hdy.ComboRow tile_color_scheme_combo;
    
    private GLib.Settings _settings;

    public SettingsWindow(Hdy.ApplicationWindow win) {
      Object();

      this.set_transient_for(win);
    }

    construct {
      this.build_label.label = _("Version: %s").printf(VERSION);
      this._settings = new GLib.Settings("com.expidus.twentyfortyeight");
      
      this._settings.notify["board-size"].connect(() => this.update_board_size());
      this.update_board_size();
      
      this.system_theme_switch.state = this._settings.get_boolean("system-colors");
      if (this.system_theme_switch.state) this.tile_color_scheme_row.show();
      else this.tile_color_scheme_row.hide();
      
      var model = new GLib.ListStore(typeof (ColorScheme));
      var colorschemes = ColorScheme.get_all();
      foreach (var cs in colorschemes) model.append(cs);
      this.tile_color_scheme_combo.bind_name_model(model, (item) => ((ColorScheme)item).get_name());
    }

    private void update_board_size() { 
      var val = this._settings.get_value("board-size");
      var width = val.get_child_value(0).get_int32();
      var height = val.get_child_value(1).get_int32();
      
      this.board_width_spin.set_value(width * 1.0);
      this.board_height_spin.set_value(height * 1.0);
    }
    
    [GtkCallback]
    private void on_board_changed() {
      this._settings.set_value("board-size", new GLib.Variant("(ii)", this.board_width_spin.get_value_as_int(), this.board_height_spin.get_value_as_int()));
    }
    
    [GtkCallback]
    private bool do_system_color_scheme(Gtk.Switch s, bool is_active) {
      if (is_active) this.tile_color_scheme_row.hide();
      else this.tile_color_scheme_row.show();

      this._settings.set_boolean("system-colors", is_active);
      return false;
    }
    
    [GtkCallback]
    private void do_color_scheme_picked() {
      var cs = ColorScheme.by_index(this.tile_color_scheme_combo.get_selected_index());
      if (cs != null) this._settings.set_string("color-scheme", cs.get_name());
    }
  }
}