# encoding: utf-8
require 'jldrill/model/Problem'

module JLDrill
    # The first kind of Problem shown.  It lets you read it in Japanese and
    # guess the English
    class ReadingProblem < Problem
        def initialize(item, schedule)
            super(item, schedule)
            @level = 0
            @questionParts = ["kanji", "reading", "hint"]
            @answerParts = ["definitions"]
        end

        def name
            return "ReadingProblem"
        end

        def clone
            value = ReadingProblem.new(@item, @schedule)
            value.assign(self)
            return value
        end

        def largeReading?
            return evaluateAttribute("kanji").empty?
        end
    end 
end
