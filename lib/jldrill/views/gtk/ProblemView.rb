require 'Context/Gtk/Widget'
require 'jldrill/views/ProblemView'
require 'jldrill/oldUI/GtkIndicatorBox'
require 'gtk2'

module JLDrill::Gtk

	class ProblemView < JLDrill::ProblemView

        class InfoPane < Gtk::ScrolledWindow
            def initialize
                super
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
                                   "family" => "Times")
                @buffer.create_tag("reading", 
                                   "size" => 18 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_CENTER,
                                   "family" => "Times",
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

            def publish_kanji(string)            
                @buffer.insert(@buffer.end_iter, string + "\n", "kanji")
            end
            
            def publish_reading(string)            
                if !@hasKanji
                    readingStyle = "kanji"
                else
                    readingStyle = "reading"
                end
                @buffer.insert(@buffer.end_iter, string + "\n", readingStyle)
            end

            def publish_definitions(string)
                @buffer.insert(@buffer.end_iter, string + "\n", "definitions")
            end

            def publish_hint(string)
                @buffer.insert(@buffer.end_iter, string, "hint")
            end
            
        end

        class QuestionPane < InfoPane
            def update(problem)
                clear
                if !problem.nil?
                    @hasKanji = problem.kanji != ""
                    problem.publishQuestion(self)
                end
            end
        end        
        
        class AnswerPane < InfoPane
            def update(problem)
                clear
                if !problem.nil?
                    @hasKanji = problem.kanji != ""
                    problem.publishAnswer(self)
                end
            end
        end        
	
	    class ProblemWindow < Gtk::VBox
	        attr_reader :question, :answer

	        def initialize(view)
	            @view = view
	            super()
	            ## Create indicators
	            @indicatorBox = GtkIndicatorBox.new
	            self.pack_start(@indicatorBox, false)
	            @vpane = Gtk::VPaned.new
                @vpane.set_border_width(5)
                @vpane.set_position(125)
                @question = QuestionPane.new
                @answer = AnswerPane.new
                @problem = nil
                @vpane.pack1(@question, true, true)
                @vpane.pack2(@answer, true, true)
                self.pack_end(@vpane, true)
	        end
	        
	        def newProblem(problem)
	            @problem = problem
	            @answer.clear
	            @question.update(problem)
	            if !problem.nil?  && !problem.vocab.nil?
    	            @indicatorBox.set(problem.vocab)
    	        else
    	            @indicatorBox.clear
    	        end
	        end
	        
	        def showAnswer
	            if !@problem.nil?
    	            @answer.update(@problem)
    	        end
	        end
	        
	    end
	
        attr_reader :problemWindow
        	
		def initialize(context)
			super(context)
			@problemWindow = ProblemWindow.new(self)
			@widget = Context::Gtk::Widget.new(@problemWindow)
			@widget.expandWidth = true
			@widget.expandHeight = true
		end
		
		def getWidget
			@widget
		end
		
		def newProblem(problem)
		    @problemWindow.newProblem(problem)
		end
		
		def showAnswer
		    @problemWindow.showAnswer
		end
    end
    
end

