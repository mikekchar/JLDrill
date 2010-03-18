require 'jldrill/model/Problem'
require 'jldrill/model/problems/ReadingProblem'
require 'jldrill/model/problems/KanjiProblem'
require 'jldrill/model/problems/MeaningProblem'

module JLDrill
    class ProblemFactory
        def ProblemFactory.create(level, item, quiz)
            case level
                when 0
                    problem = ReadingProblem.new(item, quiz)
                when 1
                    v = item.to_o
                    if !v.kanji.nil?
                        problem = KanjiProblem.new(item, quiz)
                    else
                        problem = MeaningProblem.new(item, quiz)
                    end
                when 2
                    problem = MeaningProblem.new(item, quiz)
                else
                   problem = ReadingProblem.new(item, quiz)
             end
            problem.requestedLevel = level
            return problem
        end
    end
end
