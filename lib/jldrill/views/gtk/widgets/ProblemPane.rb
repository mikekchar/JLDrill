require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk

    # This is a scrolled window that shows information from
    # a problem.  There are two kinds of problem pane:
    # the QuestionPane and the AnswerPane.  The QuestionPane
    # shows the question for the problem and the AnswerPane
    # shows the answer
    class ProblemPane < Gtk::ScrolledWindow
        include Context::Gtk::Widget

        NORMAL_COLOR = Gdk::Color.parse("#ffffc0")
        DISPLAY_ONLY_COLOR = Gdk::Color.parse("#e0f0ff")
        PREVIEW_COLOR = Gdk::Color.parse("#ffe0ff")
        EXPIRED_COLOR = Gdk::Color.parse("#f07070")

        attr_reader :contents

        def initialize(display)
            super()
            @display = display
            setupWidget

            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            @contents = Gtk::TextView.new
            @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
            @contents.editable = false
            @contents.cursor_visible = false
            @contents.set_pixels_above_lines(5)
            normalMode
            self.add(@contents)
            @buffer = @contents.buffer
            createTags
            @images = []
        end

        def normalMode
            @contents.modify_base(Gtk::STATE_NORMAL, NORMAL_COLOR)
        end

        def previewMode
            @contents.modify_base(Gtk::STATE_NORMAL, PREVIEW_COLOR)
        end

        def displayOnlyMode
            @contents.modify_base(Gtk::STATE_NORMAL, DISPLAY_ONLY_COLOR)
        end

        def expiredMode
            @contents.modify_base(Gtk::STATE_NORMAL, EXPIRED_COLOR)
        end

        def createTags
            @buffer.create_tag("kanji", 
                               "size" => 36 * Pango::SCALE,
                               "justification" => Gtk::JUSTIFY_CENTER,
                               "family" => "Kochi Mincho")
            @buffer.create_tag("reading", 
                               "size" => 18 * Pango::SCALE,
                               "justification" => Gtk::JUSTIFY_CENTER,
                               "family" => "Kochi Mincho",
                               "foreground" => "blue")
            @buffer.create_tag("definitions", 
                               "size" => 16 * Pango::SCALE,
                               "justification" => Gtk::JUSTIFY_CENTER,
                               "family" => "Sans")
            @buffer.create_tag("hint", 
                               "size" => 14 * Pango::SCALE,
                               "justification" => Gtk::JUSTIFY_CENTER,
                               "family" => "Sans",
                               "foreground" => "red")
            @buffer.create_tag("image",
                               "justification" => Gtk::JUSTIFY_CENTER)
        end

        # Adds an image to the bottom of the pane
        def addImage(filename)
            filename = @display.expandWithSavePath(filename)
            image = Gtk::Image.new(filename)
            # inserting spaces on either end of the image centers it
            @buffer.insert(@buffer.end_iter," ", "image")
            if !image.pixbuf.nil?
                @buffer.insert(@buffer.end_iter, image.pixbuf)
                # This simply makes sure the image isn't garbage collected
                # because the pixbuf in the image isn't reference counted.
                @images.push(image)
            else
                @buffer.insert(@buffer.end_iter, filename + " not found.", 
                               "image")
            end
            @buffer.insert(@buffer.end_iter," ", "image")
        end

        def clear(problem)
            if !problem.nil? && problem.preview?
                previewMode
            elsif !problem.nil? && problem.displayOnly?
                displayOnlyMode
            else
                normalMode
            end

            @buffer.text = ""
            @images = []
        end

        def text
            @buffer.text
        end

        def receive(type, string)
            if !string.nil? && !string.empty?
                if (string.start_with?("image:"))
                    addImage(string[6..string.size])
                else
                    @buffer.insert(@buffer.end_iter, string, type)
                end
                @buffer.insert(@buffer.end_iter, "\n", type)
            end
        end

        # Returns the height of the buffer in buffer coordinates.
        # Note: This method must be called *after* all drawing
        # has taken place.  The easiest way to do this is to
        # put the calculation into an Gtk.idle_add block.
        def bufferSize
            # Allow the buffer to be drawn so that we get correct
            # coordinates
            iter = @buffer.end_iter
            y, height = @contents.get_line_yrange(iter)
            size = y + height
            windowType = Gtk::TextView::WINDOW_TEXT
            winx, winy = @contents.buffer_to_window_coords(windowType, 0, size)
            return winy
        end
    end

    # The pane that displays the question for the problem
    class QuestionPane < ProblemPane
        def update(problem)
            clear(problem)
            if !problem.nil?
                problem.publishQuestion(self)
            end
        end

        def expire
            expiredMode
        end

    end        
    
    # The pane that displays the answer for the problem
    class AnswerPane < ProblemPane
        def clear(problem)
            super(problem)
            @isClear = true
        end
        
        def clear?
            @isClear
        end
        
        def update(problem)
            clear(problem)
            if !problem.nil?
                problem.publishAnswer(self)
                @isClear = false
            end
        end
    end
end
