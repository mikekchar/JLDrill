require 'jldrill/views/gtk/widgets/ProblemDisplay'
require 'gtk2'

module JLDrill::Gtk

	class ProblemView < JLDrill::ProblemView

        attr_reader :problemDisplay
        	
		def initialize(context)
			super(context)
			@problemDisplay = ProblemDisplay.new(self)
			@problemDisplay.expandWidgetWidth
			@problemDisplay.expandWidgetHeight
            @timeoutID = nil
		end
		
		def getWidget
			@problemDisplay
		end
		
		def mainWindow
		    getWidget.gtkWidgetMainWindow
		end
		
        def stopTimer
            if @timeout != 0 && !@timeoutID.nil?
                Gtk.timeout_remove(@timeoutID)
                @timeoutID = nil
            end
        end

        def startTimer
            if @timeout != 0 && @timeoutID.nil?
                @timeoutID = Gtk.timeout_add(2000) do
                    @timeoutID = nil
                    expire
                    false
                end
            end
        end

		def newProblem(problem, differs)
		    @problemDisplay.newProblem(problem, differs)
            stopTimer
            startTimer
		end
		
		def showAnswer
		    @problemDisplay.showAnswer
            stopTimer
		end

        def expire
            @problemDisplay.expire
        end

        def updateProblem(problem, differs)
            @problemDisplay.updateProblem(problem, differs)
            stopTimer
            startTimer
        end
    end
    
end

