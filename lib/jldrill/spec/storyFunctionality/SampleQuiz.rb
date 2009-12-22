require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'

# Sample quiz functionality.  Used as a mixin within a StoryMemento
module JLDrill::StoryFunctionality
    module SampleQuiz

        def hasDefaultQuiz
            @sampleQuiz = JLDrill::SampleQuiz.new
            @mainContext.quiz = @sampleQuiz.defaultQuiz
        end

        def sampleQuiz
            @sampleQuiz
        end

        def loadQuiz
            @sampleQuiz = JLDrill::SampleQuiz.new
            if @mainContext.quiz.loadFromString("SampleQuiz", 
                                                @sampleQuiz.resetFile)
                @mainContext.quiz.drill
            end
        end

        def quiz
            @mainContext.quiz
        end
    end
end
