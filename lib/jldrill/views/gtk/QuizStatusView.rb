require 'jldrill/views/gtk/widgets/QuizStatusBar'
require 'jldrill/contexts/DisplayQuizStatusContext'
require 'gtk2'

module JLDrill::Gtk

	class QuizStatusView < JLDrill::DisplayQuizStatusContext::QuizStatusView
	
        attr_reader :quizStatusBar
        	
		def initialize(context)
			super(context)
			@quizStatusBar = QuizStatusBar.new(self)
			@quizStatusBar.expandWidgetWidth
			@verified = nil
		end
		
		def getWidget
			@quizStatusBar
		end
		
		def update(quiz)
		    @quizStatusBar.update(quiz.status)
		end
    end    
end
