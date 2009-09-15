require 'jldrill/model/Bin'
require 'jldrill/model/Quiz/Schedule'

module JLDrill

	describe ItemStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Score: 0/Level: 0/Consecutive: 0/Difficulty: 0/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Score: 0/Level: 0/Consecutive: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 3/Score: 0/Level: 0/Consecutive: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Score: 0/Level: 0/Consecutive: 1/Difficulty: 7/]
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
		    @items[3].schedule.reviewed?.should be(false)
		    time = @items[3].schedule.markReviewed
		    time.should_not be_nil
		    @items[3].schedule.reviewed?.should be(true)
		end
    
        it "should be able to write the last reviewed time to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule.markReviewed
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Score: 0/Level: 0/LastReviewed: " + time.to_i.to_s + "/Consecutive: 0/Difficulty: 0/\n")
        end
        
        it "should be able to parse the information in the file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule.markReviewed
            newItem = Item.create(@items[1].to_s)
            newItem.schedule.lastReviewed.to_i.should eql(@items[1].schedule.lastReviewed.to_i)
        end
        
        it "should be able to write consecutive to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            @items[1].schedule.consecutive = 2
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Score: 0/Level: 0/Consecutive: 2/Difficulty: 0/\n")
        end

        it "should be able to set the scheduled time" do
		    @items[3].schedule.scheduled?.should be(false)
		    @items[3].schedule.getScheduledTime.to_i.should eql(Time::at(0).to_i)
		    time = @items[3].schedule.schedule
		    time.should_not be_nil
		    @items[3].schedule.scheduled?.should be(true)
        end

        # There's a +- 10% variation in scheduling, so the actual
        # value should be in between those values        
        def should_be_plus_minus_ten_percent(actual, expected)
        variation = expected / 10
        (actual >= (expected - variation)).should be(true)
        (actual <= (expected + variation)).should be(true)
        end

        it "should schedule new items to maximum value by default" do
		    @items[1].schedule.scheduled?.should be(false)
		    time = @items[1].schedule.schedule
		    time.should_not be_nil
		    @items[1].schedule.scheduled?.should be(true)
		    actual = @items[1].schedule.getScheduledTime.to_i
		    expected = Time::now.to_i + days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should schedule old items to twice their elapsed time" do
            # Set reviewed time to 3 days ago
            @items[3].schedule.lastReviewed = Time::now - days(3)
		    @items[3].schedule.scheduled?.should be(false)
		    time = @items[3].schedule.schedule
		    time.should_not be_nil
		    @items[3].schedule.scheduled?.should be(true)
		    # Should be scheduled for 6 days from now
		    actual = @items[3].schedule.getScheduledTime.to_i
		    expected = Time::now.to_i + days(6)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should set a minimum schedule based on difficulty" do
            # Set reviewed time to 1 day ago
            @items[3].schedule.lastReviewed = Time::now - days(1)
		    @items[3].schedule.scheduled?.should be(false)
		    @items[3].schedule.numIncorrect = 0
		    time = @items[3].schedule.schedule
		    time.should_not be_nil
		    @items[3].schedule.scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    actual = @items[3].schedule.getScheduledTime.to_i
		    expected = Time::now.to_i + days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end

        it "should be able to write scheduledTime to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule.schedule
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Score: 0/Level: 0/Consecutive: 0/ScheduledTime: " + time.to_i.to_s + "/Difficulty: 0/\n")
        end

        it "should be able to parse the schedule information in the file" do
            @items[3].to_s.should eql(@strings[3] + "\n")
            time = @items[3].schedule.schedule
            # Note: I have to pass the bin here for legacy reasons.  In the
            # actual application, Items that are created will have a bin
            # because that's where they are stored.  Since we aren't using
            # a bin here, we'll cheat and set the bin number manually.
            newItem = Item.create(@items[3].to_s, 4)
            newItem.schedule.getScheduledTime.to_i.should eql(time.to_i)
        end
        
        it "should be able to clear the schedule" do
		    @items[1].schedule.scheduled?.should be(false)
		    time = @items[1].schedule.schedule
		    time.should_not be_nil
		    @items[1].schedule.scheduled?.should be(true)
		    @items[1].schedule.unschedule
		    @items[1].schedule.scheduled?.should be(false)
        end

        it "should keep track of the number of times incorrect" do
            @items[1].schedule.numIncorrect.should be(0)
            1.upto(10) do
                @items[1].schedule.incorrect
            end
            @items[1].schedule.numIncorrect.should be(10)
        end

        it "should keep a difficulty level equal to the number of times it was incorrect the last time it was in the working set" do
            @items[1].schedule.difficulty.should eql(@items[1].schedule.numIncorrect)
            1.upto(10) do
                @items[1].schedule.incorrect
            end
            @items[1].schedule.difficulty.should eql(@items[1].schedule.numIncorrect)
        end
        
        def days(n)
            return 60 * 60 * 24 * n
        end
        
        it "should choose the longest interval with 0 difficulty" do
            @items[1].schedule.numIncorrect = 0
            @items[1].schedule.difficulty.should be(0)
            @items[1].schedule.intervalFromDifficulty(0).should be(days(5))
        end
        
        it "should decrement the interval by 20 percent from difficulty 1 to 5, down to 1 day" do
            1.upto(5) do |i|
                @items[1].schedule.numIncorrect = i
                @items[1].schedule.difficulty.should be(i)
                int = days(1) + (days(4) * (1.0 - (i.to_f / 5.0))).to_i
                @items[1].schedule.intervalFromDifficulty(i).should be(int)
            end        
        end

        it "should decrement the interval from 1 day approaching 0 days as difficulty increases from 6" do
            last = days(1)
            # Note, if you make the number too big, it will actually hit zero
            # due to rounding errors.  So if you alter the algorithm remember
            # to adjust the maximum number so that it stays just above zero.
            6.upto(50) do |i|
                @items[1].schedule.numIncorrect = i
                @items[1].schedule.difficulty.should be(i)
                (last > @items[1].schedule.intervalFromDifficulty(i)).should be(true)
                last = @items[1].schedule.intervalFromDifficulty(i)
                (last > 0).should be(true)
            end            
        end

        it "should be able to calculate the difficulty based on the interval that has passed." do
            sched = @items[1].schedule
            sched.difficultyFromInterval(10*60*60*24).should be(0)
            0.upto(50) do |i|
                int = sched.intervalFromDifficulty(i)
                sched.difficultyFromInterval(int).should be(i)
            end
        end

        it "should modify the difficulty when the item is correctly answered" do
            sched = @items[1].schedule
            sched.numIncorrect = 10
            sched.schedule
            sched.correct
            sched.difficulty.should be(10)
            1.upto(5) do |i|
                iDaysAgo = i*60*60*24
                # Pretend that we reviewed it i days ago
                sched.lastReviewed = Time::now - iDaysAgo
                sched.correct
                sched.difficulty.should be(sched.difficultyFromInterval(iDaysAgo))
            end
        end
        
        it "should be able to tell if an item is overdue to be reviewed" do
            @items[1].schedule.setScheduledTime(Time::now - Schedule::SECONDS_PER_DAY)
            @items[1].schedule.overdue?.should be(true)
            @items[1].schedule.setScheduledTime(Time::now + Schedule::SECONDS_PER_DAY)
            @items[1].schedule.overdue?.should be(false)            
            @items[1].schedule.setScheduledTime(Time::now)
            @items[1].schedule.overdue?.should be(false)            
        end
        
        it "should be able to tell which day an item is scheduled for" do
            @items[1].schedule.setScheduledTime(Time::now)
            @items[1].schedule.scheduledOn?(0).should be(true)
            @items[1].schedule.scheduledOn?(1).should be(false)
            hoursToMidnight = 24 - @items[1].schedule.getScheduledTime.hour
            @items[1].schedule.setScheduledTime(@items[1].schedule.getScheduledTime + hoursToMidnight * 60 * 60)
            @items[1].schedule.scheduledOn?(0).should be(false)
            @items[1].schedule.scheduledOn?(1).should be(true)
            @items[1].schedule.scheduledOn?(2).should be(false)
            @items[1].schedule.setScheduledTime(@items[1].schedule.getScheduledTime + 24 * 60 * 60)
            @items[1].schedule.scheduledOn?(0).should be(false)
            @items[1].schedule.scheduledOn?(1).should be(false)
            @items[1].schedule.scheduledOn?(2).should be(true)
            @items[1].schedule.scheduledOn?(3).should be(false)
        end
        
        it "should be able to tell if an item is scheduled in a range" do
            @items[1].schedule.schedule(0)
            @items[1].schedule.durationWithin?(0..5).should be(true)
            @items[1].schedule.durationWithin?(1..5).should be(false)

            @items[1].schedule.schedule(1)
            @items[1].schedule.durationWithin?(0..5).should be(true)
            @items[1].schedule.durationWithin?(1..5).should be(false)

            @items[1].schedule.schedule(24 * 60 * 60)
            # Does not include the end point
            @items[1].schedule.durationWithin?(0..1).should be(false)
            @items[1].schedule.durationWithin?(1..2).should be(true)
            @items[1].schedule.schedule(24 * 60 * 60 + 1)
            @items[1].schedule.durationWithin?(0..1).should be(false)
            @items[1].schedule.durationWithin?(0..2).should be(true)            
            @items[1].schedule.durationWithin?(1..2).should be(true)            
        end
        
        it "should be able to show the reviewed date" do
            @items[3].schedule.lastReviewed = Time::now
            @items[3].schedule.reviewedDate.should eql("Today")
            @items[3].schedule.lastReviewed = Time::now - days(1)
            @items[3].schedule.reviewedDate.should eql("Yesterday")
        end
	end

end
