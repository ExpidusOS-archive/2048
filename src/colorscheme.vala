namespace Expidus2048 {
  public struct Color {
    public double red;
    public double green;
    public double blue;
    public double alpha;

    public Color(double red, double green, double blue, double alpha) {
      this.red = red;
      this.green = green;
      this.blue = blue;
      this.alpha = alpha;
    }
    
    public static Color from_hex(string input) {
      var rgba = Gdk.RGBA();
      rgba.parse(input.index_of_char('#') == 0 ? input : "#" + input);
      return Color(rgba.red, rgba.green, rgba.blue, rgba.alpha);
    }
  }
  
  private class ColorSchemeSolarizedLight : GLib.Object, ColorScheme {
    public string get_name() {
      return _("Solarized Light");
    }

    public Color? get_color(uint64 value) {
      if (value == 2) return Color.from_hex("657b83");
      else if (value == 4) return Color.from_hex("839496");
      else if (value == 8) return Color.from_hex("93a1a1");
      else if (value == 16) return Color.from_hex("b58900");
      else if (value == 32) return Color.from_hex("cb4b16");
      else if (value == 64) return Color.from_hex("dc322f");
      else if (value == 128) return Color.from_hex("d33682");
      else if (value == 256) return Color.from_hex("6c71c4");
      else if (value == 512) return Color.from_hex("268bd2");
      else if (value == 1024) return Color.from_hex("2aa198");
      else if (value == 2048) return Color.from_hex("859900");
      return Color.from_hex("#586e75");
    }

    public Color? get_foreground_color(uint64 value) {
      return Color.from_hex("#002b36");
    }
    
    public Color get_background_color(bool board) {
      return Color.from_hex(board ? "#fdf6e3" : "#eee8d5");
    }
  }
  
  private class ColorSchemeSolarizedDark : GLib.Object, ColorScheme {
    public string get_name() {
      return _("Solarized Dark");
    }

    public Color? get_color(uint64 value) {
      if (value == 2) return Color.from_hex("657b83");
      else if (value == 4) return Color.from_hex("839496");
      else if (value == 8) return Color.from_hex("93a1a1");
      else if (value == 16) return Color.from_hex("b58900");
      else if (value == 32) return Color.from_hex("cb4b16");
      else if (value == 64) return Color.from_hex("dc322f");
      else if (value == 128) return Color.from_hex("d33682");
      else if (value == 256) return Color.from_hex("6c71c4");
      else if (value == 512) return Color.from_hex("268bd2");
      else if (value == 1024) return Color.from_hex("2aa198");
      else if (value == 2048) return Color.from_hex("859900");
      return Color.from_hex("#586e75");
    }

    public Color? get_foreground_color(uint64 value) {
      return Color.from_hex("#fdf6e3");
    }
    
    public Color get_background_color(bool board) {
      return Color.from_hex(board ? "#073642" : "#002b36");
    }
  }
  
  private class ColorSchemeClassic : GLib.Object, ColorScheme { 
    public string get_name() {
      return _("Classic");
    }

    public Color? get_color(uint64 value) {
      if (value == 2) return Color.from_hex("eee4da");
      else if (value == 4) return Color.from_hex("ede0c8");
      else if (value == 8) return Color.from_hex("f2b179");
      else if (value == 16) return Color.from_hex("f59563");
      else if (value == 32) return Color.from_hex("f67c5f");
      else if (value == 64) return Color.from_hex("f65e3b");
      else if (value == 128) return Color.from_hex("edcf72");
      else if (value == 256) return Color.from_hex("edcc61");
      else if (value == 512) return Color.from_hex("edc850");
      else if (value == 1024) return Color.from_hex("edc53f");
      else if (value == 2048) return Color.from_hex("edc22e");
      return Color.from_hex("#cdc1b4");
    }

    public Color? get_foreground_color(uint64 value) {
      return Color.from_hex("#776e65");
    }
    
    public Color get_background_color(bool board) {
      return Color.from_hex(board ? "#bbada0" : "#faf8ef");
    }
  }
  
  public class ColorSchemeSystem : GLib.Object, ColorScheme {
    public string get_name() {
      return _("System");
    }

    public Color? get_color(uint64 value) {
      var ctx = new Gtk.StyleContext();
      ctx.add_provider(Gtk.Settings.get_default(), Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS);
      ctx.add_class("expidus-2048-game-tile");
      ctx.add_class("expidus-2048-game-tile%llu".printf(value));
      
      var path = new Gtk.WidgetPath();
      path.append_type(typeof (Gtk.Box));
      ctx.set_path(path);
      Gdk.RGBA color = {};
      ctx.get(Gtk.StateFlags.NORMAL, "background-color", ref color);
      return Color(color.red, color.green, color.blue, color.alpha);
    }
    
    public Color? get_foreground_color(uint64 value) {
      var ctx = new Gtk.StyleContext();
      ctx.add_provider(Gtk.Settings.get_default(), Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS);
      ctx.add_class("expidus-2048-game-tile");
      
      var path = new Gtk.WidgetPath();
      path.append_type(typeof (Gtk.Box));
      ctx.set_path(path);
      var color = ctx.get_color(Gtk.StateFlags.NORMAL);
      return Color(color.red, color.green, color.blue, color.alpha);
    }

    public Color get_background_color(bool board) {
      var ctx = new Gtk.StyleContext();
      ctx.add_provider(Gtk.Settings.get_default(), Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS);
      ctx.add_class("expidus-2048-game-" + (board ? "board" : "background"));
      
      var path = new Gtk.WidgetPath();
      path.append_type(typeof (Gtk.Box));
      ctx.set_path(path);
      Gdk.RGBA color = {};
      ctx.get(Gtk.StateFlags.NORMAL, "background-color", ref color);
      return Color(color.red, color.green, color.blue, color.alpha);
    }
  }

  public interface ColorScheme : GLib.Object {
    public abstract string get_name();
    public abstract Color? get_color(uint64 value);
    public abstract Color? get_foreground_color(uint64 value);
    public abstract Color get_background_color(bool board);
    
    public static GLib.List<ColorScheme?> get_all() {
      var lst = new GLib.List<ColorScheme?>();
      lst.append(new ColorSchemeClassic());
      lst.append(new ColorSchemeSolarizedLight());
      lst.append(new ColorSchemeSolarizedDark());
      return lst;
    }
    
    public static ColorScheme? by_name(string name, bool? default_sys = true) {
      foreach (var cs in get_all()) {
        if (name == cs.get_name()) return cs;
      }
      return default_sys ? new ColorSchemeSystem() : null;
    }
    
    public static ColorScheme? by_index(int i) {
      return get_all().nth_data(i);
    }
  }
}