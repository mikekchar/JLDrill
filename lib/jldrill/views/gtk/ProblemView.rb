require 'Context/Gtk/Widget'
require 'jldrill/views/ProblemView'
require 'jldrill/oldUI/GtkIndicatorBox'
require 'gtk2'

module JLDrill::Gtk

	class ProblemView < JLDrill::ProblemView

        class InfoPane < Gtk::ScrolledWindow
            attr_reader :contents
        
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
	            self.pack_start(@indicatorBox, false, false)
	            @vpane = Gtk::VPaned.new
                @vpane.set_border_width(5)
                @vpane.set_position(125)
                @question = QuestionPane.new
                @answer = AnswerPane.new
                @problem = nil
                @vpane.pack1(@question, true, true)
                @vpane.pack2(@answer, true, true)
                self.pack_end(@vpane, true, true)
                @popup = nil
                
                connectSignals
	        end
	        
   			def connectSignals
	            @question.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
	            @question.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
	            @answer.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
	            @answer.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)

        		@question.contents.signal_connect('motion_notify_event') do |widget, motion|
				    characterPopup(widget, motion.window, motion.x, motion.y)
				end

        		@answer.contents.signal_connect('motion_notify_event') do |widget, motion|
				    characterPopup(widget, motion.window, motion.x, motion.y)
				end

        		@question.contents.signal_connect('leave_notify_event') do
				    closePopup
				end

        		@answer.contents.signal_connect('leave_notify_event') do
				    closePopup
				end
			end

			def closePopup
			    if !@popup.nil?
			        @popup.destroy
			        @popup = nil
			        @popupChar = nil
			    end
			end
			
			# Translates the x,y coordinates of the widget in this
			# window to absolute screen coordinates
			def toAbsPos(widget, x, y)
		        origin = @view.mainWindow.window.position
		        pos = [x + origin[0], y + origin[1]]
                widget.translate_coordinates(@view.mainWindow, pos[0], pos[1])
			end
			
			def getCharAt(widget, type, x, y)
			    coords = widget.window_to_buffer_coords(type, x, y)
			    iter, tr = widget.get_iter_at_position(coords[0], coords[1])
			    char = iter.char
		        pos = widget.get_iter_location(iter)
		        if (coords[0] > pos.x) && (coords[0] < pos.x + pos.width) &&
			      char != ""
			        rect = widget.buffer_to_window_coords(type, pos.x, pos.y)
			        [char, [rect[0], rect[1], pos.width, pos.height]]
			    else
			        nil
			    end
			end
			
			def createPopup(char)
		        popup = Gtk::Window.new(Gtk::Window::POPUP)
		        popup.set_transient_for(@view.mainWindow)
		        popup.set_destroy_with_parent(true)
		        popup.set_window_position(Gtk::Window::POS_NONE)
		        label = Gtk::Label.new(char)
		        popup.add(label)
		        popup
			end
			
			def belowRect(rect)
			    x = rect[0] + (rect[2] / 2)
			    y = rect[1] + (rect[3])
			    [x, y]
			end
			
			def characterPopup(widget, window, x, y)
			    if @view.kanjiDic.nil?
			        return
			    end
                closePopup
                type = widget.get_window_type(window)
                char, charRect = getCharAt(widget, type, x, y)
			    if !char.nil? && !(char =~ /[a-zA-Z0-9 \s]/)
			        kanjiString = @view.kanjiDic.find do |entry|
			            entry.character == char
			        end.to_s
			        @popup = createPopup(kanjiString)
			        charPos = belowRect(charRect)
			        screenPos = toAbsPos(widget, charPos[0], charPos[1])
			        @popup.move(screenPos[0], screenPos[1] )
			        @popup.show_all
			    end
			end
	        
	        def newProblem(problem, differs)
	            @problem = problem
	            @answer.clear
	            @question.update(problem)
	            if !problem.nil?  && !problem.vocab.nil?
    	            @indicatorBox.set(problem.vocab, differs)
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
		
		def mainWindow
		    @widget.mainWindow
		end
		
		def newProblem(problem, differs)
		    @problemWindow.newProblem(problem, differs)
		end
		
		def showAnswer
		    @problemWindow.showAnswer
		end
    end
    
end

