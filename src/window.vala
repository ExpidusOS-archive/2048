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
      this.gen_board();
    }
    
    private void gen_board() {
      var val = this._settings.get_value("board-size");

      var width = val.get_child_value(0).get_int32();
      var height = val.get_child_value(1).get_int32();

      this._board = new uint64[width * height];
    }
    
    private void move(Direction dir) {}
    
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
    }
    
    [GtkCallback]
    private void on_board_changed() {
    }
  }
}