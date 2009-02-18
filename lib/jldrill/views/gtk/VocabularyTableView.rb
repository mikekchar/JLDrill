require 'jldrill/views/gtk/widgets/VocabularyTableWindow'
require 'jldrill/views/VocabularyTableView'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyTableView < JLDrill::VocabularyTableView

        attr_reader :vocabularyTableWindow
        	
		def initialize(context)
			super(context)
			@vocabularyTableWindow = VocabularyTableWindow.new(self)
		end
		
		def getWidget
			@vocabularyTableWindow
		end

        def destroy
            @vocabularyTableWindow.destroy
        end

        def run(quiz)
            super(quiz)
            @vocabularyTableWindow.execute
        end
    end
end

