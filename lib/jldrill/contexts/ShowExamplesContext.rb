# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowExamplesContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
            @examples = nil
		end
		
        include JLDrill::Behaviour::SearchDictionary

        class ExampleView < Context::View
            attr_reader :exampleWindow

            def initialize(context)
                super(context)
            end

            # Destroy the window
            def destroy
                # Please define in the concrete class
            end

            # Update the examples in the UI showing only native language
            def updateNativeOnly(examples)
                # Please define in the concrete class
            end

            # Update the examples in the UI showing only target language
            def updateTargetOnly(examples)
                # Please define in the concrete class
            end

            # Update the examples in the UI
            def update(examples)
                # Please define in the concrete class
            end

            # Show the busy cursor in the UI if bool is true.
            # This happens during a long event where the user can't
            # interact with the window
            def showBusy(bool)
                # Please define in the concrete class
            end

            # This is a convenience function for the tests so that
            # they don't have to catch the close on the context
            def close
                @context.exit
            end
        end	

        def createViews
            @mainView = @viewBridge.ExampleView.new(self)
        end
        
        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def canDisplay?(parent)
		    !parent.nil? && parent.class.public_method_defined?(:quiz) &&
		        !parent.quiz.nil? && parent.exampleDB.loaded?(parent.quiz.options)
		end
	
		def findExamples(problem)
			examples = []
			if !problem.nil?
				vocab = problem.item.to_o
				if !vocab.nil?
					examples = @parent.exampleDB.search(vocab.kanji, 
                                                        vocab.reading,
                                                        @parent.quiz.options)
				end
			end
			return examples
		end

		def enter(parent)
		    if canDisplay?(parent)
    		    super(parent)
    		    @mainView.update(findExamples(@parent.quiz.currentProblem))
    		    @parent.quiz.publisher.subscribe(self, "newProblem")
    		    @parent.quiz.publisher.subscribe(self, "load")
                @parent.longEventPublisher.subscribe(self, "startLongEvent")
                @parent.longEventPublisher.subscribe(self, "stopLongEvent")
                newProblemUpdated(@parent.quiz.currentProblem)
    		end
		end
		
		def exit
		    @parent.quiz.publisher.unsubscribe(self, "newProblem")
		    @parent.quiz.publisher.unsubscribe(self, "load")
            @parent.longEventPublisher.unsubscribe(self, "startLongEvent")
            @parent.longEventPublisher.unsubscribe(self, "stopLongEvent")
		    super
		end
		
		def newProblemUpdated(problem)
            if !@mainView.nil? && !problem.nil?
                @examples = findExamples(problem)
                if (problem.name.eql?("MeaningProblem"))
                    @mainView.updateNativeOnly(@examples)
                else
                    @mainView.updateTargetOnly(@examples)
                end
            end
		end

        def loadUpdated(quiz)
            # The language might have changed, so we might need to
            # load a new index file
            @parent.loadExamples
        end

        def startLongEventUpdated(source)
            @mainView.showBusy(true)
        end

        def stopLongEventUpdated(source)
            @mainView.showBusy(false)
        end

        def showAnswer()
            @mainView.update(@examples) unless @mainView.nil?
        end

    end
end
