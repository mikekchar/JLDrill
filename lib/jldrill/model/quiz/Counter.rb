# encoding: utf-8
require 'jldrill/model/quiz/Schedule'

module JLDrill
    class Counter
        attr_reader :ranges, :table

        def initialize
            @ranges = makeRanges
            @table = initializeTable
        end            

        def initializeTable
            retVal = []
            0.upto(7) do |level|
                retVal.push(0)
            end
            return retVal
        end

        def makeRanges
            retVal = []
            0.upto(6) do |level|
                retVal.push(Counter.findRange(level))
            end
            return retVal
        end

        def Counter.findRange(level)
            low = Duration.new(0)
            high = Duration.new
            high.days = 5.0
            1.upto(level) do
                low.assign(high)
                high.seconds = Schedule.backoff(low.seconds)
            end
            return low.seconds...high.seconds
        end

        def Counter.getLevel(item)
            level = 0
            found = false
            while (level <= 6) && !found
                range = Counter.findRange(level)
                if !item.state.currentSchedule.nil? &&
                    item.state.currentSchedule.durationWithin?(range)
                    found = true
                else
                    level += 1
                end
            end
            return level
        end

        # Returns the rounded number of days from seconds
        def toDays(seconds) 
            d = Duration.new(seconds)
            return d.days.round
        end

        def levelString(level)
            if level == 0
                return "Less than #{toDays(@ranges[0].end)} days"
            elsif level == 7
                return "More than #{toDays(@ranges[6].end)} days"
            else
                return "#{toDays(@ranges[level].begin)} to #{toDays(@ranges[level].end)} days"
            end
        end

        def to_s
            retVal = ""
            0.upto(7) do |i|
                retVal = retVal + levelString(i) + "    #{@table[i]}\n"
            end
            return retVal
        end
    end

    class DurationCounter < Counter
        def count(item)
            found = false
            0.upto(6) do |level|
                if !found && item.state.currentSchedule.durationWithin?(@ranges[level])
                    @table[level] += 1
                    found = true
                end
            end
            if !found
                @table[7] += 1
            end
        end
    end
end
