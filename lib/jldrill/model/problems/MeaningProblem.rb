# encoding: utf-8
require 'jldrill/model/Problem'

module JLDrill
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(item, schedule)
            super(item, schedule)
            @level = 1
            @questionParts = ["definitions"]
            @answerParts = ["kanji", "reading", "hint"]
        end

        def name
            return "MeaningProblem"
        end

        def clone
            value = MeaningProblem.new(@item, @strategy)
            value.assign(self)
            return value
        end

        def largeReading?
            return evaluateAttribute("kanji").empty?
        end
    end
end
