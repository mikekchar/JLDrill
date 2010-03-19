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

        def findSchedule(type)
            sched = nil
            index = @types.find_index(type)
            if !index.nil?
                sched = @schedules[index]
            end
            return sched
        end

        def addAllowed(levels)
            levels.each do |level|
                type = ProblemFactory.lookup(level)
                if findSchedule(type).nil?
                    @types.push(type)
                    @schedules.push(firstSchedule.clone)
                end
            end 
        end

        # When an item is being demoted, demote all the schedules
        def demoteAll
            @schedules.each do |schedule|
                schedule.demote
            end
        end

        # When an item is being promoted to the review set, schedule
        # each type
        def scheduleAll
            @schedules.each do |schedule|
                schedule.schedule
            end
        end

        def disallowed?(type, levels)
            retVal = false
            index = ProblemFactory.parse(type)
            if !index.nil?
                retVal = !levels.include?(index)
            end
            return retVal
        end

        def removeDisallowed(levels)
            @types.each_index do |i|
                if disallowed?(@types[i], levels)
                    @schedules.delete_at(i)
                end
            end
            @types.delete_if do |type|
                disallowed?(type, levels)
            end
        end

        # Make sure the schedule types match with the allowed ones
        # for the quiz.  If not, push a new type on.
        def checkSchedules
            if !@item.nil? && !@item.quiz.nil?
                levels = @item.quiz.options.allowedLevels
                addAllowed(levels)
                removeDisallowed(levels)
            end
        end

        def firstProblem
            # Every time we make a problem we should check to make sure
            # that correct schedules have been build.  The user may have
            # changed the options.
            checkSchedules
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
