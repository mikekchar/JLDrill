# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'

# Sample quiz functionality.  Used as a mixin within a StoryMemento
module JLDrill::StoryFunctionality
    module SampleQuiz

        def hasDefaultQuiz
            @sampleQuiz = JLDrill::SampleQuiz.new
            @mainContext.quiz = @sampleQuiz.defaultQuiz
        end

        def hasResetQuiz
            @sampleQuiz = JLDrill::SampleQuiz.new
            @mainContext.quiz = @sampleQuiz.resetQuiz
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
        
        def newSet
            quiz.strategy.newSet
        end

        def reviewSet
            quiz.strategy.reviewSet
        end

        def currentItem
            quiz.currentProblem.item
        end

        # Create a problem for the item and set it as correct
        def drillCorrectly(item)
            quiz.createProblem(item)
            quiz.correct
        end

        # Create a problem for the item and set it as correct
        def drillIncorrectly(item)
            quiz.createProblem(item)
            quiz.incorrect
        end

        # Promote a new set item to the working set
        def promoteIntoWorkingSet(item)
            quiz.strategy.promote(item)
        end

        # Promote a working set item to the review set
        def promoteIntoReviewSet(item)
            0.upto(2) do
               drillCorrectly(item)
            end
        end

        # Return a float containing the number of days for the given
        # number of seconds
        def secondsInDays(duration)
            return duration.to_f / (60 * 60 * 24)
        end

        # Return the number of seconds for the given number of days.
        def daysInSeconds(days)
            return (days.to_f * (60 * 60 * 24)).round
        end

        def setDaysAgoReviewed(schedule, days)
            schedule.lastReviewed = Time::now() - daysInSeconds(days)
        end

    end
end
