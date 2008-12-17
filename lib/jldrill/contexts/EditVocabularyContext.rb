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
            if (!@parent.nil?) && (!@parent.quiz.nil?)
                @parent.quiz.publisher.subscribe(self, "newProblem")
                @parent.quiz.publisher.subscribe(self, "problemModified")
                newProblemUpdated(@parent.quiz)
            end
		end
		
		def exit
            if (!@parent.nil?) && (!@parent.quiz.nil?)
                @parent.quiz.publisher.unsubscribe(self, "newProblem")
                @parent.quiz.publisher.unsubscribe(self, "problemModified")
            end
		    super
		end

        def newProblemUpdated(quiz)
            update(quiz)
        end

        def problemModifiedUpdated(quiz)
            update(quiz)
        end

        def update(quiz)
		    @mainView.update(quiz.currentProblem.item.to_o)
            @mainView.updateSearch
        end
		
		def addVocabulary(vocab)
		    # Do nothing in this context
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
		    @parent.quiz.currentProblem.vocab = vocab
		end

    end
end
