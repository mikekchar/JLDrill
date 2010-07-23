require 'jldrill/model/Quiz/Counter'

module JLDrill
    describe Counter do

        it "should create the ranges properly" do
            counter = Counter.new
            counter.ranges[0].begin.should eql(0)
            counter.ranges[0].end.should eql(5)
            counter.ranges[1].begin.should eql(5)
            counter.ranges[1].end.should eql(10)
            counter.ranges[2].begin.should eql(10)
            counter.ranges[2].end.should eql(19)
            counter.ranges[3].begin.should eql(19)
            counter.ranges[3].end.should eql(36)
            counter.ranges[4].begin.should eql(36)
            counter.ranges[4].end.should eql(65)
            counter.ranges[5].begin.should eql(65)
            counter.ranges[5].end.should eql(107)
            counter.ranges[6].begin.should eql(107)
            counter.ranges[6].end.should eql(150)
            
            counter.levelString(0).should eql("Less than 5 days")
            counter.levelString(1).should eql("5 to 10 days")
            counter.levelString(2).should eql("10 to 19 days")
            counter.levelString(3).should eql("19 to 36 days")
            counter.levelString(4).should eql("36 to 65 days")
            counter.levelString(5).should eql("65 to 107 days")
            counter.levelString(6).should eql("107 to 150 days")
            counter.levelString(7).should eql("More than 150 days")
        end

        it "should count properly" do 
            counter = JLDrill::DurationCounter.new
            item = Item.new
            item.schedule.schedule
            d = JLDrill::Duration.new
            d.days = 2
            item.schedule.duration = d.seconds
            counter.count(item)
            counter.table[0].should eql(1)
        end
    end
end
