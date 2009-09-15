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
        CONSECUTIVE_RE = /^Consecutive: (.*)/
        SCHEDULEDTIME_RE = /^ScheduledTime: (.*)/
        DIFFICULTY_RE = /^Difficulty: (.*)/
        
        SECONDS_PER_DAY = 60 * 60 * 24
        MAX_ADDITIONAL_TIME = 4 * SECONDS_PER_DAY

        attr_reader :name, :item, :score, :level, 
                    :lastReviewed, :consecutive, :scheduledTime,
                    :seen, :numIncorrect
        attr_writer :item, :score, :level,
                    :lastReviewed, :consecutive, :scheduledTime,
                    :seen, :numIncorrect


        def initialize(item)
            @name = "Schedule"
            @score = 0
            @level = 0
            @consecutive = 0
            @lastReviewed = nil
            @scheduledTime = nil
            @seen = false
            @numIncorrect = 0
            @item = item
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
                when CONSECUTIVE_RE 
                    @consecutive = $1.to_i
                when SCHEDULEDTIME_RE
                    if @item.bin == 4
                        @scheduledTime = Time.at($1.to_i)
                    end
                when DIFFICULTY_RE
                    @numIncorrect = $1.to_i
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
            @consecutive = schedule.consecutive
            @lastReviewed = schedule.lastReviewed
            @scheduledTime = schedule.scheduledTime
            @seen = schedule.seen
            @numIncorrect = schedule.numIncorrect
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

        # Return the time that the item was reviewed.  If it wasn't
        # reviewed mark it reviewed and return now.
        def reviewedTime
            if !reviewed?
                markReviewed
            end
            return @lastReviewed
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
            @scheduledTime = nil
            @score = 0
            @consecutive = 0
            @seen = false
            @numIncorrect = 0
        end
        
        # Returns true if the item has been scheduled for review
        def scheduled?
            !@scheduledTime.nil?
        end
        
        # Returns a +-10% random variation in the interval.
        # This smooths out the distribution of items and makes
        # it so that similar items aren't always together.
        def randomVariation(interval)
            # 10% - rand(20%) = +- 10%
            (interval / 10) - rand(interval / 5) 
        end

        # Schedule times are based are not fixed.  They are
        # relative to the schedule date of the first reviewed
        # item.  That's because when we are reviewing, the
        # first item will be reviewed "now".
        def nowForScheduling
            # Set a default "Now"
            retVal = Time::now
            if !@item.nil? && !@item.container.nil?
                firstItem = @item.container.bins[4][0]
                if !firstItem.nil? && firstItem.schedule.scheduled?
                    retVal = firstItem.schedule.scheduledTime
                end
            end
            return retVal
        end

        # Return the time where we should measure the interval from.
        # We want to start from the date the current item is
        # scheduled for, rather than now.  Otherwise if the user
        # is ahead we could end up scheduling in the past.
        def calculateStart
            start = nowForScheduling()
            if @item.bin == 4
                if scheduled? && (start.to_i < @scheduledTime.to_i)
                    start = @scheduledTime
                end
            end
            start
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
        
        # Return the amount of time we should wait (in ideal time)
        # for the next review.
        #
        # Calculates the interval for the item.  For newly
        # promoted items, the schedule will be the interval based on 
        # difficulty.  
        # For the rest it is twice the actual amount of time since 
        # the last review.
        def calculateInterval
            interval = intervalFromDifficulty(difficulty)
            # If it is scheduled, then that means it isn't 
            # a newly promoted item
            if scheduled?
                elapsed = elapsedTime
                if (2 * elapsed) > interval
                    interval = 2 * elapsed
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
            start = calculateStart
            if int < 0
                interval = calculateInterval
                interval = interval + randomVariation(interval)
            else
                interval = int
            end
            @scheduledTime = start + interval 
            return @scheduledTime
        end
        
        # Remove review schedule for the item
        def unschedule
            @scheduledTime = nil
        end
        
        # Return the time at which the item is scheduled for review
        def getScheduledTime
            if !scheduled?
                Time::at(0)
            else
                @scheduledTime
            end
        end
        
        # Set the scheduled time to a specific value
        def setScheduledTime(time)
            @scheduledTime = time
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
            @consecutive = 0
        end

        # Mark the item as correct.
        def correct
            recalculateDifficulty
            schedule
            markReviewed
            @score += 1
            if @item.bin == 4
                @consecutive += 1
            end
        end

        # Returns true if the item has been seen before.
        def seen?
            @seen
        end

        # Returns the total number of days the item was last
        # scheduled for.  Returns a float.
        def potentialScheduleInDays
            seconds = calculateInterval.to_i
            days = (seconds * 10 / SECONDS_PER_DAY).to_f / 10
            return days
        end
        
        # Return the total number of seconds from the
        # last reviewed time to the scheduled time
        def scheduleDuration
            retVal = 0
            if scheduled?
                retVal = @scheduledTime.to_i - reviewedTime().to_i
            end
            retVal
        end
        
        # Returns true if the item is overdue to be reviewed
        # Obsolete.  This should never happen any more.
        def overdue?
            if !scheduled?
                return false
            else
                @scheduledTime.to_i < nowForScheduling().to_i
            end
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
                return onDay?(Time::now(), reviewedTime(), day)
            end
        end
        
        # Returns true if the item is scheduled on the specified day.
        # 0 is today, 1 is tomorrow, 2 is the day after, etc.  Uses the
        # date, not 24 hour time period (i.e., if it's 11pm, then an
        # item scheduled in 2 hours is tomorrow).
        def scheduledOn?(day)
            if !scheduled?
                return false
            else
                return onDay?(nowForScheduling(), @scheduledTime, day)
            end
        end
        
        # Returns true if the item has a schedule duration in the range of days
        # supplied.  Unlike scheduledOn?, this uses a 24 hour time period for
        # each day.  The range does *not* include the end point.  Note that
        # 1..1, etc will always return false.
        def durationWithin?(range)
            low = SECONDS_PER_DAY * range.begin
            high = SECONDS_PER_DAY * range.end
            scheduleDuration >= low && scheduleDuration < high
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
                    retVal = reviewedTime().strftime("%x")
                end
            end
            retVal
        end
        
        # Outputs the item schedule in save format.
        def to_s
            retVal = "/Score: #{@score}" + "/Level: #{@level}"
            if reviewed?
                retVal += "/LastReviewed: #{reviewedTime().to_i}"
            end
            if !@consecutive.nil?
                retVal += "/Consecutive: #{@consecutive.to_i}"
            end
            if scheduled?
                retVal += "/ScheduledTime: #{@scheduledTime.to_i}"
            end
            retVal += "/Difficulty: #{difficulty}"
            retVal
        end
    end
end
