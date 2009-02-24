require 'jldrill/model/Bin'
require 'jldrill/model/items/ItemStatus'

module JLDrill

	describe ItemStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 0/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 4/Consecutive: 1/Difficulty: 7/]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @items = []
            0.upto(@strings.length - 1) do |i|
                 @items.push(Item.create(@strings[i]))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@items.length - 1) do |i|
                @items[i].to_s.should eql(@strings[i] + "\n")
            end
		end
		
		it "should be able to set a lastReviewed time on the object" do
		    @items[3].status.reviewed?.should be(false)
		    time = @items[3].status.markReviewed
		    time.should_not be_nil
		    @items[3].status.reviewed?.should be(true)
		end
    
        it "should be able to write the last reviewed time to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].status.markReviewed
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/LastReviewed: " + time.to_i.to_s + "/Consecutive: 0/Difficulty: 0/\n")
        end
        
        it "should be able to parse the information in the file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].status.markReviewed
            newItem = Item.create(@items[1].to_s)
            newItem.status.lastReviewed.to_i.should eql(@items[1].status.lastReviewed.to_i)
        end
        
        it "should be able to write consecutive to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            @items[1].status.consecutive = 2
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 2/Difficulty: 0/\n")
        end

        it "should be able to set the scheduled time" do
		    @items[3].status.scheduled?.should be(false)
		    @items[3].status.getScheduledTime.to_i.should eql(Time::at(0).to_i)
		    time = @items[3].status.schedule
		    time.should_not be_nil
		    @items[3].status.scheduled?.should be(true)
        end

        # There's a +- 10% variation in scheduling, so the actual
        # value should be in between those values        
        def should_be_plus_minus_ten_percent(actual, expected)
        variation = expected / 10
        (actual >= (expected - variation)).should be(true)
        (actual <= (expected + variation)).should be(true)
        end

        it "should schedule new items to maximum value by default" do
		    @items[1].status.scheduled?.should be(false)
		    time = @items[1].status.schedule
		    time.should_not be_nil
		    @items[1].status.scheduled?.should be(true)
		    actual = @items[1].status.getScheduledTime.to_i
		    expected = Time::now.to_i + days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should schedule old items to twice their elapsed time" do
            # Set reviewed time to 3 days ago
            @items[3].status.lastReviewed = Time::now - days(3)
		    @items[3].status.scheduled?.should be(false)
		    time = @items[3].status.schedule
		    time.should_not be_nil
		    @items[3].status.scheduled?.should be(true)
		    # Should be scheduled for 6 days from now
		    actual = @items[3].status.getScheduledTime.to_i
		    expected = Time::now.to_i + days(6)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should set a minimum schedule equal to firstInterval" do
            # Set reviewed time to 1 day ago
            @items[3].status.lastReviewed = Time::now - days(1)
		    @items[3].status.scheduled?.should be(false)
		    @items[3].status.numIncorrect = 0
		    time = @items[3].status.schedule
		    time.should_not be_nil
		    @items[3].status.scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    actual = @items[3].status.getScheduledTime.to_i
		    expected = Time::now.to_i + days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end

        it "should be able to write scheduledTime to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].status.schedule
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/ScheduledTime: " + time.to_i.to_s + "/Difficulty: 0/\n")
        end

        it "should be able to parse the schedule information in the file" do
            @items[3].to_s.should eql(@strings[3] + "\n")
            time = @items[3].status.schedule
            newItem = Item.create(@items[3].to_s)
            newItem.status.getScheduledTime.to_i.should eql(time.to_i)
        end
        
        it "should be able to clear the schedule" do
		    @items[1].status.scheduled?.should be(false)
		    time = @items[1].status.schedule
		    time.should_not be_nil
		    @items[1].status.scheduled?.should be(true)
		    @items[1].status.unschedule
		    @items[1].status.scheduled?.should be(false)
        end

        it "should keep track of the number of times incorrect" do
            @items[1].status.numIncorrect.should be(0)
            1.upto(10) do
                @items[1].status.incorrect
            end
            @items[1].status.numIncorrect.should be(10)
        end

        it "should keep a difficulty level equal to the number of times it was incorrect the last time it was in the working set" do
            @items[1].status.difficulty.should eql(@items[1].status.numIncorrect)
            1.upto(10) do
                @items[1].status.incorrect
            end
            @items[1].status.difficulty.should eql(@items[1].status.numIncorrect)
        end
        
        def days(n)
            return 60 * 60 * 24 * n
        end
        
        it "should choose the longest first interval with 0 difficulty" do
            @items[1].status.numIncorrect = 0
            @items[1].status.difficulty.should be(0)
            @items[1].status.firstInterval.should be(days(5))
        end
        
        it "should decrement first interval by 20 percent from difficulty 1 to 5, down to 1 day" do
            1.upto(5) do |i|
                @items[1].status.numIncorrect = i
                @items[1].status.difficulty.should be(i)
                int = days(1) + (days(4) * (1.0 - (i.to_f / 5.0))).to_i
                @items[1].status.firstInterval.should be(int)
            end
        
        end

        it "should decrement first interval from 1 day approaching 0 days as difficulty increases from 6" do
            last = days(1)
            # Note, if you make the number too big, it will actually hit zero
            # due to rounding errors.  So if you alter the algorithm remember
            # to adjust the maximum number so that it stays just above zero.
            6.upto(50) do |i|
                @items[1].status.numIncorrect = i
                @items[1].status.difficulty.should be(i)
                (last > @items[1].status.firstInterval).should be(true)
                last = @items[1].status.firstInterval
                (last > 0).should be(true)
            end            
        end
        
        it "should be able to tell if an item is overdue to be reviewed" do
            @items[1].status.setScheduledTime(Time::now - ItemStatus::SECONDS_PER_DAY)
            @items[1].status.overdue?.should be(true)
            @items[1].status.setScheduledTime(Time::now + ItemStatus::SECONDS_PER_DAY)
            @items[1].status.overdue?.should be(false)            
            @items[1].status.setScheduledTime(Time::now)
            @items[1].status.overdue?.should be(false)            
        end
        
        it "should be able to tell which day an item is scheduled for" do
            @items[1].status.setScheduledTime(Time::now)
            @items[1].status.scheduledOn?(0).should be(true)
            @items[1].status.scheduledOn?(1).should be(false)
            hoursToMidnight = 24 - @items[1].status.getScheduledTime.hour
            @items[1].status.setScheduledTime(@items[1].status.getScheduledTime + hoursToMidnight * 60 * 60)
            @items[1].status.scheduledOn?(0).should be(false)
            @items[1].status.scheduledOn?(1).should be(true)
            @items[1].status.scheduledOn?(2).should be(false)
            @items[1].status.setScheduledTime(@items[1].status.getScheduledTime + 24 * 60 * 60)
            @items[1].status.scheduledOn?(0).should be(false)
            @items[1].status.scheduledOn?(1).should be(false)
            @items[1].status.scheduledOn?(2).should be(true)
            @items[1].status.scheduledOn?(3).should be(false)
        end
        
        it "should be able to tell if an item is scheduled in a range" do
            @items[1].status.scheduleDuration = 0
            @items[1].status.durationWithin?(0..5).should be(true)
            @items[1].status.durationWithin?(1..5).should be(false)

            @items[1].status.scheduleDuration = 1
            @items[1].status.durationWithin?(0..5).should be(true)
            @items[1].status.durationWithin?(1..5).should be(false)

            @items[1].status.scheduleDuration = 24 * 60 * 60
            # Does not include the end point
            @items[1].status.durationWithin?(0..1).should be(false)
            @items[1].status.durationWithin?(1..2).should be(true)
            @items[1].status.scheduleDuration += 1
            @items[1].status.durationWithin?(0..1).should be(false)
            @items[1].status.durationWithin?(0..2).should be(true)            
            @items[1].status.durationWithin?(1..2).should be(true)            
        end
        
        it "should be able to show the reviewed date" do
            @items[3].status.lastReviewed = Time::now
            @items[3].status.reviewedDate.should eql("Today")
            @items[3].status.lastReviewed = Time::now - days(1)
            @items[3].status.reviewedDate.should eql("Yesterday")
        end
	end

end
