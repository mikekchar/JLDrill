# encoding: utf-8
require 'jldrill/model/util/Duration'
require 'jldrill/model/problems/ProblemFactory'

module JLDrill

    # Calculates and stores the Schedule information for a problem
    # in the Spaced Repetition Drill.
    # * score is the number of times the item has been successfully
    #   drilled in the current bin.
    class Schedule

        SCORE_RE = /^Score: (.*)/
        # level is deprecated
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
        INITIAL_WORKING_SET_INTERVAL = 60

        # Note: scheduledTime is deprecated
        attr_reader :name, :item, :score,
                    :lastReviewed, :scheduledTime,
                    :seen, :potential, :problemType
        attr_writer :item, :score,
                    :lastReviewed, :scheduledTime,
                    :seen, :potential


        def initialize(item, problemType)
            @name = "Schedule"
            @problemType = problemType
            @score = 0
            @lastReviewed = nil
            # scheduledTime is deprecated
            @scheduledTime = nil
            @seen = false
            @potential = Schedule.defaultPotential
            @item = item
            @duration = Duration.new
        end

        # Parse the problem type
        def Schedule.parseProblemType(string)
            retVal = nil
            if !ProblemFactory.parse(string).nil?
                retVal = string
            end
            return retVal
        end

        # Parses a single part of the Schedule information
        # Returns true if the string was successfully parsed
        def parse(string)
            retVal = true
            case string
                when SCORE_RE 
                    @score = $1.to_i
                when LEVEL_RE
                    # Level is deprecated
                    # Use the level in Legacy files to determine what
                    # the scores should really be
                    if @item.state.inWorkingSet?
                       case ProblemFactory.parse(@problemType) <=> $1.to_i
                       when -1
                           # The level is beyond this problem type
                           @score = @item.state.quiz.options.promoteThresh 
                       when 0
                           # This problem type is the correct level
                           # Leave the score as it is
                       when 1
                           # The level is below this problem type
                           @score = 0
                       end
                    end
                when LASTREVIEWED_RE
                    @lastReviewed = Time.at($1.to_i)
                when SCHEDULEDTIME_RE
                    # scheduledTime is deprecated
                    if @item.state.inReviewSet?
                        @scheduledTime = Time.at($1.to_i)
                    end
                when DIFFICULTY_RE
                    # Difficulty is deprecated
                    if @item.state.inWorkingSet?
                        @potential = (Schedule.difficultyScale($1.to_i) *
                            Schedule.defaultPotential).to_i 
                    end
                when POTENTIAL_RE
                    # Only set the potential in the working set bin.
                    # This is to take care of some legacy files with
                    # an incorrect setting
                    if @item.state.inWorkingSet?
                        @potential = $1.to_i
                    end
                when DURATION_RE
                    # Only scheduled items have durations and items should
                    # only be scheduled in the review and forgotten set.
                    # Furthermore, while the potential is saved, it is
                    # the same as the duration and some legacy files have
                    # the potential saved incorrectly.
                    if @item.state.notNewOrWorking?
                        @duration = Duration.parse($1)
                        # Fix for some legacy files
                        @potential = @duration.seconds
                    end
            else 
                retVal = false
            end
            return retVal
        end

        # Create a clone of this schedule
        def clone
            retVal = Schedule.new(@item, @problemType)
            retVal.assign(self)
            return retVal
        end

        # copy the data from the Schedule passed in to this one
        # Note: Doesn't assign the item
        def assign(schedule)
            @score = schedule.score
            @lastReviewed = schedule.lastReviewed
            # scheduledTime is deprecated
            @scheduledTime = schedule.scheduledTime
            @seen = schedule.seen
            @potential = schedule.potential
            @duration.seconds = schedule.duration
            @problemType = schedule.problemType
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

        def Schedule.initialWorkingSetInterval
            return INITIAL_WORKING_SET_INTERVAL
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
        # Note: It doesn't change the problem type
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

        # Reduce the potential scale by 20% of it's target value
        # This should be called every time a question is guessed wrong
        # in the working set
        def reducePotential(targetPotential)
            @potential = targetPotential - (0.2 * targetPotential).to_i
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
                    max = maxInterval()
                    if (interval > max) && (max > 0)
                        interval = max
                    end
                else
                    interval = @duration.seconds
                end
            else
                if (@item.state.inWorkingSet?) &&
                    (@item.state.quiz.options.interleavedWorkingSet)
                    interval = Schedule.initialWorkingSetInterval
                else
                    interval = @potential
                end 
            end
            return interval
        end
        
        # Schedule the item for review
        def schedule
            interval = calculateInterval
            @duration.seconds = interval + randomVariation(interval)
            @potential = @duration.seconds
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
        end
        
        # Mark the item as incorrect.
        def incorrect(targetPotential)
            reducePotential(targetPotential)
            unschedule
            markReviewed
            @score = 0
        end

        # Mark the item as correct.
        def correct
            if @item.state.notNewOrWorking?
                schedule()
            end
            markReviewed()
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
        # Note: The duration should never be set to 0, but if it is, this
        # will return 0.000001
        def reviewRate
            retVal = 0.000001
            dur = scheduleDuration
            if dur != 0
                retVal = elapsedTime.to_f / dur.to_f
            end
            retVal
        end

        # This is simply 1/reviewRate.  It is used to sort the
        # schedules since we want the smalled reviewRates at the
        # end of the list.
        # Note: It sets the reviewLoad to 1000000 if no time has elapsed.
        def reviewLoad
            retVal = 1000000.0
            sched = scheduleDuration.to_f
            time = elapsedTime.to_f
            if time != 0.0
                retVal = sched / time
            end
            retVal
        end
        
        # Outputs the item schedule in save format.
        def to_s
            retVal = "/#{@problemType}"
            retVal += "/Score: #{@score}"
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
