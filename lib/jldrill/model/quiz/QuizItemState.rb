# encoding: utf-8

require "jldrill/model/ItemState.rb"
require 'jldrill/model/quiz/ProblemStatus'
require 'jldrill/model/quiz/ItemStats'
require 'jldrill/model/problems/ProblemFactory'

module JLDrill

    # Represents the state of the item in the Quiz.
    # This is the concrete class for the default quiz type.
    class QuizItemState < ItemState

        attr_reader :problemStatus, :itemStats, :quiz
        attr_writer :quiz

        def initialize(item, quiz)
            super(item)
            @quiz = quiz
            @problemStatus = ProblemStatus.new(@quiz, item)
            @itemStats = ItemStats.new(@quiz, item)
        end

        # Assign the contents of itemState to this itemState
        def assign(itemState)
            super(itemState)
            @problemStatus = itemState.problemStatus.clone
            @problemStatus.item = @item
            @itemStats = itemState.itemStats.clone
            @itemStats.item = @item
        end

        # Make a new ItemState
        def clone()
            retVal = QuizItemState.new(@item, @quiz)
            retVal.assign(self)
            return retVal
        end

        def parsePart(part)
            parsed = super(part)
            if !parsed
                parsed = @problemStatus.parse(part)
                if !parsed
                    parsed = @itemStats.parse(part)
                end
            end
            return parsed
        end
        
        # The following are actions that change the state of an item.
        # The caller should clone the state from the item, modify it
        # using one of these methods and then set the state of the item
        # using the new state.
       
        # Some legacy files have kanji schedules without kanji in the item.
        # This method removes the kanji schedules from the state. 
        def removeInvalidKanjiProblems
            return @problemStatus.removeInvalidKanjiProblems
        end

        # Update all the schedules
        def scheduleAll
            @problemStatus.scheduleAll
        end

        # Demote all the schedules
        def demoteAll
            @problemStatus.demoteAll
        end
        
        # Reset all teh schedules
        def resetSchedules
            @problemStatus.resetAll
        end

        # Ensure that the correct schedules exist for each problem type.
        # Either create or remove schedules as needed.
        def updateSchedules
            @problemStatus.checkSchedules
        end

        # Indicate that all problems for the item have been seen in 
        # this session.
        def setAllSeen(value)
            @problemStatus.setAllSeen(value)
        end

        # Set the number of times a problem type has been correctly
        # guessed in the working set to value.  This sets all of the
        # problem types.
        def setScores(value)
            @problemStatus.setScores(value)     
        end

        # Reset the state to seem as if the item has never been used before.
        def allReset
            @problemStatus.resetAll
            @itemStats.reset
        end

        # Create a new problem
        def createProblem
            @itemStats.createProblem()
            return currentProblem()
        end

        # Indicate that the item was correct
        def correct
            @itemStats.correct
            currentSchedule.correct unless currentSchedule.nil?
            @quiz.contents.bins[@bin].correct(@item)
        end

        # Indicate that the item was incorrect
        def incorrect
            @itemStats.incorrect
            @quiz.contents.bins[@bin].incorrect(@item)
            @problemStatus.allIncorrect
        end

        # Promote the item at the request of the user
        def learn
            correct
            @quiz.contents.bins[@bin].learn(@item)
        end

        # Set the level of the item to a specific one. 0 means that
        # none of the problem types have been completed.  1 means that
        # Reading Problems have been completed. 2 means that Kanji
        # problems have been completed. 3 or greater means that all
        # problem types have been completed (and hence the item should
        # now be in the review set).
        def level=(level)
            @problemStatus.currentLevel = level
        end

        def increaseConsecutive
            @itemStats.consecutive += 1
        end

        # The following are actions to query the state of the item.
        # These methods do not change the state of the item and thus
        # there is no need to create a new state.

        # Returns true if the item is in the new set
        def inNewSet?
            return @bin == @quiz.contents.newSetBin
        end

        # Returns true if the item is in the working set
        def inWorkingSet?
            return @bin == @quiz.contents.workingSetBin
        end

        # Returns true if the item is in the review set
        def inReviewSet?
            return @bin == @quiz.contents.reviewSetBin
        end

        # Returns true if the item is in the forgotten set
        def inForgottenSet?
            return @bin == @quiz.contents.forgottenSetBin
        end

        # Returns true if the item is neither in the new nor working sets
        def notNewOrWorking?
            return @bin > @quiz.contents.workingSetBin
        end

        # Returns the schedule of the problem that should be reviewed first
        def currentSchedule
            return @problemStatus.firstSchedule
        end
        
        # Returns an array of all the schedules for this item.  For new
        # items, this will be empty.  For other items, there will be one
        # schedule for each problem type.
        def schedules
            return @problemStatus.schedules
        end
        # returns the problem that is currently showing for this item
        def currentProblem
            return @problemStatus.firstProblem
        end

        # Returns true if the item has been seen before.  If the
        # item has no schedule set, then it hasn't been seen before.
        def seen?
            retVal = false
            if !currentSchedule.nil?
                retVal = currentSchedule.seen?
            end
            return retVal
        end

        # returns true if the review rate of an item is below
        # the forgetting threshold in the options
        def reviewRateUnderThreshold?
            retVal = false
            if !currentSchedule.nil?
                retVal = currentSchedule.reviewRate < 
                    @quiz.options.forgettingThresh.to_f
            end
            return retVal
        end

        # Returns the level for items in the working set.  0 means that
        # none of the problem types have been completed.  1 means that
        # Reading Problems have been completed. 2 means that Kanji
        # problems have been completed. 3 or greater means that all
        # problem types have been completed (and hence the item should
        # now be in the review set).
        def level
            return @problemStatus.currentLevel
        end

        # Returns user feedback about the state of the item.
        def status
            retVal = super()
            if inNewSet?
                retVal += "New"
            elsif inWorkingSet?
                retVal += "#{level() + 1}"
            else
                retVal += "+#{itemStats.consecutive}"
                if !currentSchedule.nil? && currentSchedule.reviewed?
                    retVal += ", #{currentSchedule.reviewedDate}"
                end
            end
            if !currentSchedule.nil?
                retVal += " --> #{self.currentSchedule.potentialScheduleInDays} days"
            end
            return retVal
        end

        # The timeLimit is the number of seconds the user has to guess
        # the answer before the problem expires.
        def timeLimit
            return itemStats.timeLimit
        end

        # Returns a string containing the save file representation of 
        # this state
        def to_s
            return super() + @itemStats.to_s + @problemStatus.to_s 
        end
    end
end


