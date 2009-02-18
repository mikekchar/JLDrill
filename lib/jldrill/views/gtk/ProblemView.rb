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
		end
		
		def getWidget
			@problemDisplay
		end
		
		def mainWindow
		    getWidget.gtkWidgetMainWindow
		end
		
		def newProblem(problem, differs)
		    @problemDisplay.newProblem(problem, differs)
		end
		
		def showAnswer
		    @problemDisplay.showAnswer
		end

        def updateProblem(problem, differs)
            @problemDisplay.updateProblem(problem, differs)
        end
    end
    
end

