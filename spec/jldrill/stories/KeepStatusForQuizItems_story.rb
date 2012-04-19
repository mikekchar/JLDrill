# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/Item'
require 'jldrill/model/Quiz'
require 'jldrill/model/quiz/Schedule'

module JLDrill

	describe "Scheduling Plans" do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Potential: 432000/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Potential: 432000/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 3/Consecutive: 0/MeaningProblem/Score: 0/Potential: 432000/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/MeaningProblem/Score: 0/Potential: 432000/]
            @quiz = Quiz.new
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @items = []
            0.upto(@strings.length - 1) do |i|
                 @items.push(QuizItem.create(@quiz, @strings[i], @quiz.contents.reviewSetBin))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@items.length - 1) do |i|
                @items[i].to_s.should eql(@strings[i] + "\n")
            end
		end
		
		it "should be able to set a lastReviewed time on the object" do
		    @items[3].state.currentSchedule.reviewed?.should be(false)
		    time = @items[3].state.currentSchedule.markReviewed
		    time.should_not be_nil
		    @items[3].state.currentSchedule.reviewed?.should be(true)
		end
    
        it "should be able to write the last reviewed time to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].state.currentSchedule.markReviewed
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/LastReviewed: " + time.to_i.to_s + "/Potential: 432000/\n")
        end
        
        it "should be able to parse the information in the file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].state.currentSchedule.markReviewed
            newItem = QuizItem.create(@quiz, @items[1].to_s, @quiz.contents.reviewSetBin)
            newItem.state.currentSchedule.lastReviewed.to_i.should eql(@items[1].state.currentSchedule.lastReviewed.to_i)
        end
        
        it "should be able to write consecutive to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            @items[1].state.itemStats.consecutive = 2
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 2/MeaningProblem/Score: 0/Potential: 432000/\n")
        end

        # There's a +- 10% variation in scheduling, so the actual
        # value should be in between those values        
        def should_be_plus_minus_ten_percent(actual, expected)
            variation = expected.to_f / 10.0
            (actual >= (expected.to_f - variation.to_f).to_i).should be(true)
            (actual <= (expected.to_f + variation.to_f).to_i).should be(true)
        end

        it "should schedule new items to maximum value by default" do
		    @items[1].state.currentSchedule.scheduled?.should be(false)
		    time = @items[1].state.currentSchedule.schedule
		    time.should_not be_nil
		    @items[1].state.currentSchedule.scheduled?.should be(true)
		    actual = @items[1].state.currentSchedule.duration
		    expected = days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should schedule old items to based on their elapsed time" do
            # Set reviewed time to 3 days ago
            @items[3].state.currentSchedule.lastReviewed = Time::now - (days(3) - 1)
            @items[3].state.currentSchedule.duration = days(3)
		    @items[3].state.currentSchedule.scheduled?.should be(true)
		    time = @items[3].state.currentSchedule.schedule
		    time.should_not be_nil
		    @items[3].state.currentSchedule.scheduled?.should be(true)
		    # Should be scheduled based on actual duration
		    actual = @items[3].state.currentSchedule.duration
		    expected = Schedule.backoff(days(3))
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should set a minimum schedule based on difficulty" do
            # Set reviewed time to 1 day ago
            @items[3].state.currentSchedule.lastReviewed = Time::now - days(1)
		    @items[3].state.currentSchedule.scheduled?.should be(false)
		    @items[3].state.currentSchedule.potential = Schedule.defaultPotential
		    time = @items[3].state.currentSchedule.schedule
		    time.should_not be_nil
		    @items[3].state.currentSchedule.scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    actual = @items[3].state.currentSchedule.duration
		    expected = days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end

        it "should be able to write duration to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].state.currentSchedule.schedule
            duration = @items[1].state.currentSchedule.duration
            # Note potential should be the same as duration for scheduled
            # items
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Duration: " + duration.to_s + "/Potential: " + duration.to_s + "/\n")
        end

        it "should be able to parse the schedule information in the file" do
            @items[3].to_s.should eql(@strings[3] + "\n")
            time = @items[3].state.currentSchedule.schedule
            newItem = QuizItem.create(@quiz, @items[3].to_s, @quiz.contents.reviewSetBin)
            # Since we aren't using
            # a bin here, we'll cheat and set the bin number manually.
            newItem.state.moveTo(4)
            newItem.state.currentSchedule.duration.should eql(time.to_i)
        end
        
        it "should be able to clear the schedule" do
		    @items[1].state.currentSchedule.scheduled?.should be(false)
		    time = @items[1].state.currentSchedule.schedule
		    time.should_not be_nil
		    @items[1].state.currentSchedule.scheduled?.should be(true)
		    @items[1].state.currentSchedule.unschedule
		    @items[1].state.currentSchedule.scheduled?.should be(false)
        end

        def days(n)
            return 60 * 60 * 24 * n
        end
        
        it "should be able to show the reviewed date" do
            @items[3].state.currentSchedule.lastReviewed = Time::now
            @items[3].state.currentSchedule.reviewedDate.should eql("Today")
            @items[3].state.currentSchedule.lastReviewed = Time::now - days(1)
            @items[3].state.currentSchedule.reviewedDate.should eql("Yesterday")
        end
	end

end
