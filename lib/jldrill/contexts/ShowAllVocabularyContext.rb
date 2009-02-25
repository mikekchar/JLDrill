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
                updateWithCurrentProblem(parent.quiz)
                @parent.quiz.publisher.subscribe(self, "quiz")
                @parent.quiz.publisher.subscribe(self, "newProblem")
                @parent.quiz.publisher.subscribe(self, "problemModified")
            end
		end

        def exit
            if !@parent.nil? && !@parent.quiz.nil?
                @parent.quiz.publisher.unsubscribe(self, "quiz")
                @parent.quiz.publisher.unsubscribe(self, "newProblem")
                @parent.quiz.publisher.unsubscribe(self, "problemModified")
            end
            super
        end

        def updateWithCurrentProblem(quiz)
            item = nil
            if !quiz.currentProblem.nil?
                item = quiz.currentProblem.item
            end
            @mainView.update(quiz.allItems, item)
        end

        def updateWithLastNewProblem(quiz)
            lastPosition = quiz.contents.bins[0].length - 1
            if lastPosition >= 0
                lastItem = quiz.contents.bins[0][lastPosition]
                @mainView.update(quiz.allItems, lastItem)
            end
        end

		def quizUpdated(quiz)
            updateWithLastNewProblem(quiz)
		end

		def newProblemUpdated(quiz)
            updateWithCurrentProblem(quiz)
		end

		def problemModifiedUpdated(quiz)
            updateWithCurrentProblem(quiz)
		end
    end
end
