require 'gtk2'

module JLDrill::Gtk
    class Popup
        attr_reader :character, :x, :y
            
        def initialize(character, mainWindow, x, y)
            @x = x
            @y = y
            @character = character
            
            @popup = Gtk::Window.new(Gtk::Window::POPUP)
            @popup.set_transient_for(mainWindow)
            @popup.set_destroy_with_parent(true)
            @popup.set_window_position(Gtk::Window::POS_NONE)
            
            @hbox = Gtk::HBox.new
            @popup.add(@hbox)
        end
        
        def display
            @popup.move(x, y)
            @popup.show_all
        end
        
        def close
            @popup.destroy                
        end
    end
end
