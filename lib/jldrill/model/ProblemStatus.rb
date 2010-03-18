require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/model/Quiz/Schedule'

module JLDrill
    # Keeps track of which problem types are being reviewed and
    # their schedules
    class ProblemStatus
        attr_reader :item, :types, :schedules
        attr_writer :item

        def initialize(item)
            @item = item
            @types = []
            @schedules = []
        end

        def name
            return "ProblemStatus"
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

        # Returns the schedule that should be addressed first
        def firstSchedule
            retVal = @schedules.max do |x,y|
                x.reviewLoad <=> y.reviewLoad
            end
            # If there is no schedule, then create a meaning problem schedule
            if retVal.nil?
                retVal = Schedule.new(@item)
                @schedules.push(retVal)
                @types.push("MeaningProblem")
            end
            return retVal
        end

        def firstProblem
            sched = firstSchedule
            index = @schedules.find_index(sched)
            level = ProblemFactory.parse(@types[index])
            return ProblemFactory.create(level, @item)
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
