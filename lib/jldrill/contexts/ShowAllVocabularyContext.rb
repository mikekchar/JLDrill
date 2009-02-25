require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyTableView'

module JLDrill

	class ShowAllVocabularyContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyTableView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
    		@mainView.update(parent.quiz.allItems)
		end
    end
end
