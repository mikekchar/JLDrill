require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyView'

module JLDrill

	class EditVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self, "Set") do
    		    @mainView.setVocabulary
                @mainView.close
    		end
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		    @mainView.update(@parent.quiz.currentProblem.vocab)
            @mainView.updateSearch
		end
		
		def exit
		    super
		end
		
		def addVocabulary(vocab)
		    # Do nothing in this context
		end
		
		def search(reading)
		    if !@parent.nil? && !@parent.reference.nil?
		        @parent.reference.search(reading).sort! do |x,y|
		            x.reading <=> y.reading
		        end
		    else
		        []
		    end
		end
		
		def setVocabulary(vocab)
		    @parent.quiz.currentProblem.vocab = vocab
		end
    end
end
