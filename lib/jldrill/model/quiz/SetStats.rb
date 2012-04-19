# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/util/Timer'
require 'jldrill/model/quiz/LevelStats'
require 'jldrill/model/quiz/Counter'

module JLDrill

    # Statistics for a set in the quiz
    class SetStats
    
        attr_reader :lastTen, :levels, :timesInTargetZone, :promoted, :reviewed
        
        SECONDS_PER_DAY = 60 * 60 * 24
        
        def initialize(quiz, binNumber)
            @quiz = quiz
            @binNumber = binNumber
            @correct = 0
            @incorrect = 0
            @lastTen = []
            @timesInTargetZone = 0
            @levels = []
            1.upto(8) do
                @levels.push(LevelStats.new)
            end
            @promoted = 0
            @reviewed = 0
            @reviewRateSum = 0
            @reviewTimer = Timer.new
        end

        # Returns the percentage of items in the last 10 that were correct
        def recentAccuracy
            retVal = 0
            if @lastTen.size > 0
                0.upto(@lastTen.size) do |i|
                    if @lastTen[i]
                        retVal += 1
                    end
                end
                retVal = (retVal * 100 / @lastTen.size).to_i
            end
            retVal
        end
       
        # Returns true if there have been at least 10 items reviewed
        # and the accuracy is at least 90% 
        def inTargetZone?
            # Don't start the countdown until we have reviewed
            # at least 10 item.
            if @reviewed <= 10
                return false
            else 
                return (recentAccuracy >= 90)
            end
        end

        # Record a result.  True means that the item was guessed
        # correctly, false means it was incorrect.        
        def record(bool)
            @lastTen.push(bool)
            while @lastTen.size > 10
                @lastTen.delete_at(0)
            end
            if inTargetZone?
                @timesInTargetZone += 1
            else
                @timesInTargetZone = 0
            end
        end
        
        # Get the appropriate LevelStat object for this item
        def getLevel(item)
            return @levels[Counter.getLevel(item)]
        end

        # Adds the reviewRate for this item to the total sum
        def recordReviewRate(item)
            if !item.state.currentSchedule.nil?
                @reviewRateSum += item.state.currentSchedule.reviewRate
            end
        end

        # Returns the bin that this object is measuring
        def reviewBin
            return @quiz.contents.bins[@binNumber]
        end

        # Average reviewRate for all the items reviewed so far
        def averageReviewRate
            retVal = 1.0
            if @reviewed != 0
                retVal = roundToOneDecimal(@reviewRateSum.to_f / @reviewed.to_f)
            end
            return retVal
        end

        # The review rate of the highest scheduled item in the bin
        def currentReviewRate
            retVal = 1.0
            if !reviewBin.empty? && !reviewBin[0].state.currentSchedule.nil?
                retVal = roundToTwoDecimals(reviewBin[0].state.currentSchedule.reviewRate)
            end
            retVal
        end

        # Record the statistics necessary when an item is correct
        def correct(item)
            if item.state.bin != @binNumber
                return
            end
            @correct += 1
            @reviewed += 1
            recordReviewRate(item)
            level = getLevel(item)
            if !level.nil?
                level.correct
            end
            record(true)
        end

        # Record the statistics necessary when the item is incorrect
        def incorrect(item)
            if item.state.bin != @binNumber
                return
            end
            @incorrect += 1
            @reviewed += 1
            recordReviewRate(item)
            level = getLevel(item)
            if !level.nil?
                level.incorrect
            end
            record(false)
        end

        # Record the statistics necessary when the item is promoted
        def promote(item)
            @promoted += 1
        end
        
        # Returns the actual % accuracy of the quiz in an integer 
        def accuracy
            retVal = 0
            if @incorrect == 0
                if @correct != 0
                    retVal = 100
                end
            else
                retVal = ((@correct * 100) / total).to_i
            end
            retVal
        end
        
        # Return the total number of reviews seen so far
        def total
            @correct + @incorrect
        end
       
        # Start the timer indicating that we are reviewing an item for this bin 
        def startTimer
            @reviewTimer.start
        end

        # Stop the timer indicating that we are reviewing an item for this bin
        def stopTimer
            @reviewTimer.stop
        end

        # The total amount of time we have spent reviewing items in this bin
        def reviewTime
            @reviewTimer.total
        end
        
        def roundToOneDecimal(value)
            value = value * 10.0
            value = value.round
            value = value.to_f / 10.0
            value
        end

        def roundToTwoDecimals(value)
            value = value * 100.0
            value = value.round
            value = value.to_f / 100.0
            value
        end

        # Amount of time spent reviewing per item reviewed in this bin
        def reviewPace
            if @reviewed > 0
                return roundToOneDecimal(reviewTime.to_f / @reviewed.to_f)
            else
                return 0.0
            end
        end

        # Amount of time spent reviewing items in this bin per item promoted from
        # the bin.
        def promotionPace
            if @promoted > 0
                return roundToOneDecimal(reviewTime.to_f / @promoted.to_f)
            else
                return 0.0
            end
        end
        
    end
end
