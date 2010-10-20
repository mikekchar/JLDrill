require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadQuizContext'
require 'jldrill/contexts/MergeQuizContext'

module JLDrill

	class AppendFileContext < Context::Context

		def initialize(viewBridge)
			super(viewBridge)
            @loadQuizContext = LoadQuizContext.new(@viewBridge)
            @mergeQuizContext = MergeQuizContext.new(@viewBridge)
		end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def exitAppendFileContext
            self.exit
        end

        def enter(parent, quiz)
            super(parent)
            newQuiz = Quiz.new
            @loadQuizContext.onExit do
                @mergeQuizContext.onExit do
                    if quiz.currentProblem.nil?
                        quiz.drill
                    end
                    exitAppendFileContext
                end
                @mergeQuizContext.enter(self, quiz, newQuiz)
            end
            @loadQuizContext.enter(self, newQuiz)
        end
    end		
end
