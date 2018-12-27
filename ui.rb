class UI
  def initialize app
    @app = app
    @themelist = Array.new
    @menu=Gtk::Menu.new
    @sig        = Gtk::StatusIcon.new
    @sig.pixbuf = GdkPixbuf::Pixbuf.new(:file => File.join(File.expand_path(File.dirname __FILE__), 'wpchange.svg'))
    #si.stock = Gtk::Stock::DIALOG_INFO
    @sig.tooltip_text = "Hello"
    Dir.chdir(File.join(File.expand_path(File.dirname __FILE__), "/themes"))
    @files = Dir.glob('*')
  end

  def quitall
    [tcheck, traythread].each { |t| Thread.kill t}
    Gtk.main_quit
  end

  def show
    i = 0
    # create menu items for themes in themes directory
    @files.each do | theme |
      @themelist[i]=Gtk::ImageMenuItem.new(:label => "#{theme}", :mnemonic => nil, :stock_id => nil, :accel_group => nil)
      @menu.append(@themelist[i])
      @themelist[i].signal_connect('activate'){@app.changetheme theme}
      i += 1
    end

    @quit=Gtk::ImageMenuItem.new(:label => 'QUIT', :mnemonic => nil, :stock_id => nil, :accel_group => nil)
    @quit.signal_connect('activate'){quitall}
    @menu.append(Gtk::SeparatorMenuItem.new)
    @menu.append(@quit)
    @menu.show_all
    @sig.signal_connect('popup-menu'){|tray, button, time| @menu.popup(nil, nil, button, time)}


    Gtk.main
  end
end
