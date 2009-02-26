require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyTableView'

module JLDrill

	class ShowAllVocabularyContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyTableView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil? && !@parent.quiz.nil?
                update(@parent.quiz)
                if !@parent.quiz.currentProblem.nil?
                    select(@parent.quiz.currentProblem)
                end
                @parent.quiz.publisher.subscribe(self, "load")
                @parent.quiz.publisher.subscribe(self, "newProblem")
                @parent.quiz.publisher.subscribe(self, "problemModified")
            end
		end

        def exit
            if !@parent.nil? && !@parent.quiz.nil?
                @parent.quiz.publisher.unsubscribe(self, "load")
                @parent.quiz.publisher.unsubscribe(self, "newProblem")
                @parent.quiz.publisher.unsubscribe(self, "problemModified")
            end
            super
        end

        def update(quiz)
            @mainView.update(quiz.allItems)
        end

        def select(problem)
            @mainView.select(problem.item)
        end

		def loadUpdated(quiz)
            update(quiz)
		end

		def newProblemUpdated(problem)
            select(problem)
		end

		def problemModifiedUpdated(problem)
            select(problem)
		end
    end
end
