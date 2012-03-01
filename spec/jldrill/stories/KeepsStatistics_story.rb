# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/quiz/Schedule'
require 'jldrill/model/quiz/Statistics'

module JLDrill::KeepsStatistics
	Story = JLDrill::StoryMemento.new("JLDrill Keeps Statistics Story")

	def Story.setup(type)
		super(type)
		@sample = JLDrill::SampleQuiz.new
		@mainContext.quiz = @sample.resetQuiz
	end

	describe Story.stepName("Measures the amount of time to learn an item") do
		before(:each) do
			Story.setup(JLDrill)
			Story.start
			quiz.options.promoteThresh = 1
			newSet.length.should_not eql(0)
			newSet[0].should_not be_nil
		end

		after(:each) do
			Story.shutdown
		end
    end
end

