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

        attr_reader :contents

        def initialize
            super
            setupWidget

            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            @contents = Gtk::TextView.new
            @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
            @contents.editable = false
            @contents.cursor_visible = false
            @contents.set_pixels_above_lines(5)
            self.add(@contents)
            @buffer = @contents.buffer
            @hasKanji = true
            createTags
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
        end

        def clear
            @buffer.text = ""
        end

        def text
            @buffer.text
        end

        def receive(type, string)
            if !string.nil? && !string.empty?
                if type == "reading" && !@hasKanji
                    # We want to display readings as if they were kanji
                    # if the item has no kanji.
                    type = "kanji"
                end
                @buffer.insert(@buffer.end_iter, string, type)

                # To make it fit on the screen better, hints have no
                # trailing carriage return.
                if type != "hint"
                    @buffer.insert(@buffer.end_iter, "\n", type)
                end                    
            end
        end

        def gtkAddWidget(widget)
            # We currently can't add widgets to this pane. Silently fail.
        end

        def gtkRemoveWidget(widget)
            # We currently can't remove widgets from this pane. Silently fail.
        end
    end

    # The pane that displays the question for the problem
    class QuestionPane < ProblemPane
        def update(problem)
            clear
            if !problem.nil?
                @hasKanji = problem.kanji != ""
                problem.publishQuestion(self)
            end
        end
    end        
    
    # The pane that displays the answer for the problem
    class AnswerPane < ProblemPane
        def clear
            super
            @isClear = true
        end
        
        def clear?
            @isClear
        end
        
        def update(problem)
            clear
            if !problem.nil?
                @hasKanji = problem.kanji != ""
                problem.publishAnswer(self)
                @isClear = false
            end
        end
    end
end
