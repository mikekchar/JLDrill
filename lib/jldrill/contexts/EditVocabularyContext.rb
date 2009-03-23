require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyView'

module JLDrill

	class EditVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
            @initialProblem = nil
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self, "Set") do
    		    if @mainView.setVocabulary
                    @mainView.close
                    true
                else
                    false
                end
    		end
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.subscribe(self, "newProblem")
                    @parent.quiz.publisher.subscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.subscribe(self, "edictLoad")
                end
                newProblemUpdated(@parent.quiz.currentProblem)
            end
		end
		
		def exit
            if !@parent.nil?
                if !@parent.quiz.nil?
                    if !@originalProblem.nil?
                        @parent.quiz.setCurrentProblem(@originalProblem)
                    end
                    @parent.quiz.publisher.unsubscribe(self, "newProblem")
                    @parent.quiz.publisher.unsubscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.subscribe(self, "edictLoad")
                end
            end
		    super
		end

        def newProblemUpdated(problem)
            update(problem)
        end

        def problemModifiedUpdated(problem)
            update(problem)
        end

        def update(problem)
            if !problem.preview?
                @originalProblem = problem
            end
		    @mainView.update(problem.item.to_o)
            @mainView.updateSearch
        end
		
		def addVocabulary(vocab)
		    # Do nothing in this context
		end
		
        def dictionaryLoaded?
            !@parent.nil? && !@parent.reference.nil? &&
                @parent.reference.loaded?
        end
        
        def loadDictionary
            @parent.loadReference unless @parent.nil?
        end

		def search(reading)
		    if dictionaryLoaded?
		        @parent.reference.search(reading).sort! do |x,y|
		            x.to_o.reading <=> y.to_o.reading
		        end
		    else
		        []
		    end
		end
		
        # Sets the vocabulary of the current problem to vocab
        # Refuses to set the vocabulary if it already exists in the
        # quiz.  Returns true if the vocabulary was set, false otherwise
		def setVocabulary(vocab)
            if !@parent.quiz.exists?(vocab)
                @originalProblem.vocab = vocab
                @parent.quiz.setCurrentProblem(@originalProblem)
                return true
            else
                return false
            end
		end

        def edictLoadUpdated(reference)
            @mainView.updateSearch unless @mainView.nil?
        end

        def preview(item)
            @parent.previewItem(item)
        end

    end
end
