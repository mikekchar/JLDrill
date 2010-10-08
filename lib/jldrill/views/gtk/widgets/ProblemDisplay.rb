require 'jldrill/views/gtk/widgets/ProblemPane'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/views/gtk/widgets/PopupFactory'
require 'gtk2'

module JLDrill::Gtk
    
    # This is the widget that displays the problem.
    # The display is made up of 2 pieces:
    # the QuestionPane, which shows the question for the problem
    # and the AnswerPane which shows the answer.
    # The ProblemDisplay also interacts with the PopupFactory
    # to display the kanji/kana Popup when hovering over a character.
    class ProblemDisplay < Context::Gtk::VBox
        attr_reader :question, :answer

        def initialize(view)
            @view = view
            @context = @view.context
            super()
            @vpane = nil
            @question = QuestionPane.new(self)
            @answer = AnswerPane.new(self)
            @problem = nil
            @popupFactory = PopupFactory.new(view)
            packVPane
            connectSignals
        end

        def removeVPane
            if !@vpane.nil?
                @vpane.remove(@question)
                @vpane.remove(@answer)
                self.remove(@vpane)
                @vpane = nil
            end
        end

        def packVPane
            @vpane = Gtk::VPaned.new
            @vpane.set_border_width(5)
            @vpane.pack1(@question, true, true)
            @vpane.pack2(@answer, true, true)
            self.pack_end(@vpane, true, true)
            @vpane.show
        end
	        
        def connectSignals
            @question.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
            @question.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
            @answer.contents.add_events(Gdk::Event::POINTER_MOTION_MASK)
            @answer.contents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
            
            @question.contents.signal_connect('motion_notify_event') do |widget, motion|
                @popupFactory.notify(widget, motion.window, motion.x, motion.y)
            end

            @answer.contents.signal_connect('motion_notify_event') do |widget, motion|
                @popupFactory.notify(widget, motion.window, motion.x, motion.y)
            end
            
            @question.contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
            end
            
            @answer.contents.signal_connect('leave_notify_event') do
                @popupFactory.closePopup
            end
        end
        
        def newProblem(problem)
            @popupFactory.closePopup
            @problem = problem
            @answer.clear(@problem)
            @question.update(problem)
            # Attempt to adjust the size of the question pane
            # to accomodate the size of the question
            pos = @question.bufferSize
            # But don't adjust the size unnecessarily
            if pos > @vpane.position
                @vpane.position = pos
            end
        end
        
        def showAnswer
            if !@problem.nil?
                @answer.update(@problem)
                # Try to accomodate the answer size.  Always
                # keep 10% of the panel for the question, though.
                maxPos = @vpane.max_position
                minPos = (maxPos.to_f * 0.10).to_i
                pos = maxPos - @answer.bufferSize
                if pos < minPos
                    pos = minPos
                end
                # Don't adjust the size unnecessarily
                if pos < @vpane.position
                    @vpane.position = pos
                end
            end
        end

        def expire
            if !@problem.nil?
                @question.expire
            end
        end
        
        def showingAnswer?
            !@answer.clear?
        end
        
        def updateProblem(problem)
            needToDisplayAnswer = showingAnswer?
            newProblem(problem)
            if needToDisplayAnswer
                showAnswer
            end
        end

        def expandWithSavePath(filename)
            @context.expandWithSavePath(filename)
        end
        
    end
end
