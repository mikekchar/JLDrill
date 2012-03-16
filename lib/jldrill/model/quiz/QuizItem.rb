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

        def problemStatus
            return @status.select("ProblemStatus")
        end
        
        def itemStats
            return @status.select("ItemStats")
        end

        def removeInvalidKanjiProblems
            return problemStatus.removeInvalidKanjiProblems
        end

        # Return the schedule for the Spaced Repetition Drill
        def schedule
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

        def allSeen(value)
            problemStatus.allSeen(value)
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

        def level
            return problemStatus.currentLevel
        end

        def level=(level)
            problemStatus.currentLevel = level
        end

        def infoStatus
            retVal = super()
            if @bin < Strategy.reviewSetBin
                if bin == 0
                    retVal += "New"
                else
                    retVal += "#{problemStatus.currentLevel + 1}"
                end
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

