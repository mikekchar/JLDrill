require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyView'

module JLDrill

	class AddNewVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self, "Add") do
    		    @mainView.addVocabulary
    		end
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
		        if @parent.quiz.currentProblem.nil?
		            @parent.quiz.drill
        		end
    		end
		end
		
        def dictionaryLoaded?
            !@parent.nil? && !@parent.reference.nil? &&
                @parent.reference.loaded?
        end

		def search(reading)
		    if dictionaryLoaded?
		        @parent.reference.search(reading).sort! do |x,y|
		            x.reading <=> y.reading
		        end
		    else
		        []
		    end
		end
		
		def setVocabulary(vocab)
		    # Do nothing in this context
		end
    end
end
