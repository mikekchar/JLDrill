# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/quiz/QuizItem'

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

        def loadStringQuiz(title, string)
            @sampleQuiz = JLDrill::SampleQuiz.new
            @mainContext.quiz.loadFromString(title, 
                                                @sampleQuiz.header + 
                                                @sampleQuiz.info +
                                                string)
        end

        def quiz
            @mainContext.quiz
        end

        def newSet
            quiz.contents.newSet
        end

        def workingSet
            quiz.contents.workingSet
        end

        def reviewSet
            quiz.contents.reviewSet
        end

        def forgottenSet
            quiz.contents.forgottenSet
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
            item.state.promote()
        end

        # Promote a working set item to the review set
        def promoteIntoReviewSet(item)
            0.upto(quiz.options.promoteThresh * 2) do
               drillCorrectly(item)
            end
        end

        # Create a new item.  Note that it isn't added to any bins
        def newSampleItem
            JLDrill::QuizItem.new(quiz, @sampleQuiz.sampleVocab)
        end

        # Create a new item with no Kanji.  Note that it isn't added to any bin.
        def newNoKanjiItem
            JLDrill::QuizItem.new(quiz, @sampleQuiz.noKanjiVocab)
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
