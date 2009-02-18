require 'gtk2'

module JLDrill::Gtk
    class Popup
        attr_reader :character, :x, :y
            
        def initialize(char, kanjiString, mainWindow, x, y)
            @character = char
            @x = x
            @y = y
            
            @popup = Gtk::Window.new(Gtk::Window::POPUP)
            @popup.set_transient_for(mainWindow)
            @popup.set_destroy_with_parent(true)
            @popup.set_window_position(Gtk::Window::POS_NONE)
            
            @hbox = Gtk::HBox.new
            @popup.add(@hbox)
            
            color = Gdk::Color.parse("lightblue1")
            @strokes = Gtk::TextView.new
            @strokes.wrap_mode = Gtk::TextTag::WRAP_NONE
            @strokes.editable = false
            @strokes.cursor_visible = false
            @strokes.set_pixels_above_lines(0)
            @strokes.set_pixels_below_lines(0)
            @strokes.modify_base(Gtk::STATE_NORMAL, color)
            
            @strokeBuffer = @strokes.buffer
            @strokeBuffer.create_tag("strokeOrder",
                                     "size" => 120 * Pango::SCALE,
                                     "justification" => Gtk::JUSTIFY_CENTER,
                                     "family" => "KanjiStrokeOrders")
            @strokeBuffer.insert(@strokeBuffer.start_iter, @character + "\n", "strokeOrder")
            @hbox.add(@strokes)
            
            if !kanjiString.empty?
                @contents = Gtk::TextView.new
                @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                @contents.editable = false
                @contents.cursor_visible = false
                @contents.set_pixels_above_lines(0)
                @contents.modify_base(Gtk::STATE_NORMAL, color)
                @contents.set_width_request(250)
                
                @buffer = @contents.buffer
                @buffer.create_tag("popupText", 
                                   "size" => 10 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_LEFT)
                @buffer.insert(@buffer.end_iter, kanjiString, "popupText")
                @hbox.add(@contents)
            end
            
            @popup.move(x, y)
            @popup.show_all
        end
        
        def close
            @popup.destroy                
        end
    end
end
