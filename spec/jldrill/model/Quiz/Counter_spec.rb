require 'jldrill/model/Quiz/Counter'
require 'jldrill/model/Quiz/Statistics'

module JLDrill
    describe Counter do

        it "should be created" do
            quiz = Quiz.new
            stats = Statistics.new(quiz)
            table = stats.initializeTable
            start = 0
            pos = 0
            counter = Counter.new(stats, start, table, pos)
            counter.found.should eql(false)
        end
    end
end
