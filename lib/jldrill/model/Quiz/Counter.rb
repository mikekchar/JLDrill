class Counter
    attr_reader :found, :ranges, :table, :pos
    attr_writer :found

    def initialize(stats, start, table, pos)
        @ranges = makeRanges(stats, start)
        @found = false
        @table = table
        @pos = pos
    end            

    def makeRanges(stats, start)
        retVal = []
        0.upto(6) do |level|
            retVal.push(stats.findRange(level, start))
        end
        return retVal
    end

    def finalCount
        if !@found
            @table[7][@pos] += 1
        end
        @found = false
    end
end

class DurationCounter < Counter
    def count(schedule, level)
        if !@found && schedule.durationWithin?(@ranges[level])
            @table[level][@pos] += 1
            @found = true
        end
    end
end

