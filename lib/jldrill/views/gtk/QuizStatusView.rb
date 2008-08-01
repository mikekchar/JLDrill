require 'Context/Gtk/Widget'
require 'jldrill/views/QuizStatusView'
require 'gtk2'

module JLDrill::Gtk

	class QuizStatusView < JLDrill::QuizStatusView
	
	    class QuizStatusBar < Gtk::Statusbar

            attr_reader :text

	        def initialize(view)
	            @view = view
	            super()
	            @text = ""
	            @id = get_context_id("Update quiz status")
	        end
	        
	        def update(string)
	            @text = string
	            pop(@id)
	            push(@id, string)
	        end
	        
	    end
	
        attr_reader :quizStatusBar
        	
		def initialize(context)
			super(context)
			@quizStatusBar = QuizStatusBar.new(self)
			@widget = Context::Gtk::Widget.new(@quizStatusBar)
			@verified = nil
		end
		
		def getWidget
			@widget
		end
		
		def verifiedTag
		    retVal = ""
		    if !@verified.nil?
		        if @verified
		            retVal = " -- OK"
		        else
		            retVal = " -- XX"
		        end
		    end
		    retVal
		end
		
		def update(quiz)
		    @quizStatusBar.update(quiz.status + verifiedTag)
		end
		
		def vocabVerified(quiz, bool)
		    @verified = bool
		    update(quiz)
        end
    end
    
end

