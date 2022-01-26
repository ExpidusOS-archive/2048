namespace Expidus2048 {
	public class Application : Gtk.Application {
		private Window _win;
		
		public Application() {
			Object(application_id: "com.expidus.twentyfortyeight", flags: GLib.ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate() {
			if (this._win == null) this._win = new Window(this);
			this._win.show_all();
		}
	}
}
