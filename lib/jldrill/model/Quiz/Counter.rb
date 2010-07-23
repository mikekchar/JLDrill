class Counter
    attr_reader :found, :ranges, :table
    attr_writer :found

    def initialize(stats)
        @ranges = makeRanges(stats)
        @found = false
        @table = initializeTable
    end            

    def initializeTable
        retVal = []
        0.upto(7) do |level|
            retVal.push([0, 0])
        end
        return retVal
    end

    def makeRanges(stats)
        retVal = []
        0.upto(6) do |level|
            retVal.push(stats.findRange(level, 0))
        end
        return retVal
    end

    def finalCount
        if !@found
            @table[7][0] += 1
        end
        @found = false
    end
end

class DurationCounter < Counter
    def count(schedule, level)
        if !@found && schedule.durationWithin?(@ranges[level])
            @table[level][0] += 1
            @found = true
        end
    end
end

