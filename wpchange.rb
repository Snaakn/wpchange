#! /usr/bin/env ruby
require 'yaml'
require 'gtk3'

class WpApp
  def initialize
    @path = File.expand_path(File.dirname __FILE__)
  end

  # load config to load theme
  def loadconf

    @conf = YAML.load_file(File.join(@path, "config.yaml"))
    return @conf['theme']
  end

  def timeparse str
    # convert the string to a max 4 digit int (from 0 to 2359)
    @time = "#{str[0]}#{str[1]}#{str[3]}#{str[4]}".to_i

  end

  # check theme witch wallpaper should be loaded
  def checkWall
    path = @path + "/themes/" + loadconf + '/'
    t = Time.now
    # convert timestring to int such that the highest 4 digit number is 2359
    # now it it easy to check instead of checking hours and minutes seperately
    @timenow = (t.strftime('%H') + t.strftime('%M')).to_i
    @theme = YAML.load_file(path + loadconf + ".yaml")
    k = @theme.keys
    @wp = path + @theme[k[0]]

    k.each do |item|
      timeparse item
      puts @time
      puts @timenow
      if @timenow >= @time
      @wp = path + @theme[item]
      #puts @wp
      end
    end
    setwall @wp
  end

  # change wallpaper from given path
  def setwall path
    cmd = "gsettings set org.gnome.desktop.background picture-uri file:///" + path
    puts cmd
    system ( cmd )
    puts "wallpaper changed"
  end

  def changetheme selected
    puts @conf
    @conf['theme'] = selected
    puts @conf
    File.write(@path + '/config.yaml', @conf.to_yaml)
    puts 'theme changed'
    checkWall
  end
    # time1 = Time.now
    # puts "Current time: " + time1.strftime('%H') + ":" + time1.strftime('%M')

    #TODO call load config
end

def quitall
  [tcheck, traythread].each { |t| Thread.kill t}
  Gtk.main_quit
end




Dir.chdir(File.join(File.expand_path(File.dirname __FILE__), "/themes"))
files = Dir.glob('*')

app = WpApp.new

tcheck = Thread.new {
  min = 1
  while true
    app.checkWall
    sleep(min * 60)
  end
}


# Making tray icon and menu
#----------------------------------------------------------------------------

si        = Gtk::StatusIcon.new
si.pixbuf = GdkPixbuf::Pixbuf.new(:file => File.join(File.expand_path(File.dirname __FILE__), 'wpchange.svg'))
#si.stock = Gtk::Stock::DIALOG_INFO
si.tooltip_text = "Hello"

themelist = Array.new
i = 0
menu=Gtk::Menu.new

# create menu items for themes in themes directory
files.each do | theme |
  themelist[i]=Gtk::ImageMenuItem.new(:label => "#{theme}", :mnemonic => nil, :stock_id => nil, :accel_group => nil)
  menu.append(themelist[i])
  themelist[i].signal_connect('activate'){app.changetheme theme}
  i += 1
end

quit=Gtk::ImageMenuItem.new(:label => 'QUIT', :mnemonic => nil, :stock_id => nil, :accel_group => nil)
quit.signal_connect('activate'){quitall}
menu.append(Gtk::SeparatorMenuItem.new)
menu.append(quit)
menu.show_all
si.signal_connect('popup-menu'){|tray, button, time| menu.popup(nil, nil, button, time)}


Gtk.main
tcheck.join
