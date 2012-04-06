# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/quiz/ProblemStatus'
require 'jldrill/model/quiz/ItemStats'

module JLDrill
    class QuizItem < Item
        def initialize(quiz, item)
            super(item)
            @quiz = quiz
            @status.add(ProblemStatus.new(@quiz, self))
            @status.add(ItemStats.new(@quiz, self))
        end

        # Create a Quiz item from the save string.  To get around
        # some problems with legacy files (specifically schedules)
        # we need to know what bin this will be going into.
        def QuizItem.create(quiz, string, bin)
            item = QuizItem.new(quiz, nil)
            item.bin = bin
            item.parse(string)
            return item
        end

        def clone
            item = QuizItem.create(@quiz, @contents, @bin)
            item.assign(self)
            return item
        end

        def options
            return @quiz.options
        end

        def problemStatus
            return @status.select("ProblemStatus")
        end
        
        def itemStats
            return @status.select("ItemStats")
        end

        def inNewSet?
            return @bin == @quiz.contents.newSetBin
        end

        def inWorkingSet?
            return @bin == @quiz.contents.workingSetBin
        end

        def inReviewSet?
            return @bin == @quiz.contents.reviewSetBin
        end

        def inForgottenSet?
            return @bin == @quiz.contents.forgottenSetBin
        end

        def notNewOrWorking?
            return @bin > @quiz.contents.workingSetBin
        end

        def removeInvalidKanjiProblems
            return problemStatus.removeInvalidKanjiProblems
        end

        # Return the schedule for the item that is the highest priority
        # according to the strategy
        def firstSchedule
            return problemStatus.firstSchedule
        end

        def schedules
            return problemStatus.schedules
        end

        # UpdateAll the schedules
        def scheduleAll
            problemStatus.scheduleAll
        end

        # Demote all the schedules
        def demoteAll
            problemStatus.demoteAll
        end
        
        def resetSchedules
            problemStatus.resetAll
        end

        def updateSchedules
            problemStatus.checkSchedules
        end

        # Returns true if the item has been seen before.  If the
        # item has no schedule set, then it hasn't been seen before.
        def seen?
            retVal = false
            if !firstSchedule.nil?
                retVal = firstSchedule.seen
            end
            return retVal
        end

        def setAllSeen(value)
            problemStatus.setAllSeen(value)
        end

        def setScores(value)
            problemStatus.setScores(value)     
        end

        def allCorrect
            problemStatus.allCorrect     
        end

        def allIncorrect
            problemStatus.allIncorrect     
        end

        def allReset
            problemStatus.resetAll
            itemStats.reset
        end

        def problem
            return problemStatus.firstProblem
        end

        # returns true if the review rate of an item is below
        # the forgetting threshold in the options
        def reviewRateUnderThreshold
            retVal = false
            if !firstSchedule.nil?
                retVal = firstSchedule.reviewRate < options.forgettingThresh.to_f
            end
            return retVal
        end

        def level
            return problemStatus.currentLevel
        end

        def level=(level)
            problemStatus.currentLevel = level
        end

        def infoStatus
            retVal = super()
            if inNewSet?
                retVal += "New"
            elsif inWorkingSet?
                retVal += "#{problemStatus.currentLevel + 1}"
            else
                retVal += "+#{itemStats.consecutive}"
                if !problemStatus.firstSchedule.nil? &&
                    problemStatus.firstSchedule.reviewed?
                    retVal += ", #{problemStatus.firstSchedule.reviewedDate}"
                end
            end
            if !problemStatus.firstSchedule.nil?
                retVal += " --> #{problemStatus.firstSchedule.potentialScheduleInDays} days"
            end
            return retVal
        end
    end
end

