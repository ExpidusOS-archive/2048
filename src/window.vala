namespace Expidus2048 {
  public enum Direction {
    NONE = 0,
    LEFT,
    RIGHT,
    UP,
    DOWN
  }

  [GtkTemplate(ui = "/com/expidus/twentyfortyeight/game-win.glade")]
	public class Window : Hdy.ApplicationWindow {
    private GLib.Settings _settings;
    private uint64[] _board;
    
    public Window(Gtk.Application application) {
      Object(application: application);
    }

    construct {
      this._settings = new GLib.Settings("com.expidus.twentyfortyeight");
      this._settings.notify["board-size"].connect(() => this.reset_game());
      this.reset_game();
    }
    
    private void reset_game() {
      var val = this._settings.get_value("board-size");

      var width = val.get_child_value(0).get_int32();
      var height = val.get_child_value(1).get_int32();

      this._board = new uint64[width * height];
    }
    
    private void move_pieces(Direction dir) {}
    
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
  }
}