# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class ShowStatisticsContext < Context::Context
		
		def initialize(viewBridge)
			super(viewBridge)
		end
	
        class StatisticsView < Context::View
            attr_reader  :quiz
	
            def initialize(context)
                super(context)
                @quiz = nil
            end

            # This closes the window.  It's a convenience function
            # for the test code so that it has something to catch other
            # than the context closing.        
            def close
                @context.exit
            end

            # Destroy the window containing the view
            def destroy
                # Please define in the concrete class
            end

            # Show the busy cursor in the UI if bool is true.
            # This happens during a long event where the user can't
            # interact with the window
            def showBusy(bool)
                # Please define in the concrete class
            end

            # Update the view with the statistics from the quiz
            def update(quiz)
                @quiz = quiz
                # Please define the rest of this method in the concrete class.
                # You should call super(quiz) first.
            end
        end
	
		def createViews
    		@mainView = @viewBridge.StatisticsView.new(self)
        end
        
        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def hasQuiz?(parent)
		    !parent.nil? && parent.class.public_method_defined?(:quiz) &&
		        !parent.quiz.nil?
		end
		
		def enter(parent)
		    if hasQuiz?(parent)
    		    super(parent)
    		    @mainView.update(parent.quiz)
    		    @parent.quiz.publisher.subscribe(self, "newProblem")
                @parent.longEventPublisher.subscribe(self, "startLongEvent")
                @parent.longEventPublisher.subscribe(self, "stopLongEvent")
    		end
		end
		
		def exit
		    @parent.quiz.publisher.unsubscribe(self, "newProblem")
            @parent.longEventPublisher.unsubscribe(self, "startLongEvent")
            @parent.longEventPublisher.unsubscribe(self, "stopLongEvent")
		    super
		end
		
		def newProblemUpdated(problem)
		    @mainView.update(@parent.quiz) unless @mainView.nil?
		end
        
        def startLongEventUpdated(source)
            @mainView.showBusy(true)
        end

        def stopLongEventUpdated(source)
            @mainView.showBusy(false)
        end

    end
end
