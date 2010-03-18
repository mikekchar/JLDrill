require 'jldrill/model/Problem'

module JLDrill
    # Test your kanji reading.  Read the kanji and guess the 
    # reading and definitions
    class KanjiProblem < Problem
        def initialize(item, quiz)
            super(item, quiz)
            @level = 2
            @questionParts = ["kanji"]
            @answerParts = ["reading", "definitions", "hint"]
        end

        # Returns false if the kanji is empty and we can't drill this
        # item.
        def valid?
            return !(evaluateAttribute("kanji").empty?)
        end
    end    
end
