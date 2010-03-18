require 'jldrill/model/Problem'

module JLDrill
    # Shows you the English and you guess the kanji and reading
    class MeaningProblem < Problem
        def initialize(item, quiz)
            super(item, quiz)
            @level = 1
            @questionParts = ["definitions"]
            @answerParts = ["kanji", "reading", "hint"]
        end

        def largeReading?
            return evaluateAttribute("kanji").empty?
        end
    end
end
