require 'jldrill/views/gtk/widgets/Popup'
require 'gtk2'

module JLDrill::Gtk
    class VocabPopup < Popup
            
        def initialize(char, kanjiString, mainWindow, x, y)
            super(char, kanjiString, mainWindow, x, y)
            
            color = Gdk::Color.parse("lightblue1")
            @strokes = Gtk::TextView.new
            @strokes.wrap_mode = Gtk::TextTag::WRAP_CHAR
            @strokes.editable = false
            @strokes.cursor_visible = false
            @strokes.set_pixels_above_lines(0)
            @strokes.set_pixels_below_lines(0)
            @strokes.modify_base(Gtk::STATE_NORMAL, color)
            
            @strokeBuffer = @strokes.buffer
            @strokeBuffer.create_tag("kanji",
                                     "size" => 64 * Pango::SCALE,
                                     "justification" => Gtk::JUSTIFY_CENTER)
            @strokeBuffer.insert(@strokeBuffer.start_iter, 
                                 @character + "\n", "kanji")
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
            display 
        end

        def close
            @popup.destroy                
        end
    end
end
