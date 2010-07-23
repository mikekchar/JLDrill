require 'jldrill/model/Quiz/Counter'
require 'jldrill/model/Quiz/Statistics'

module JLDrill
    describe Counter do

        it "should be created" do
            quiz = Quiz.new
            stats = Statistics.new(quiz)
            counter = Counter.new(stats)
            counter.found.should eql(false)
        end
    end
end
