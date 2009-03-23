require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyView'

module JLDrill

	class AddNewVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
            @originalProblem = nil
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
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.subscribe(self, "newProblem")
                    @parent.quiz.publisher.subscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.subscribe(self, "edictLoad")
                end
                update(@parent.quiz.currentProblem)
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
        end

		def addVocabulary(vocab)
		    if !@parent.nil? && !@parent.quiz.nil?
    		    item = @parent.quiz.appendVocab(vocab)
                @parent.displayItem(item)
    		    @parent.updateQuizStatus
    		end
		end
		
        def dictionaryLoaded?
            !@parent.nil? && !@parent.reference.nil? &&
                @parent.reference.loaded?
        end

        def loadDictionary
            @parent.loadReference unless @parent.nil?
        end

		def search(reading)
		    if dictionaryLoaded? && !reading.nil? && !reading.empty?
		        @parent.reference.search(reading).sort! do |x,y|
		            x.to_o.reading <=> y.to_o.reading
		        end
		    else
		        []
		    end
		end
		
		def setVocabulary(vocab)
		    # Do nothing in this context
		end

        def edictLoadUpdated(reference)
            @mainView.updateSearch unless @mainView.nil?
        end

        def preview(item)
            @parent.previewItem(item)
        end
        
    end
end
