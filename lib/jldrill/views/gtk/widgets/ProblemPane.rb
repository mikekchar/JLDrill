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
            normalMode
            self.add(@contents)
            @buffer = @contents.buffer
            createTags
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
        end

        def text
            @buffer.text
        end

        def receive(type, string)
            if !string.nil? && !string.empty?
                @buffer.insert(@buffer.end_iter, string, type)

                # To make it fit on the screen better, hints have no
                # trailing carriage return.
                if type != "hint"
                    @buffer.insert(@buffer.end_iter, "\n", type)
                end                    
            end
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
