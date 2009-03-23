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
                @parent.quiz.publisher.subscribe(self, "itemAdded")
            end
		end

        def exit
            if !@parent.nil? && !@parent.quiz.nil?
                @parent.quiz.publisher.unsubscribe(self, "load")
                @parent.quiz.publisher.unsubscribe(self, "newProblem")
                @parent.quiz.publisher.unsubscribe(self, "problemModified")
                @parent.quiz.publisher.unsubscribe(self, "itemAdded")
            end
            super
        end

        def differs?(item)
            exists = true
            if @parent.reference.loaded? && !item.nil?
                exists = @parent.reference.include?(item.to_o)
		    end
		    return !exists
        end

        def update(quiz)
            @mainView.update(quiz.allItems)
        end

        def select(problem)
            @mainView.select(problem.item)
        end

        def updateProblem(problem)
            @mainView.updateItem(problem.item)
        end
        
        def addItem(item)
            @mainView.addItem(item)
        end

		def loadUpdated(quiz)
            update(quiz)
		end

		def newProblemUpdated(problem)
            select(problem)
		end

		def problemModifiedUpdated(problem)
            updateProblem(problem)
		end

        def itemAddedUpdated(item)
            addItem(item)
        end

        def edit(item)
            @parent.editItem(item)
        end
    end
end
