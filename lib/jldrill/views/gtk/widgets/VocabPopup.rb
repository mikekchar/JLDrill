# encoding: utf-8
require 'jldrill/views/gtk/widgets/Popup'
require 'gtk2'

module JLDrill::Gtk
    class VocabPopup < Popup
            
        def initialize(char, jwords, mainWindow, x, y)
            super(char, mainWindow, x, y)
            
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
                                     "size" => 32 * Pango::SCALE,
                                     "justification" => Gtk::JUSTIFY_CENTER)
            @strokeBuffer.insert(@strokeBuffer.start_iter, 
                                 char, "kanji")
            @hbox.add(@strokes)
            spacer = Gtk::TextView.new
            spacer.set_width_request(10)
            spacer.modify_base(Gtk::STATE_NORMAL, color)
            @hbox.add(spacer)

            if !jwords.empty?
                @contents = Gtk::TextView.new
                @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                @contents.editable = false
                @contents.cursor_visible = false
                @contents.set_pixels_above_lines(0)
                @contents.modify_base(Gtk::STATE_NORMAL, color)
                @contents.set_width_request(420)
                
                @buffer = @contents.buffer
                @buffer.create_tag("japanese", 
                                   "size" => 12 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_LEFT)
                @buffer.create_tag("definition", 
                                   "size" => 8 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_LEFT)
                jwords.each do |word|
                    if !word.kanji.nil?
                        @buffer.insert(@buffer.end_iter, word.kanji, "japanese")
                        @buffer.insert(@buffer.end_iter, "    ", "japanese")
                    end
                    @buffer.insert(@buffer.end_iter, word.reading, "japanese")
                    @buffer.insert(@buffer.end_iter, "\n", "japanese")
                    @buffer.insert(@buffer.end_iter, word.toMeaning, 
                                   "definition")
                    @buffer.insert(@buffer.end_iter, "\n", "definition")
                end
                @hbox.add(@contents)
            end
            @popup.set_default_size(450, 30)
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
