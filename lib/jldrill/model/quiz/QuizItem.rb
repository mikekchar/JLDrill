# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/quiz/QuizItemState'

module JLDrill
    class QuizItem < Item

        def initialize(quiz, item)
            super(item)
            @quiz = quiz
            @state = QuizItemState.new(self, quiz)
        end

        # Create a Quiz item from the save string.  To get around
        # some problems with legacy files (specifically schedules)
        # we need to know what bin this will be going into.
        def QuizItem.create(quiz, string, bin)
            item = QuizItem.new(quiz, nil)
            item.state.moveTo(bin)
            item.parse(string)
            return item
        end

        def clone
            item = QuizItem.create(@quiz, @contents, @bin)
            item.assign(self)
            return item
        end
    end
end

