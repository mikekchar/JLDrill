require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'
require 'jldrill/contexts/behaviour/SearchDictionary'

module JLDrill

	class DisplayProblemContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end

        include JLDrill::Behaviour::SearchDictionary
		
        class ProblemView < Context::View

            # The ItemHintView displays information about the current item
            # that acts as hints for the user.  For instance, it might
            # indicate that the word is intrasitive, or a suru noun, etc.
            class ItemHintView < Context::View
                def initialize(context)
                    super(context)
                end

                def newProblem(problem)
                    # Should be overridden in the concrete class
                end	

                def updateProblem(problem)
                    # Should be overridden in the concrete class
                end

                def differs?(problem)
                    @context.differs?(problem)
                end
            end

            attr_reader :itemHints

            def initialize(context)
                super(context)
                @itemHints = context.viewBridge.ItemHintView.new(context)
            end

            # Modify the viewAddedTo hook to add the ItemHintView
            def viewAddedTo(parent)
                self.addView(@itemHints)
            end

            # Modify the removingViewFrom hook to remove the ItemHintView
            def removingViewFrom(parent)
                self.removeView(@itemHints)
            end

            # A new problem has been added
            def newProblem(problem)
                itemHints.newProblem(problem)
                # Define the rest in the concrete class
            end	

            # The current problem has changed and needs updating
            def updateProblem(problem)
                itemHints.updateProblem(problem)
                # Define the rest in the concrete class
            end

            # Show the answer to the problem
            def showAnswer
                # Should be overridden in the concrete class
            end
        end

        def createViews
            @mainView = @viewBridge.ProblemView.new(self)
        end

        def destroyViews
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil?
                if !@parent.quiz.nil?
                    @parent.quiz.publisher.subscribe(self, "load")
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
                    @parent.quiz.publisher.unsubscribe(self, "load")
                    @parent.quiz.publisher.unsubscribe(self, "newProblem")
                    @parent.quiz.publisher.unsubscribe(self, "problemModified")
                end
                if !@parent.reference.nil?
                    @parent.reference.publisher.unsubscribe(self, "edictLoad")
                end
            end
		    super
		end

        def differs?(problem)
            exists = true
            if @parent.reference.loaded? && !problem.nil?
                exists = @parent.reference.include?(problem.item.to_o)
		    end
		    return !exists
        end

        def loadUpdated(quiz)
            # There isn't likely a new problem at this point, but this
            # will clear the panes and update the status for the new
            # quiz
            newProblemUpdated(quiz.currentProblem)
        end

		def newProblemUpdated(problem)
            @mainView.newProblem(problem)
		end

		def problemModifiedUpdated(problem)
            @mainView.updateProblem(problem)
		end

		def edictLoadUpdated(reference)
            quiz = @parent.quiz
            @mainView.updateProblem(quiz.currentProblem)
		end

        def showAnswer
            @mainView.showAnswer
        end
        
        def expandWithSavePath(filename)
            if !@parent.quiz.nil?
                return @parent.quiz.useSavePath(filename)
            else
                return filename
            end
        end
    end
end
