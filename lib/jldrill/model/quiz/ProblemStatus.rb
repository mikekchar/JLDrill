# encoding: utf-8
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/model/quiz/Schedule'

module JLDrill
    # Keeps track of which problem types are being reviewed and
    # their schedules
    class ProblemStatus
        attr_reader :item, :quiz, :types, :schedules
        attr_writer :item

        def initialize(quiz, item)
            @quiz = quiz
            @item = item
            @types = []
            @schedules = []
        end

        def name
            return "ProblemStatus"
        end

        def clone
            retVal = ProblemStatus.new(@quiz, item)
            retVal.assign(self)
            return retVal
        end

        def assign(value)
            @quiz = value.quiz
            value.types.each do |type|
                @types.push(type)
            end
            value.schedules.each do |schedule|
                @schedules.push(schedule.clone)
            end
        end

        def addScheduleType(type, schedule)
            # Create a problem so we can tell if this kind of item
            # can be created first.
            problem = ProblemFactory.createKindOf(type, @item)
            if (!problem.nil? && 
                (problem.level == problem.requestedLevel) &&
                problem.valid?)
                # If it's a valid problem, push the schedule
                schedule.level = problem.level
                @schedules.push(schedule)
                @types.push(type)
            end
        end

        # This is here for legacy files that might have added
        # schedules for KanjiProblems that they don't have
        def removeInvalidKanjiProblems
            pos = @types.find_index("KanjiProblem")
            if !pos.nil?
                problem = ProblemFactory.createKindOf("KanjiProblem", @item)
                if !problem.valid?
                    @types.delete_at(pos)
                    @schedules.delete_at(pos)
                end
            end
        end

        def findScheduleForLevel(level)
            return findSchedule(ProblemFactory.lookup(level))
        end

        def currentLevel
            retVal = 3
            2.downto(0) do |i|
                s = findScheduleForLevel(i)
                if !s.nil? && (s.score < @quiz.options.promoteThresh)
                    retVal = i
                end
            end
            return retVal
        end

        def currentLevel=(level)
            # Set the scores for the schedules up to the desired
            # level to the promotion threshold.
            0.upto(level-1) do |i|
                s = findScheduleForLevel(i)
                if !s.nil? && (s.score < @quiz.options.promoteThresh)
                    s.score = @quiz.options.promoteThresh
                end
            end
            # Set the rest to 0
            (level).upto(2) do |i|
                s = findScheduleForLevel(i)
                if !s.nil?
                    s.score = 0
                end
            end
        end

        # Returns the schedule that should be addressed first
        def firstSchedule
            retVal = findScheduleForLevel(currentLevel)
            if retVal.nil?
                retVal = @schedules.min do |x,y|
                    x.reviewLoad <=> y.reviewLoad
                end
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
                    # If it can't find the correct type of schedule,
                    # duplicate the first one it finds and add it.
                    schedule = Schedule.new(@item)
                    fs = firstSchedule
                    if !fs.nil?
                        schedule.setSameReviewAs(fs)
                    end
                    addScheduleType(type, schedule)
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
                if @item.bin == Strategy.newSetBin
                    levels = []
                elsif @item.bin == Strategy.workingSetBin
                    levels = [0, 1, 2]
                else
                    levels = @quiz.options.allowedLevels
                end
                addAllowed(levels)
                removeDisallowed(levels)
                if @item.bin >= Strategy.reviewSetBin
                    @item.level = 3
                end
            end
        end

        def resetAll
            @schedules = []
            @types = []
        end

        def allSeen(value)
            @schedules.each do |schedule|
                schedule.seen = value
            end
        end

        def setScores(value)
            @schedules.each do |schedule|
                schedule.score = value
            end
        end

        def allCorrect
            @schedules.each do |schedule|
                schedule.correct
            end
        end

        def allIncorrect
            @schedules.each do |schedule|
                schedule.incorrect
            end            
        end

        def firstProblem
            # Every time we make a problem we should check to make sure
            # that correct schedules have been build.  The user may have
            # changed the options.
            checkSchedules
            sched = firstSchedule
            if sched.nil?
                # If you try to create a problem with a new set item, there
                # isn't a schedule yet, so we will just make a Meaning problem.
                # I don't know why anyone would do this, but just in case.
                type = "MeaningProblem"
            else
                index = @schedules.find_index(sched)
                type = @types[index]
            end
            return ProblemFactory.createKindOf(type, @item)
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
