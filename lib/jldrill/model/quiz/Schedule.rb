# encoding: utf-8
require 'jldrill/model/util/Duration'
require 'jldrill/model/quiz/Strategy'

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
        # Note: Difficulty is deprecated
        DIFFICULTY_RE = /^Difficulty: (.*)/
        POTENTIAL_RE = /^Potential: (.*)/
        DURATION_RE = /^Duration: (.*)/
       
        SECONDS_PER_DAY = 60 * 60 * 24
        DEFAULT_POTENTIAL = 5 * SECONDS_PER_DAY

        # Note: ScheduledTime is deprecated
        attr_reader :name, :item, :score, :level, 
                    :lastReviewed, :scheduledTime,
                    :seen, :potential
        attr_writer :item, :score, :level,
                    :lastReviewed, :scheduledTime,
                    :seen, :potential


        def initialize(item)
            @name = "Schedule"
            @score = 0
            @level = 0
            @lastReviewed = nil
            # scheduledTime is deprecated
            @scheduledTime = nil
            @seen = false
            @potential = Schedule.defaultPotential
            @item = item
            @duration = Duration.new
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
                    if @item.bin == Strategy.reviewSetBin
                        @scheduledTime = Time.at($1.to_i)
                    end
                when DIFFICULTY_RE
                    # Difficulty is deprecated convert to potential schedule
                    @potential = (Schedule.difficultyScale($1.to_i) *
                                  Schedule.defaultPotential).to_i 
                when POTENTIAL_RE
                    @potential = $1.to_i
                when DURATION_RE
                    @duration = Duration.parse($1)
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
            @potential = schedule.potential
            @duration.seconds = schedule.duration
        end

        def setSameReviewAs(schedule)
            @lastReviewed = schedule.lastReviewed
            # scheduledTime is deprecated
            @scheduledTime = schedule.scheduledTime
            @potential = schedule.potential
            @duration.seconds = schedule.duration
        end

        def Schedule.defaultPotential
            return DEFAULT_POTENTIAL
        end

        def duration=(seconds)
            @duration.seconds = seconds
        end

        def duration
            return @duration.seconds
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
            @potential = DEFAULT_POTENTIAL
            @duration = Duration.new
        end
        
        # Returns true if the item has been scheduled for review
        def scheduled?
            # scheduledTime is deprecated
            (@duration.valid?) || (!@scheduledTime.nil?)
        end
        
        # Returns a +-10% random variation in the interval.
        # This smooths out the distribution of items and makes
        # it so that similar items aren't always together.
        def randomVariation(interval)
            # 10% - rand(20%) = +- 10%
            ((interval.to_f / 10) - rand(interval.to_f / 5)).to_i 
        end

        # This is used for old files.  It calculates the scale to
        # multiply the potential scale with based on the difficulty.
        # It drops geometrically 20% of the remaining
        # amount for each level of difficulty.
        def Schedule.difficultyScale(diff)
            retVal = 1.0
            0.upto(diff - 1) do
                retVal = retVal - (0.2 * retVal)
            end
            return retVal
        end

        # Reduce the potential scale by 20% of it's current value
        # This should be called every time a question is guessed wrong
        # in the working set
        def reducePotential
            @potential = @potential - (0.2 * @potential).to_i
        end

        # Return the the new interval after backing off
        def Schedule.backoff(interval)
            sixMonths = Duration.new
            sixMonths.days = 180
            if(interval < sixMonths.seconds)
                factor = 2.0 - (interval.to_f / sixMonths.seconds.to_f)
                return (factor * interval).to_i
            else
                return (interval).to_i
            end
        end

        # Return the maximum interval that this item can have.
        # It is calculated as twice the previous duration plus 25%
        # It will return -1 if there is no maximum
        def maxInterval
           return Schedule.backoff(@duration.seconds.to_f * 1.25)
        end
 
        # Return the amount of time we should wait (in ideal time)
        # for the next review.
        #
        # Calculates the interval for the item.  For newly
        # promoted items, it will be the potential schedule
        # For the rest it is based on the actual amount of time since 
        # the last review. A reducing backoff algorithm computes the
        # multiple.
	    # To avoid increasing the gap too much, a maximum of
	    # twice the previous duration plus 25% is used.
        def calculateInterval
            # If it is scheduled, then that means it isn't 
            # a newly promoted item
            if scheduled?
                elapsed = elapsedTime
                if Schedule.backoff(elapsed) > @duration.seconds
                    interval = Schedule.backoff(elapsed) 
                    max = maxInterval
                    if (interval > max) && (max > 0)
                        interval = max
                    end
                else
                    interval = @duration.seconds
                end
            else
                interval = @potential 
            end
            return interval
        end
        
        # Schedule the item for review
        def schedule(int = -1)
            if int < 0
                interval = calculateInterval
                @duration.seconds = interval + randomVariation(interval)
            else
                @duration.seconds = int
            end
            return @duration.seconds
        end
        
        # Remove review schedule for the item
        def unschedule
            @duration = Duration.new
        end

        # Unschedule and reset the level and score of the item
        def demote
            unschedule
            @score = 0
            @level = 0
        end
        
        # Mark the item as incorrect.
        def incorrect
            reducePotential
            unschedule
            markReviewed
            @score = 0
        end

        # Mark the item as correct.
        def correct
            if @item.bin == Strategy.reviewSetBin
                if @potential < elapsedTime
                    @potential = elapsedTime
                end
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
                if (!@duration.valid?) && !@scheduledTime.nil?
                    retVal = @scheduledTime.to_i - @lastReviewed.to_i
                else
                    retVal = @duration.seconds
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
            sched = scheduleDuration.to_f
            time = elapsedTime.to_f
            if time != 0.0
                retVal = sched / time
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
            retVal += "/Potential: #{@potential}"
            retVal
        end
    end
end
