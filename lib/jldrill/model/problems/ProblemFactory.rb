# encoding: utf-8
require 'jldrill/model/Problem'
require 'jldrill/model/problems/ReadingProblem'
require 'jldrill/model/problems/KanjiProblem'
require 'jldrill/model/problems/MeaningProblem'

module JLDrill
    class ProblemFactory
        PROBLEM_TYPES = ["ReadingProblem", "KanjiProblem", "MeaningProblem"]

        def ProblemFactory.parse(string)
            PROBLEM_TYPES.find_index(string)
        end

        def ProblemFactory.lookup(level)
            return PROBLEM_TYPES[level]
        end

        def ProblemFactory.create(level, item)
            case level
                when 0
                    problem = ReadingProblem.new(item)
                when 1
                    if item.hasKanji?
                        problem = KanjiProblem.new(item)
                    else
                        problem = MeaningProblem.new(item)
                    end
                when 2
                    problem = MeaningProblem.new(item)
                else
                   problem = ReadingProblem.new(item)
             end
            problem.requestedLevel = level
            return problem
        end
    end
end
