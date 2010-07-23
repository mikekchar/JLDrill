require 'jldrill/model/Quiz/Schedule'

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
            i = Duration.new
            low = 0.0
            high = 5.0
            i.days = 5.0
            1.upto(level) do
                low = i.days
                i.seconds = Schedule.backoff(i.seconds)
                high = i.days
            end
            return low.round...high.round
        end

        def Counter.getLevel(item)
            level = 0
            found = false
            while (level <= 6) && !found
                range = Counter.findRange(level)
                if item.schedule.durationWithin?(range)
                    found = true
                else
                    level += 1
                end
            end
            return level
        end

        def levelString(level)
            if level == 0
                return "Less than #{@ranges[0].end} days"
            elsif level == 7
                return "More than #{@ranges[6].end} days"
            else
                return "#{@ranges[level].begin} to #{@ranges[level].end} days"
            end
        end
    end

    class DurationCounter < Counter
        def count(item)
            found = false
            0.upto(6) do |level|
                if !found && item.schedule.durationWithin?(@ranges[level])
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
