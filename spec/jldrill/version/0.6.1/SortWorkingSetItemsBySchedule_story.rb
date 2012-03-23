# encoding: utf-8
require 'jldrill/spec/storyFunctionality/SampleQuiz.rb'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::Version_0_6_1
    module SortWorkingSetItemsBySchedule
        # Currently the items in the working set are selected randomly.
        # When each item in the working set has been drilled, it
        # starts again.
        #
        # Instead schedule the items similarly to those in the review set.
        # Only the schedule for the current level is scheduled, though.
        # All items start with a schedule of 10 seconds
    end
end

