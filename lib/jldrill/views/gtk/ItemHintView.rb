require 'jldrill/views/ItemHintView'
require 'jldrill/views/gtk/widgets/VocabularyHintBox'
require 'gtk2'

module JLDrill::Gtk

	class ItemHintView < JLDrill::ItemHintView

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
        def update(problem, differs)
            if !problem.nil?  && !problem.item.nil?
                hintBox.set(problem.item.to_o, differs)
            else
                hintBox.clear
            end
        end

        def newProblem(problem, differs)
            update(problem, differs)
        end

    end
end
