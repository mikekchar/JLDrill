# encoding: utf-8
require 'jldrill/views/gtk/widgets/Popup'
require 'gtk2'

module JLDrill::Gtk
    class KanjiPopup < Popup
            
        def initialize(char, kanjiString, mainWindow, x, y)
            super(char, mainWindow, x, y)
            
            color = Gdk::Color.parse("lightblue1")
            @kanji = Gtk::TextView.new
            @kanji.wrap_mode = Gtk::TextTag::WRAP_NONE
            @kanji.editable = false
            @kanji.cursor_visible = false
            @kanji.set_pixels_above_lines(0)
            @kanji.set_pixels_below_lines(0)
            @kanji.modify_base(Gtk::STATE_NORMAL, color)
            
            @kanjiBuffer = @kanji.buffer
            @kanjiBuffer.create_tag("strokeOrder",
                                     "size" => 120 * Pango::SCALE,
                                     "justification" => Gtk::JUSTIFY_CENTER,
                                     "family" => "KanjiStrokeOrders")
            @kanjiBuffer.insert(@kanjiBuffer.start_iter, 
                                 @character + "\n", "strokeOrder")
            @hbox.add(@kanji)
            
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
        
        def showBusy(bool)
            # TextViews have a hidden subwindow that houses the cursor
            subwindow = @contents.get_window(Gtk::TextView::WINDOW_TEXT)
            if bool
                subwindow.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                subwindow.set_cursor(nil)
            end
            Gdk::flush()
            super(bool)
        end
    end
end
