# encoding: utf-8
require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/views/gtk/widgets/ProblemDisplay'
require 'gtk2'

module JLDrill::Gtk

	class ProblemView < JLDrill::DisplayProblemContext::ProblemView

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
            if !@timeoutID.nil?
                Gtk.timeout_remove(@timeoutID)
                @timeoutID = nil
            end
        end

        def startTimer(timeLimit)
            if timeLimit != 0.0 && @timeoutID.nil?
                # The GTK timeout is in milliseconds.
                @timeoutID = Gtk.timeout_add((timeLimit * 1000).to_i) do
                    @timeoutID = nil
                    expire
                    false
                end
            end
        end

        def clear
            super()
            @problemDisplay.clear
        end

		def newProblem(problem)
            super(problem)
		    @problemDisplay.newProblem(problem)
            stopTimer
            if !problem.nil?
                startTimer(problem.item.state.timeLimit)
            end
		end
		
		def showAnswer
		    @problemDisplay.showAnswer
            stopTimer
		end

        def expire
            @problemDisplay.expire
        end

        def updateProblem(problem)
            super(problem)
            @problemDisplay.updateProblem(problem)
            stopTimer
            if !problem.nil?
                startTimer(problem.item.state.timeLimit)
            end
        end
        
        def showBusy(bool)
            @problemDisplay.showBusy(bool)
        end
    end
    
end

