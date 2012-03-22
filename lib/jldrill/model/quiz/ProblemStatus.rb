# encoding: utf-8
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ProblemFactory'
require 'jldrill/model/quiz/Schedule'

module JLDrill
    # Keeps track of which problem types are being reviewed and
    # their schedules
    class ProblemStatus
        attr_reader :item, :quiz, :schedules
        attr_writer :item

        def initialize(quiz, item)
            @quiz = quiz
            @item = item
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
            value.schedules.each do |schedule|
                @schedules.push(schedule.clone)
            end
        end

        def addSchedule(schedule)
            # Create a problem so we can tell if this kind of item
            # can be created first.
            problem = ProblemFactory.createKindOf(schedule.problemType, @item)
            if (!problem.nil? && 
                (problem.level == problem.requestedLevel) &&
                problem.valid?)
                # If it's a valid problem, push the schedule
                @schedules.push(schedule)
            end
        end

        # This is here for legacy files that might have added
        # schedules for KanjiProblems that they don't have
        def removeInvalidKanjiProblems
            pos = @schedules.find_index do |schedule|
                schedule.problemType == "KanjiProblem"
            end
            if !pos.nil?
                problem = ProblemFactory.createKindOf("KanjiProblem", @item)
                if !problem.valid?
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
            return @schedules.find do |schedule|
                schedule.problemType == type
            end
        end

        def addAllowed(levels)
            levels.each do |level|
                type = ProblemFactory.lookup(level)
                if findSchedule(type).nil?
                    # If it can't find the correct type of schedule,
                    # duplicate the first one it finds and add it.
                    schedule = Schedule.new(@item, type)
                    fs = firstSchedule
                    if !fs.nil?
                        schedule.setSameReviewAs(fs)
                    end
                    addSchedule(schedule)
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
            indices = []
            @schedules.each_index do |i|
                if disallowed?(@schedules[i].problemType, levels)
                    indices.push(i)
                end
            end
            indices.sort! do |x, y|
                y <=> x
            end
            indices.each do |i|
                @schedules.delete_at(i)
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
            fs = firstSchedule
            if !fs.nil?
                targetPotential = fs.potential
                @schedules.each do |schedule|
                    schedule.incorrect(targetPotential)
                end
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
                # isn't a schedule yet, so we will just make a Reading problem.
                # I don't know why anyone would do this, but just in case.
                type = "ReadingProblem"
            else
                type = sched.problemType
            end
            return ProblemFactory.createKindOf(type, @item)
        end

        def to_s
            retVal = ""
            # Sort them by problem level so that the files are consistent
            s = @schedules.sort do |x, y|
                ProblemFactory.parse(x.problemType) <=> 
                ProblemFactory.parse(y.problemType)
            end
            0.upto(s.size - 1) do |i|
                retVal += s[i].to_s
            end
            return retVal
        end

        def currentlyParsing
            @schedules.size - 1
        end

        def parse(part)
            retVal = false
            type = Schedule.parseProblemType(part)
            if !type.nil?
                # Create a Schedule object for parsing.
                sched = Schedule.new(@item, type)
                if sched.parse(part)
                    @schedules.push(sched)
                    retVal = true
                end
            elsif currentlyParsing() != -1
                retVal = @schedules[currentlyParsing()].parse(part)
            end
            return retVal
        end
    end
end
