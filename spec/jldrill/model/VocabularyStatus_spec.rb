require 'jldrill/model/Bin'
require 'jldrill/model/VocabularyStatus'

module JLDrill

	describe VocabularyStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 0/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 4/Consecutive: 1/Difficulty: 7/]
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @vocab = []
            0.upto(@strings.length - 1) do |i|
                 @vocab.push(Vocabulary.create(@strings[i]))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@vocab.length - 1) do |i|
                @vocab[i].to_s.should be_eql(@strings[i] + "\n")
            end
		end
		
		it "should be able to set a lastReviewed time on the object" do
		    @vocab[3].status.reviewed?.should be(false)
		    time = @vocab[3].status.markReviewed
		    time.should_not be_nil
		    @vocab[3].status.reviewed?.should be(true)
		end
    
        it "should be able to write the last reviewed time to file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            time = @vocab[1].status.markReviewed
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/LastReviewed: " + time.to_i.to_s + "/Consecutive: 0/Difficulty: 0/\n")
        end
        
        it "should be able to parse the information in the file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            time = @vocab[1].status.markReviewed
            newVocab = Vocabulary.create(@vocab[1].to_s)
            newVocab.status.lastReviewed.to_i.should be_eql(@vocab[1].status.lastReviewed.to_i)
        end
        
        it "should be able to write consecutive to file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            @vocab[1].status.consecutive = 2
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 2/Difficulty: 0/\n")
        end

        it "should be able to set the scheduled time" do
		    @vocab[3].status.scheduled?.should be(false)
		    @vocab[3].status.scheduledTime.to_i.should be_eql(Time::at(0).to_i)
		    time = @vocab[3].status.schedule
		    time.should_not be_nil
		    @vocab[3].status.scheduled?.should be(true)
        end

        it "should schedule new items to maximum value by default" do
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::now.to_i + days(5))
        end
        
        it "should schedule old items to twice their elapsed time" do
            # Set reviewed time to 3 days ago
            @vocab[3].status.lastReviewed = Time::now - days(3)
		    @vocab[3].status.scheduled?.should be(false)
		    time = @vocab[3].status.schedule
		    time.should_not be_nil
		    @vocab[3].status.scheduled?.should be(true)
		    # Should be scheduled for 6 days from now
		    @vocab[3].status.scheduledTime.to_i.should be_eql(Time::now.to_i + days(6))            
        end
        
        it "should set a minimum schedule equal to firstInterval" do
            # Set reviewed time to 1 day ago
            @vocab[3].status.lastReviewed = Time::now - days(1)
		    @vocab[3].status.scheduled?.should be(false)
		    @vocab[3].status.numIncorrect = 0
		    time = @vocab[3].status.schedule
		    time.should_not be_nil
		    @vocab[3].status.scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    @vocab[3].status.scheduledTime.to_i.should be_eql(Time::now.to_i + days(5))            
        end

        it "should be able to write scheduledTime to file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            time = @vocab[1].status.schedule
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/ScheduledTime: " + time.to_i.to_s + "/Difficulty: 0/\n")
        end

        it "should be able to parse the schedule information in the file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            time = @vocab[1].status.schedule
            newVocab = Vocabulary.create(@vocab[1].to_s)
            newVocab.status.scheduledTime.to_i.should be_eql(time.to_i)
        end
        
        it "should be able to clear the schedule" do
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    @vocab[1].status.unschedule
		    @vocab[1].status.scheduled?.should be(false)
        end

        it "should keep track of the number of times incorrect" do
            @vocab[1].status.numIncorrect.should be(0)
            1.upto(10) do
                @vocab[1].status.incorrect
            end
            @vocab[1].status.numIncorrect.should be(10)
        end

        it "should keep a difficulty level equal to the number of times it was incorrect the last time it was in the working set" do
            @vocab[1].status.difficulty.should be_eql(@vocab[1].status.numIncorrect)
            1.upto(10) do
                @vocab[1].status.incorrect
            end
            @vocab[1].status.difficulty.should be_eql(@vocab[1].status.numIncorrect)
        end
        
        def days(n)
            return 60 * 60 * 24 * n
        end
        
        it "should choose the longest first interval with 0 difficulty" do
            @vocab[1].status.numIncorrect = 0
            @vocab[1].status.difficulty.should be(0)
            @vocab[1].status.firstInterval.should be(days(5))
        end
        
        it "should decrement first interval by 20 percent from difficulty 1 to 5, down to 1 day" do
            1.upto(5) do |i|
                @vocab[1].status.numIncorrect = i
                @vocab[1].status.difficulty.should be(i)
                int = days(1) + (days(4) * (1.0 - (i.to_f / 5.0))).to_i
                @vocab[1].status.firstInterval.should be(int)
            end
        
        end

        it "should decrement first interval from 1 day approaching 0 days as difficulty increases from 6" do
            last = days(1)
            # Note, if you make the number too big, it will actually hit zero
            # due to rounding errors.  So if you alter the algorithm remember
            # to adjust the maximum number so that it stays just above zero.
            6.upto(50) do |i|
                @vocab[1].status.numIncorrect = i
                @vocab[1].status.difficulty.should be(i)
                (last > @vocab[1].status.firstInterval).should be(true)
                last = @vocab[1].status.firstInterval
                (last > 0).should be(true)
            end            
        end
        
        it "should be able to tell if an item is overdue to be reviewed" do
            @vocab[1].status.scheduledTime = Time::now - VocabularyStatus::SECONDS_PER_DAY
            @vocab[1].status.overdue?.should be(true)
            @vocab[1].status.scheduledTime = Time::now + VocabularyStatus::SECONDS_PER_DAY
            @vocab[1].status.overdue?.should be(false)            
            @vocab[1].status.scheduledTime = Time::now
            @vocab[1].status.overdue?.should be(false)            
        end
        
        it "should be able to tell which day an item is scheduled for" do
            @vocab[1].status.scheduledTime = Time::now
            @vocab[1].status.scheduledOn?(0).should be(true)
            @vocab[1].status.scheduledOn?(1).should be(false)
            hoursToMidnight = 24 - @vocab[1].status.scheduledTime.hour
            @vocab[1].status.scheduledTime += hoursToMidnight * 60 * 60
            @vocab[1].status.scheduledOn?(0).should be(false)
            @vocab[1].status.scheduledOn?(1).should be(true)
            @vocab[1].status.scheduledOn?(2).should be(false)
            @vocab[1].status.scheduledTime += 24 * 60 * 60
            @vocab[1].status.scheduledOn?(0).should be(false)
            @vocab[1].status.scheduledOn?(1).should be(false)
            @vocab[1].status.scheduledOn?(2).should be(true)
            @vocab[1].status.scheduledOn?(3).should be(false)
        end
        
        it "should be able to tell if an item is scheduled in a range" do
            @vocab[1].status.scheduleDuration = 0
            @vocab[1].status.durationWithin?(0..5).should be(true)
            @vocab[1].status.durationWithin?(1..5).should be(false)

            @vocab[1].status.scheduleDuration = 1
            @vocab[1].status.durationWithin?(0..5).should be(true)
            @vocab[1].status.durationWithin?(1..5).should be(false)

            @vocab[1].status.scheduleDuration = 24 * 60 * 60
            # Does not include the end point
            @vocab[1].status.durationWithin?(0..1).should be(false)
            @vocab[1].status.durationWithin?(1..2).should be(true)
            @vocab[1].status.scheduleDuration += 1
            @vocab[1].status.durationWithin?(0..1).should be(false)
            @vocab[1].status.durationWithin?(0..2).should be(true)            
            @vocab[1].status.durationWithin?(1..2).should be(true)            
        end
        
        it "should be able to show the reviewed date" do
            @vocab[3].status.lastReviewed = Time::now
            @vocab[3].status.reviewedDate.should be_eql("Today")
            @vocab[3].status.lastReviewed = Time::now - days(1)
            @vocab[3].status.reviewedDate.should be_eql("Yesterday")
        end
	end

end
