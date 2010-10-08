require 'jldrill/contexts/DisplayProblemContext'
require 'jldrill/views/gtk/widgets/VocabularyHintBox'
require 'gtk2'

module JLDrill::Gtk

	class ItemHintView < JLDrill::DisplayProblemContext::ProblemView::ItemHintView

        attr_reader :hintBox
        	
		def initialize(context)
            super(context)
            @hintBox = VocabularyHintBox.new
        end

        def getWidget
            @hintBox
        end

        def mainWindow
            getWidget.gtkWidgetMainWindow
        end

        # Update the indicators
        def update(problem)
            if !problem.nil?  && !problem.item.nil?
                hintBox.set(problem.item.to_o, @context.differs?(problem))
            else
                hintBox.clear
            end
        end

        def newProblem(problem)
            super(problem)
            update(problem)
        end

        def updateProblem(problem)
            super(problem)
            update(problem)
        end

    end
end
