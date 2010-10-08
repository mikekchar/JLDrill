require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowAllVocabularyContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
		
        class VocabularyTableView < Context::View
            attr_reader :quiz, :items

            def initialize(context)
                super(context)
                @quiz = nil
                @items = nil
            end

            # Destroy the window
            def destroy
                # Please define in the concrete class
            end

            # Update the items in the table
            def update(items)
                @items = items
                # Please define the rest in the concrete class
            end

            # Select one of the items in the table
            def select(item)
                # Please define in the concrete class
            end

            # Modify one of the items in the table
            # This happens when an item has been edited while the table is open
            def updateItem(item)
                # Please define in the concrete class
            end

            # Add the item to the table
            # This happens when an item has been added while the table is open
            def addItem(item)
                # Please define in the concrete class
            end

            # Remove an item from the table
            # This happens when the item has been removed while the table is
            # open
            def removeItem(item)
                # Please define in the concrete class
            end

            # Close the window
            # Closing the window exits the context.
            def close
                # Please define in the concrete class.
                # Run super() after everything is complete.
                @context.exit
            end
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
                @parent.quiz.publisher.subscribe(self, "itemDeleted")
            end
		end

        def exit
            if !@parent.nil? && !@parent.quiz.nil?
                @parent.quiz.publisher.unsubscribe(self, "load")
                @parent.quiz.publisher.unsubscribe(self, "newProblem")
                @parent.quiz.publisher.unsubscribe(self, "problemModified")
                @parent.quiz.publisher.unsubscribe(self, "itemAdded")
                @parent.quiz.publisher.unsubscribe(self, "itemDeleted")
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

        def removeItem(item)
            @mainView.removeItem(item)
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

        def itemDeletedUpdated(item)
            removeItem(item)
        end

        def edit(item)
            @parent.editItem(item)
        end

        def delete(item)
            @parent.deleteItem(item)
        end

        def preview(item)
            @parent.displayItem(item)
        end
    end
end
