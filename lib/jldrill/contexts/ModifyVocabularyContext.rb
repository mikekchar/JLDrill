require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill
    class ModifyVocabularyContext < Context::Context

        def initialize(viewBridge)
            super(viewBridge)
            @originalProblem = nil
        end

        class VocabularyView < Context::View

            attr_reader :vocabulary, :actionName
            attr_writer :vocabulary

            def initialize(context, name)
                super(context)
                @vocabulary = Vocabulary.new
                @actionName = name
            end

            # Destroy the window
            def destroy
                # Please define in the concrete class
            end

            # Search for the vocabulary and update the list of choices
            def updateSearch
                # Please define in the concrete class
            end

            # gets the data from the UI and sets the @vocabulary variable
            def getVocabulary
                # Please define in the concrete class
            end

            # resets the vocabulary variable and clears the UI
            def clearVocabulary
                @vocabulary = Vocabulary.new
                # Please define the code to clear the UI in the concrete class
            end

            # update the window with the given vocabulary.
            # The concrete class should do it's thing and then call super.
            def update(vocabulary)
                oldVocab = @vocabulary
                @vocabulary = vocabulary
                # Search for the vocabulary if the reading has changed.
                if !vocabulary.reading.eql?(oldVocab.reading)
                    updateSearch
                end
            end

            # Bind this method to the action button on the UI
            def action
                getVocabulary
                @context.doAction(@vocabulary)
            end
        end

		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self, "Add")
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
                    @parent.reference.publisher.unsubscribe(self, "edictLoad")
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
            if !problem.nil? && !problem.preview?
                @originalProblem = problem
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
			
        def edictLoadUpdated(reference)
            @mainView.updateSearch unless @mainView.nil?
        end

        def preview(item)
            @parent.previewItem(item)
        end
    	
    end
end