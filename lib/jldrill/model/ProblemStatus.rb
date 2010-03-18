require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'

module JLDrill
    # Keeps track of which problem types are being reviewed and
    # their schedules
    class ProblemStatus
        attr_reader :item, :types, :schedules

        def initialize(item)
            @item = item
            @types = []
            @schedules = []
        end

        def clone
            retVal = ProblemStatus.new(item)
            retVal.assign(self)
            return retVal
        end

        def assign(value)
            value.types.each do |type|
                @types.push(type)
            end
            value.schedules.each do |schedule|
                @schedules.push(schedule.clone)
            end
        end

        def to_s
            retVal = ""
            0.upto(@types.size - 1) do |i|
                retVal += "/" + @types[i]
                if i < @schedules.size
                    retVal += @schedules[i].to_s
                end
            end
            return retVal
        end

        def currentlyParsing
            @types.size - 1
        end

        def parseType(part)
            retVal = false
            if !ProblemFactory.parse(part).nil?
                @types.push(part)
                @schedules.push(Schedule.new(@item))
                retVal = true
            end
            return retVal
        end

        def parseSchedule(part)
            retVal = false
            if currentlyParsing == -1
                # Create a temporary schedule
                sched = Schedule.new(@item)
                if sched.parse(part)
                    @types.push("MeaningProblem")
                    @schedules.push(sched)
                    retVal = true
                end
            else
                retVal = @schedules[currentlyParsing].parse(part)
            end
            return retVal
        end

        def parse(part)
            retVal = parseType(part)
            if !retVal
                retVal = parseSchedule(part)
            end
            return retVal
        end
    end
end
