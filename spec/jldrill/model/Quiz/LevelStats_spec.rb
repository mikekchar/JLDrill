# encoding: utf-8
require 'jldrill/model/Quiz/LevelStats'

module JLDrill
    describe LevelStats do
        
        it "should count the total number of trials" do
            s = LevelStats.new
            s.total.should eql(0)
            s.correct
            s.total.should eql(1)
            s.incorrect
            s.total.should eql(2)
            1.upto(10) do
                s.correct
                s.incorrect
            end
            s.total.should eql(22)
        end

        it "should keep track of the percentage correct" do
            s = LevelStats.new
            # Returns nil when initialized to distinguish from 0 with trials.
            s.accuracy.should be_nil 
            s.correct
            s.accuracy.should eql(100)
            s.incorrect
            s.accuracy.should eql(50)
            s.incorrect
            s.accuracy.should eql(33)
            s.correct
            s.correct
            s.correct
            # It's truncated not rounded
            s.accuracy.should eql(66)
        end
    end
end

