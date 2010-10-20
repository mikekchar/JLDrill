require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadQuizContext'

module JLDrill

	class AppendFileContext < Context::Context

		def initialize(viewBridge)
			super(viewBridge)
            @loadQuizContext = LoadQuizContext.new(@viewBridge)
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

        def loadAsQuiz(quiz, filename)
            @loadFileContext.onExit do
                exitLoadQuizContext
            end
            @loadFileContext.enter(self, quiz, filename)
        end

        def enter(parent, quiz)
            super(parent)
            newQuiz = Quiz.new
            @loadQuizContext.onExit do
                quiz.append(newQuiz)
                exitAppendFileContext
            end
            @loadQuizContext.enter(self, newQuiz)
        end
    end		
end
