# encoding: utf-8
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ReadingProblem'
require 'jldrill/model/problems/KanjiProblem'
require 'jldrill/model/problems/MeaningProblem'

module JLDrill
    class ProblemFactory
        PROBLEM_TYPES = ["ReadingProblem", "KanjiProblem", "MeaningProblem"]

        def ProblemFactory.parse(string)
            return PROBLEM_TYPES.find_index(string)
        end

        def ProblemFactory.lookup(level)
            return PROBLEM_TYPES[level]
        end

        def ProblemFactory.create(level, item)
            problem = nil
            # Try to make the problem at the requested level
            # but if it is invalid, go to the next one.  If all
            # else fails, make a reading problem (which is always
            # valid).
            requestedLevel = level
            while (problem.nil?  || !problem.valid?) && level < 4
                case level
                when 0
                    problem = ReadingProblem.new(item)
                when 1
                    problem = KanjiProblem.new(item)
                when 2
                    problem = MeaningProblem.new(item)
                else
                    problem = ReadingProblem.new(item)
                end
                problem.requestedLevel = requestedLevel
                level += 1
            end
            return problem
        end

        def ProblemFactory.createKindOf(type, item)
            level = ProblemFactory.parse(type)
            return ProblemFactory.create(level, item)
        end
    end
end
