public static int main(string[] args) {
  GLib.Intl.setlocale(GLib.LocaleCategory.ALL, ""); 
  GLib.Intl.bindtextdomain(GETTEXT_PACKAGE, Expidus2048.DATADIR + "/locale");
  GLib.Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
  GLib.Intl.textdomain(GETTEXT_PACKAGE);

  GLib.Environment.set_application_name(GETTEXT_PACKAGE);
  GLib.Environment.set_prgname(GETTEXT_PACKAGE);
  return new Expidus2048.Application().run(args);
}