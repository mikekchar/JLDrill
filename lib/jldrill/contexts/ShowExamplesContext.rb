require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowExamplesContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
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

            # Update the examples in the UI
            def update(examples)
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
		        !parent.quiz.nil? && parent.tanaka.loaded?
		end
	
		def findExamples(problem)
			examples = []
			if !problem.nil?
				vocab = problem.item.to_o
				if !vocab.nil?
					examples = @parent.tanaka.search(vocab.kanji, vocab.reading)
				end
			end
			return examples
		end

		def enter(parent)
		    if canDisplay?(parent)
    		    super(parent)
    		    @mainView.update(findExamples(@parent.quiz.currentProblem))
    		    @parent.quiz.publisher.subscribe(self, "newProblem")
    		end
		end
		
		def exit
		    @parent.quiz.publisher.unsubscribe(self, "newProblem")
		    super
		end
		
		def newProblemUpdated(problem)
		    @mainView.update(nil) unless @mainView.nil?
		end

        def showAnswer()
            @mainView.update(findExamples(@parent.quiz.currentProblem)) unless @mainView.nil?
        end

    end
end
