require 'jldrill/model/Bin'
require 'jldrill/model/VocabularyStatus'

module JLDrill

	describe VocabularyStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 0/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 0/Difficulty: 7/]
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
		    @vocab[1].status.reviewed?.should be(false)
		    time = @vocab[1].status.markReviewed
		    time.should_not be_nil
		    @vocab[1].status.reviewed?.should be(true)
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
		    @vocab[1].status.scheduled?.should be(false)
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::at(0).to_i)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
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
            @vocab[1].status.lastReviewed = Time::now - days(3)
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    # Should be scheduled for 6 days from now
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::now.to_i + days(6))            
        end
        
        it "should set a minimum schedule equal to firstInterval" do
            # Set reviewed time to 1 day ago
            @vocab[1].status.lastReviewed = Time::now - days(1)
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::now.to_i + days(5))            
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
        
        it "should decrement first interval by 10 percent from difficulty 1 to 10, down to 1 day" do
            1.upto(10) do |i|
                @vocab[1].status.numIncorrect = i
                @vocab[1].status.difficulty.should be(i)
                int = days(1) + (days(4) * (1.0 - (i.to_f / 10.0))).to_i
                @vocab[1].status.firstInterval.should be(int)
            end
        
        end

        it "should decrement first interval from 1 day approaching 0 days as difficulty increases from 10" do
            last = days(1)
            11.upto(100) do |i|
                @vocab[1].status.numIncorrect = i
                @vocab[1].status.difficulty.should be(i)
                (last > @vocab[1].status.firstInterval).should be(true)
                last = @vocab[1].status.firstInterval
                (last > 0).should be(true)
            end            
        end
        
	end

end
