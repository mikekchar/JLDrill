require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowExamplesContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
        class ExampleView < Context::View
            attr_reader :exampleWindow

            def initialize(context)
                super(context)
                @exampleWindow = ExampleWindow.new(self)
            end

            # Destroy the window
            def destroy
                # Please define in the concrete class
            end

            # Update the examples in the UI
            def update(examples)
                # Please define in the concrete class
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
					if vocab.kanji.nil?
						key = vocab.reading
					else
						key = vocab.kanji
					end
					examples = @parent.tanaka.search(key)
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
		    @mainView.update(findExamples(problem)) unless @mainView.nil?
		end

        def kanjiLoaded?
            !parent.kanji.nil?
        end

        def kanjiInfo(character)
            retVal = ""
            kanji = @parent.kanji.findChar(character)
            if !kanji.nil?
                retVal = kanji.withRadical_to_s(@parent.radicals)
            else
                kana = @parent.kana.findChar(character)
                if !kana.nil?
                    retVal = kana.to_s
                end
            end
            retVal
        end

    end
end
