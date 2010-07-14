require 'jldrill/model/Duration'

module JLDrill

    describe Duration do

        it "should create an invalid duration with no argument" do
            duration = Duration.new
            duration.seconds.should eql(-1)
            duration.valid?.should be_false
        end

        it "should create a duration of the required length" do
            duration = Duration.new(52)
            duration.seconds.should eql(52)
            duration.valid?.should be_true
        end

        it "should parse a duration from a string" do
            duration = Duration.parse("126")
            duration.seconds.should eql(126)
            duration = Duration.parse("abcd")
            duration.valid?.should be_false
            duration = Duration.parse("0")
            duration.seconds.should eql(0)
            duration.valid?.should be_true
        end

        it "should output the duration in days" do
            fiveDays = Duration.new
            fiveDays.days = 5.0
            fiveDays.seconds.should eql(432000)
            fiveDays.days.should eql(5.0)
        end

        it "should output the duration as a string" do
            duration = Duration.new(256)
            duration.to_s.should eql("256")
        end

        it "should assign durations properly" do
            duration = Duration.new(1234)
            duration2 = Duration.new
            duration2.assign(duration)
            duration2.seconds.should eql(duration.seconds)
        end
    end
end
