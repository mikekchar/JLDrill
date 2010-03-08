require 'jldrill/views/gtk/widgets/ProblemPane'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/views/gtk/widgets/PopupFactory'
require 'gtk2'

module JLDrill::Gtk
    
    # This is the widget that displays the problem.
    # The display is made up of 3 pieces:
    # The IndicatorBox, which shows the markers for the
    # item, the QuestionPane, which shows the question for the problem
    # and the AnswerPane which shows the answer.
    # The ProblemDisplay also interacts with the PopupFactory
    # to display the kanji/kana Popup when hovering over a character.
    class ProblemDisplay < Context::Gtk::VBox
        attr_reader :question, :answer

        def initialize(view)
            @view = view
            super()
            @vpane = Gtk::VPaned.new
            @vpane.set_border_width(5)
            @vpane.set_position(125)
            @question = QuestionPane.new
            @answer = AnswerPane.new
            @problem = nil
            @vpane.pack1(@question, true, true)
            @vpane.pack2(@answer, true, true)
            self.pack_end(@vpane, true, true)
            @popupFactory = PopupFactory.new(view)
            
            connectSignals
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
        end
        
        def showAnswer
            if !@problem.nil?
                @answer.update(@problem)
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
        
    end
end
