
module JLDrill

    # A memento that keeps track of the quiz status for this
    # item.
    # * score is the number of times the item has been successfully
    #   drilled in the current bin.
    # * bin is the number of the bin
    # * level is 0 if meaning has not been introduced 
    #            1 if kanji has not been introduced, 
    #            2 otherwise
    # * position is the original ordinal position of the item in the quiz
    # * index is the ordinal position of the item in the bin
    #
    # Note: item is not currently being stored in the files and is not outputted
    # in to_s()
    class ItemStatus

        SCORE_RE = /^Score: (.*)/
        BIN_RE = /^Bin: (.*)/
        LEVEL_RE = /^Level: (.*)/
        POSITION_RE = /^Position: (.*)/
        LASTREVIEWED_RE = /^LastReviewed: (.*)/
        CONSECUTIVE_RE = /^Consecutive: (.*)/
        SCHEDULEDTIME_RE = /^ScheduledTime: (.*)/
        DIFFICULTY_RE = /^Difficulty: (.*)/
        
        SECONDS_PER_DAY = 60 * 60 * 24
        MAX_ADDITIONAL_TIME = 4 * SECONDS_PER_DAY

        attr_reader :score, :bin, :level, :position, :index, 
                        :lastReviewed, :consecutive, :scheduledTime,
                        :seen, :numIncorrect
        attr_writer :score, :bin, :level, :position, :index, 
                        :lastReviewed, :consecutive, :scheduledTime,
                        :seen, :numIncorrect


        def initialize
            @score = 0
            @bin = 0
            @level = 0
            @consecutive = 0
            @position = 0
            @lastReviewed = nil
            @scheduledTime = nil
            @seen = false
            @index = nil
            @numIncorrect = 0
        end
        
        # Parses the item status.
        def parse(string)
            parsed = true
            case string
                when SCORE_RE 
                    @score = $1.to_i
                when BIN_RE 
                    @bin = $1.to_i
                when LEVEL_RE
                    @level = $1.to_i
                when POSITION_RE 
                    @position = $1.to_i
                when LASTREVIEWED_RE
                    @lastReviewed = Time.at($1.to_i)
                when CONSECUTIVE_RE 
                    @consecutive = $1.to_i
                when SCHEDULEDTIME_RE
                    @scheduledTime = Time.at($1.to_i)
                when DIFFICULTY_RE
                    @numIncorrect = $1.to_i
            else # Not something we understand
                parsed = false
            end
            parsed
        end
        
        # Updates the status for the lastReviewed to be now.
        # Returns the time that it set.
        def markReviewed
            @lastReviewed = Time::now
        end
   
        # Returns true if the item has been marked reviewed at least once
        def reviewed?
            !@lastReviewed.nil?
        end
           
        # Resets the status  
        def reset
            @lastReviewed = nil
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
        
        def calculateStart
            start = Time::now
            if bin == 4
                if scheduled? && (start.to_i < @scheduledTime.to_i)
                    start = @scheduledTime
                end
            end
            start
        end
        
        def calculateInterval
            interval = firstInterval()
            if bin == 4
                if reviewed?
                    elapsed = Time::now.to_i - @lastReviewed.to_i
                    if (2 * elapsed) > interval
                        interval = 2 * elapsed
                    end
                end
            end
            interval
        end
                
        def calculateNewSchedule
            start = calculateStart
            interval = calculateInterval
            start + interval + randomVariation(interval)
        end
        
        # Schedule the item for review
        def schedule
            @scheduledTime = calculateNewSchedule
            return @scheduledTime
        end
        
        # Remove review schedule for the item
        def unschedule
            @scheduledTime = nil
        end
        
        # Return the time at which the item is scheduled for review
        def scheduledTime
            if !scheduled?
                Time::at(0)
            else
                @scheduledTime
            end
        end
        
        def firstInterval
            if difficulty <= 5
                SECONDS_PER_DAY +
                    (MAX_ADDITIONAL_TIME * (1.0 - (difficulty.to_f / 5.0))).to_i
            else
                scale = difficulty - 5
                current = 0.0
                1.upto(scale) do |x|
                    current = current + (1 - current).to_f / 10.0
                end
                (SECONDS_PER_DAY * (1.0 - current)).to_i
            end
        end
        
        def difficulty
            @numIncorrect
        end
        
        def incorrect
            @numIncorrect += 1
        end
            
        def seen?
            @seen
        end
        
        def potentialScheduleInDays
            seconds = calculateInterval.to_i
            days = (seconds * 10 / SECONDS_PER_DAY).to_f / 10
            return days
        end
        
        # Return the total number of seconds that the item from the
        # last reviewed time to the scheduled time
        def scheduleDuration
            retVal = 0
            if scheduled?
                retVal = @scheduledTime.to_i - @lastReviewed.to_i
            end
            retVal
        end
        
        def scheduleDuration=(seconds)
            if !reviewed?
                markReviewed
            end
            @scheduledTime = @lastReviewed + seconds
        end
        
        # Returns true if the item is overdue to be reviewed
        def overdue?
            @scheduledTime.to_i < Time::now.to_i
        end
        
        # Returns true if the item was reviewed on the specified day.
        # 0 is today, -1 is yesterday, -2 is the day before, etc.  Uses the
        # date, not 24 hour time period (i.e., if it's 1am, then an
        # item reviewed 2 hours ago is yesterday).
        def reviewedOn?(day)
            target = Time::now + (SECONDS_PER_DAY * day)
            @lastReviewed.day == target.day && 
                @lastReviewed.month == target.month &&
                @lastReviewed.year == target.year
        end
        
        # Returns true if the item is scheduled on the specified day.
        # 0 is today, 1 is tomorrow, 2 is the day after, etc.  Uses the
        # date, not 24 hour time period (i.e., if it's 11pm, then an
        # item scheduled in 2 hours is tomorrow).
        def scheduledOn?(day)
            target = Time::now + (SECONDS_PER_DAY * day)
            @scheduledTime.day == target.day && 
                @scheduledTime.month == target.month &&
                @scheduledTime.year == target.year
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
        
        def to_s
            retVal = "/Score: #{@score}" + "/Bin: #{@bin}" + "/Level: #{@level}" +
                "/Position: #{@position}"
            if reviewed?
                retVal += "/LastReviewed: #{@lastReviewed.to_i}"
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
