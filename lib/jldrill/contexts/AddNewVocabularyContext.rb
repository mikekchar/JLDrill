require 'Context/Context'
require 'Context/Bridge'

module JLDrill

	class AddNewVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		end
		
		def exit
		    super
		end
		
		def addVocabulary(vocab)
		    if !@parent.nil? && !@parent.quiz.nil?
    		    @parent.quiz.appendVocab(vocab)
    		    @parent.updateQuizStatus
    		end
		end
		
		def search(reading)
		    if !@parent.nil? && !@parent.reference.nil?
		        @parent.reference.search(reading)
		    else
		        []
		    end
		end
    end
end