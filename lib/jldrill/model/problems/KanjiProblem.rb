# encoding: utf-8
require 'jldrill/model/Problem'

module JLDrill
    # Test your kanji reading.  Read the kanji and guess the 
    # reading and definitions
    class KanjiProblem < Problem
        def initialize(item)
            super(item)
            @level = 1
            @questionParts = ["kanji"]
            @answerParts = ["reading", "definitions", "hint"]
        end

        def name
            return "KanjiProblem"
        end

        def clone
            value = KanjiProblem.new(@item)
            value.assign(self)
            return value
        end

        # Returns false if the kanji is empty and we can't drill this
        # item.
        def valid?
            return !(evaluateAttribute("kanji").empty?)
        end
    end    
end
