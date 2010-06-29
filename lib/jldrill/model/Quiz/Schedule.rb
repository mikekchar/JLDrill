module JLDrill

    # Calculates and stores the Schedule information for an item
    # in the Spaced Repetition Drill.
    # * score is the number of times the item has been successfully
    #   drilled in the current bin.
    # * level is 0 if meaning has not been introduced 
    #            1 if kanji has not been introduced, 
    #            2 otherwise
    class Schedule

        SCORE_RE = /^Score: (.*)/
        LEVEL_RE = /^Level: (.*)/
        LASTREVIEWED_RE = /^LastReviewed: (.*)/
        # Note: ScheduledTime is deprecated
        SCHEDULEDTIME_RE = /^ScheduledTime: (.*)/
        DIFFICULTY_RE = /^Difficulty: (.*)/
        DURATION_RE = /^Duration: (.*)/
        
        SECONDS_PER_DAY = 60 * 60 * 24
        MAX_ADDITIONAL_TIME = 4 * SECONDS_PER_DAY

        # Note: ScheduledTime is deprecated
        attr_reader :name, :item, :score, :level, 
                    :lastReviewed, :scheduledTime,
                    :seen, :numIncorrect, :duration
        attr_writer :item, :score, :level,
                    :lastReviewed, :scheduledTime,
                    :seen, :numIncorrect, :duration


        def initialize(item)
            @name = "Schedule"
            @score = 0
            @level = 0
            @lastReviewed = nil
            # scheduledTime is deprecated
            @scheduledTime = nil
            @seen = false
            @numIncorrect = 0
            @item = item
            @duration = -1
        end

        # Parses a single part of the Schedule information
        def parse(string)
            parsed = true
            case string
                when SCORE_RE 
                    @score = $1.to_i
                when LEVEL_RE
                    @level = $1.to_i
                when LASTREVIEWED_RE
                    @lastReviewed = Time.at($1.to_i)
                when SCHEDULEDTIME_RE
                    # scheduledTime is deprecated
                    if @item.bin == 4
                        @scheduledTime = Time.at($1.to_i)
                    end
                when DIFFICULTY_RE
                    @numIncorrect = $1.to_i
                when DURATION_RE
                    @duration = $1.to_i
            else # Not something we understand
                parsed = false
            end
            parsed
        end

        # Create a clone of this schedule
        def clone
            retVal = Schedule.new(@item)
            retVal.assign(self)
            return retVal
        end

        # copy the data from the Schedule passed in to this one
        # Note: Doesn't assign the item
        def assign(schedule)
            @score = schedule.score
            @level = schedule.level
            @lastReviewed = schedule.lastReviewed
            # scheduledTime is deprecated
            @scheduledTime = schedule.scheduledTime
            @seen = schedule.seen
            @numIncorrect = schedule.numIncorrect
            @duration = schedule.duration
        end
        
        # Updates the time that the item was last reviewed to be the real
        # current time.
        # Returns the time that it set.
        def markReviewed
            @lastReviewed = Time::now()
        end
   
        # Returns true if the item has been marked reviewed at least once
        def reviewed?
            !@lastReviewed.nil?
        end

        # Returns the number of seconds since the item was last reviewed
        def elapsedTime
            retVal = 0
            if reviewed?
                retVal = Time::now().to_i - @lastReviewed.to_i
            end
            return retVal
        end
           
        # Resets the schedule  
        def reset
            @lastReviewed = nil
            # scheduledTime is deprecated
            @scheduledTime = nil
            @score = 0
            @seen = false
            @numIncorrect = 0
            @duration = -1
        end
        
        # Returns true if the item has been scheduled for review
        def scheduled?
            # scheduledTime is deprecated
            (duration != -1) || (!@scheduledTime.nil?)
        end
        
        # Returns a +-10% random variation in the interval.
        # This smooths out the distribution of items and makes
        # it so that similar items aren't always together.
        def randomVariation(interval)
            # 10% - rand(20%) = +- 10%
            (interval / 10) - rand(interval / 5) 
        end

        # This is the interval the item will have when it it first
        # promoted into the Review Set.  
        #
        # It is a sliding scale based on difficulty.  If the user 
        # has never gotten the item incorrect, then the interval 
        # will be 5.0.  For each time the get it wrong, it moves 
        # closer to 0.
        def intervalFromDifficulty(diff)
            if diff <= 5
                SECONDS_PER_DAY +
                    (MAX_ADDITIONAL_TIME * (1.0 - (diff.to_f / 5.0))).to_i
            else
                scale = diff - 5
                current = 0.0
                1.upto(scale) do |x|
                    current = current + (1 - current).to_f / 10.0
                end
                (SECONDS_PER_DAY * (1.0 - current)).to_i
            end
        end

        # Calculate the difficulty from the interval.  This is used
        # to reset the difficulty of an item based on past performance.
        def difficultyFromInterval(interval)
            # to deal with corrupt files where the review times are screwed up
            if interval <= 0
                return 50
            end
            i = 0
            while interval < intervalFromDifficulty(i)
                i += 1
            end

            return i
        end
       
        # Return the maximum interval that this item can have.
        # It is calculated as twice the previous duration plus 25%
        # It will return -1 if there is no maximum
        def maxInterval
           return (@duration.to_f * 1.25).to_i * 2
        end
 
        # Return the amount of time we should wait (in ideal time)
        # for the next review.
        #
        # Calculates the interval for the item.  For newly
        # promoted items, the schedule will be the interval based on 
        # difficulty.  
        # For the rest it is twice the actual amount of time since 
        # the last review.
	# To avoid increasing the gap too much, a maximum of
	# twice the previous duration plus 25% is used.
        def calculateInterval
            interval = intervalFromDifficulty(difficulty)
            # If it is scheduled, then that means it isn't 
            # a newly promoted item
            if scheduled?
                elapsed = elapsedTime
                if (2 * elapsed) > interval
                    interval = 2 * elapsed
                    max = maxInterval
                    if (interval > max) && (max > 0)
                        interval = max
                    end
                end
                if (interval < @duration)
                    interval = @duration
                end
            end
            interval
        end
        
        def recalculateDifficulty
            # If it's scheduled, then it isn't a newly promoted item
            # Set the difficulty based on how long the person was
            # able to go since the last review.
            if scheduled?
                elapsed = elapsedTime
                diff = difficultyFromInterval(elapsed)
                if diff < @numIncorrect
                    @numIncorrect = diff
                end
            end
        end

        # Schedule the item for review
        def schedule(int = -1)
            if int < 0
                interval = calculateInterval
                @duration = interval + randomVariation(interval)
            else
                @duration = int
            end
            return @duration
        end
        
        # Remove review schedule for the item
        def unschedule
            @duration = -1
        end

        # Unschedule and reset the level and score of the item
        def demote
            unschedule
            @score = 0
            @level = 0
        end
        
        # Return the difficulty of the item.  Right now that is
        # the number of times it was incorrect.
        def difficulty
            @numIncorrect
        end
        
        # Mark the item as incorrect.
        def incorrect
            @numIncorrect += 1
            unschedule
            markReviewed
            @score = 0
        end

        # Mark the item as correct.
        def correct
            if @item.bin == 4
                recalculateDifficulty
                schedule
            end
            markReviewed
            @score += 1
        end

        # Returns true if the item has been seen before.
        def seen?
            @seen
        end

        # Converts seconds to days rounded to the nearest 10th of a day
        def secondsToDays(seconds)
            return (seconds * 10 / SECONDS_PER_DAY).to_f / 10
        end

        # Returns the total number of days the item was last
        # scheduled for.  Returns a float.
        def potentialScheduleInDays
            return secondsToDays(calculateInterval.to_i)
        end

        # Return the duration of the schedule
        # Old quizes might not have the duration stored, so it is
        # calculated from the scheduledTime.  scheduledTime is now
        # deprecated, though.
        def scheduleDuration
            retVal = -1
            if scheduled?
                if @duration == -1 && !@scheduledTime.nil?
                    retVal = @scheduledTime.to_i - @lastReviewed.to_i
                else
                    retVal = @duration
                end
            end
            return retVal
        end
        
        # Returns true if the date is on the specified day.
        # 0 is today, -1 is yesterday, 1 is tomorrow.
        # Uses the date, not 24 hour time period.
        def onDay?(current, date, day)
            target = current + (SECONDS_PER_DAY * day)
            return date.day == target.day && 
                date.month == target.month &&
                date.year == target.year
        end

        # Returns true if the item was reviewed on the specified day.
        # 0 is today, -1 is yesterday, -2 is the day before, etc.  Uses the
        # date, not 24 hour time period (i.e., if it's 1am, then an
        # item reviewed 2 hours ago is yesterday).
        def reviewedOn?(day)
            if !reviewed?
                return false
            else
                return onDay?(Time::now(), @lastReviewed, day)
            end
        end
        
        # Returns true if the scheduled duration is in the range of times
        # supplied.  The range is of the form of number of seconds from
        # the epoch
        def durationWithin?(range)
            range.include?(scheduleDuration)
        end
        
        # Returns a human readable string showing when the item
        # was last reviewed.
        def reviewedDate
            retVal = ""
            if reviewed?
                if reviewedOn?(0)
                    retVal = "Today"
                elsif reviewedOn?(-1)
                    retVal = "Yesterday"
                else
                    retVal = @lastReviewed.strftime("%x")
                end
            end
            retVal
        end

        # Returns the "velocity" for reviewing.  It shows the ratio
        # of the actual time between review vs. scheduled time.
        # Values greater than 1 mean it is taking longer than expected,
        # values less than 1 mean it is taking less time than expected.
        def reviewRate
            retVal = 1.0
            dur = scheduleDuration
            if dur != 0
                retVal = elapsedTime.to_f / dur.to_f
            end
            retVal
        end

        # This is simply 1/reviewRate.  It is used to sort the
        # schedules since we want the smalled reviewRates at the
        # end of the list.
        def reviewLoad
            retVal = 1.0
            duration = scheduleDuration.to_f
            time = elapsedTime.to_f
            if time != 0.0
                retVal = duration / time
            end
            retVal
        end
        
        # Outputs the item schedule in save format.
        def to_s
            retVal = "/Score: #{@score}" + "/Level: #{@level}"
            if reviewed?
                retVal += "/LastReviewed: #{@lastReviewed.to_i}"
            end
            if scheduled?
                retVal += "/Duration: #{scheduleDuration.to_i}"
            end
            retVal += "/Difficulty: #{difficulty}"
            retVal
        end
    end
end
