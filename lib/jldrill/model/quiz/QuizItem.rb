# encoding: utf-8
require 'jldrill/model/Item'
require 'jldrill/model/quiz/ProblemStatus'
require 'jldrill/model/quiz/ItemStats'

module JLDrill
    class QuizItem < Item
        def initialize(quiz, item)
            super(item)
            @quiz = quiz
        end

        def QuizItem.create(quiz, string)
            item = QuizItem.new(quiz, nil)
            item.parse(string)
            return item
        end

        def clone
            item = QuizItem.new(@quiz, @contents.to_o)
            item.assign(self)
            return item
        end
    end
end

