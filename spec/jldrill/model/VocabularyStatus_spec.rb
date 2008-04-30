require 'jldrill/model/Bin'
require 'jldrill/model/VocabularyStatus'

module JLDrill

	describe VocabularyStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 4/Consecutive: 0/]
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
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/LastReviewed: " + time.to_i.to_s + "/Consecutive: 0/\n")
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
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 2/\n")
        end

        it "should be able to set the scheduled time" do
		    @vocab[1].status.scheduled?.should be(false)
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::at(0).to_i)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
        end

        it "should schedule new items to 1 day" do
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::now.to_i + (60*60*24))
        end
        
        it "should schedule old items to twice their elapsed time" do
            # Set reviewed time to yesterday
            @vocab[1].status.lastReviewed = Time::now - (60*60*24)
		    @vocab[1].status.scheduled?.should be(false)
		    time = @vocab[1].status.schedule
		    time.should_not be_nil
		    @vocab[1].status.scheduled?.should be(true)
		    # Should be scheduled for 2 days from now
		    @vocab[1].status.scheduledTime.to_i.should be_eql(Time::now.to_i + (2*60*60*24))            
        end

        it "should be able to write scheduledTime to file" do
            @vocab[1].to_s.should be_eql(@strings[1] + "\n")
            time = @vocab[1].status.schedule
            @vocab[1].to_s.should be_eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/ScheduledTime: " + time.to_i.to_s + "/\n")
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

	end

end
