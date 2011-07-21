# encoding: utf-8
require 'jldrill/model/Quiz/Counter'

module JLDrill
    describe Counter do

        it "should create the ranges properly" do
            counter = Counter.new
            
            counter.levelString(0).should eql("Less than 5 days")
            counter.levelString(1).should eql("5 to 10 days")
            counter.levelString(2).should eql("10 to 19 days")
            counter.levelString(3).should eql("19 to 36 days")
            counter.levelString(4).should eql("36 to 65 days")
            counter.levelString(5).should eql("65 to 107 days")
            counter.levelString(6).should eql("107 to 150 days")
            counter.levelString(7).should eql("More than 150 days")
        end

        def testDuration(item, counter, days,level,count)
            d = JLDrill::Duration.new
            d.days = days
            item.schedule.duration = d.seconds
            counter.count(item)
            counter.table[level].should eql(count)
        end

        it "should count properly" do 
            counter = JLDrill::DurationCounter.new
            item = Item.new
            item.schedule.schedule
            testDuration(item, counter, 3, 0, 1)
            testDuration(item, counter, 8, 1, 1)
            testDuration(item, counter, 17, 2, 1)
            testDuration(item, counter, 25, 3, 1)
        end
    end
end
