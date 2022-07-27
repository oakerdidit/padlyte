//gpad
public class HeaderBar : Gtk.HeaderBar {
    construct {
        title = "PadLyte";
        subtitle = "devel-stage";

        show_close_button = true;
        
        var btn1 = new Gtk.Button.with_label ("New");
        btn1.get_style_context().add_class("suggested-action");
        btn1.valign =  Gtk.Align.CENTER; 
        pack_start (btn1);
        
        // add icon button -> submenu (popup menu)
        var options_btn = new Gtk.Button.from_icon_name("view-more", Gtk.IconSize.MENU);
        options_btn.valign =  Gtk.Align.CENTER; 
        pack_end (options_btn);
        
    }
}

public class TextEditor : Gtk.Window {


    private Gtk.TextView text_view;
    private Gtk.MenuBar menu_bar;
    private Gtk.MenuItem item_open;
    private Gtk.MenuItem item_save;
    private Gtk.MenuItem item_quit;
    private Gtk.MenuItem item_dev;
    private File file;

    public TextEditor () {}

    construct {
        
        set_default_size (400, 325);
        window_position = Gtk.WindowPosition.CENTER;

        file = null;
        menu_bar = new Gtk.MenuBar ();
        
       
        
        Gtk.MenuItem item_file = new Gtk.MenuItem.with_label ("File");
        menu_bar.add (item_file);
        
        // font section
        Gtk.MenuItem item_font = new Gtk.MenuItem.with_label ("Font");
        menu_bar.add (item_font);
        
        // create about section
        Gtk.MenuItem item_about = new Gtk.MenuItem.with_label ("About");
        menu_bar.add (item_about);
        
        // add dev details to about
        Gtk.Menu about_sec = new Gtk.Menu ();
        item_about.set_submenu (about_sec);
        item_dev = new Gtk.MenuItem.with_label ("PadLyte created by Tristan Oaker (Oakerdidit)");
        about_sec.add (item_dev);
        
       
        
        
        
        Gtk.Menu file_menu = new Gtk.Menu ();
        item_file.set_submenu (file_menu);
        
        

        item_open = new Gtk.MenuItem.with_label ("Open");
        file_menu.add (item_open);

        item_save = new Gtk.MenuItem.with_label ("Save");
        file_menu.add (item_save);

        item_quit = new Gtk.MenuItem.with_label ("Quit");
        file_menu.add (item_quit);        

        text_view = new Gtk.TextView ();
        text_view.set_wrap_mode (Gtk.WrapMode.WORD);
        text_view.buffer.text = "";

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (text_view);
        scrolled_window.hexpand = true;
        scrolled_window.vexpand = true;

        var grid = new Gtk.Grid ();
        grid.attach (menu_bar, 0, 0, 1, 1);
        grid.attach (scrolled_window, 0, 1, 1, 1);
        add (grid as Gtk.Widget);
        var headerbar = new HeaderBar ();
	 	set_titlebar (headerbar);

	 	show_all ();

        connect_signals ();
    }

    private void connect_signals () {
        destroy.connect (Gtk.main_quit);
        item_open.activate.connect (() => {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
                "Select a file to edit", this, Gtk.FileChooserAction.OPEN,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT);
            chooser.set_select_multiple (false);
            chooser.run ();
            chooser.close ();
            if (chooser.get_file () != null) {
                file = chooser.get_file ();

                try {
                    uint8[] contents;
                    string etag_out;
                    file.load_contents (null, out contents, out etag_out);
                    text_view.buffer.text = (string) contents;
                } catch (Error e) {
                    stdout.printf ("Error: %s\n", e.message);
                }
            }
        });

        item_save.activate.connect(()=> {
            if (file != null) {
                try {
                    file.replace_contents (text_view.buffer.text.data, null, false, FileCreateFlags.NONE, null);
                } catch (Error e) {
                    stdout.printf ("Error: %s\n", e.message);
                }
            }
        });
        item_quit.activate.connect (Gtk.main_quit);
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var my_editor = new TextEditor ();
        my_editor.show_all ();

        Gtk.main ();

        return 0;
    }
}

