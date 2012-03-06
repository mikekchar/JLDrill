# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/quiz/ProblemStatus'
require 'jldrill/model/quiz/ItemStats'

module JLDrill
    class QuizItem < Item
        def initialize(quiz, item)
            super(item)
            @quiz = quiz
            @status.add(ProblemStatus.new(self))
            @status.add(ItemStats.new(self))
        end

        def QuizItem.create(quiz, string)
            item = QuizItem.new(quiz, nil)
            item.parse(string)
            return item
        end

        def clone
            item = QuizItem.create(@quiz, @contents)
            item.assign(self)
            return item
        end
        
        def removeInvalidKanjiProblems
            problemStatus = @status.select("ProblemStatus")
            problemStatus.removeInvalidKanjiProblems
        end

        # Return the schedule for the Spaced Repetition Drill
        def schedule(threshold)
            problemStatus = @status.select("ProblemStatus")
            return problemStatus.firstSchedule(threshold)
        end

        # UpdateAll the schedules
        def scheduleAll
            problemStatus = @status.select("ProblemStatus")
            problemStatus.scheduleAll
        end

        # Demote all the schedules
        def demoteAll
            problemStatus = @status.select("ProblemStatus")
            problemStatus.demoteAll
        end
        
        def resetSchedules(threshold)
            problemStatus = @status.select("ProblemStatus")
            problemStatus.resetAll(threshold)
        end

        def allSeen(value)
            problemStatus = @status.select("ProblemStatus")
            problemStatus.allSeen(value)
        end

        def setScores(value)
            problemStatus = @status.select("ProblemStatus")
            problemStatus.setScores(value)     
        end

        def allCorrect
            problemStatus = @status.select("ProblemStatus")
            problemStatus.allCorrect     
        end

        def allIncorrect
            problemStatus = @status.select("ProblemStatus")
            problemStatus.allIncorrect     
        end

        def allReset
            problemStatus = @status.select("ProblemStatus")
            problemStatus.resetAll(@quiz.options.promoteThresh)
            itemStats.reset
        end

        def problem(threshold)
            problemStatus = @status.select("ProblemStatus")
            return problemStatus.firstProblem(threshold)
        end

        def level(threshold)
            problemStatus = @status.select("ProblemStatus")
            return problemStatus.currentLevel(threshold)
        end

        def itemStats
            return @status.select("ItemStats")
        end

    end
end

