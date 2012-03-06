# encoding: utf-8
require 'jldrill/model/Bin'
require 'jldrill/model/Item'
require 'jldrill/model/ItemStatus'
require 'jldrill/model/quiz/Schedule'

module JLDrill

	describe ItemStatus do
	
		before(:each) do
        	@fileString = %Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 3/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Potential: 432000/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 4/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/Potential: 111076/]
            @quiz = Quiz.new
            @strings = @fileString.split("\n")
            @strings.length.should be(4)
            @items = []
            0.upto(@strings.length - 1) do |i|
                 @items.push(QuizItem.create(@quiz, @strings[i]))
            end
		end
		
		it "should be able to parse vocabulary from strings" do
            0.upto(@items.length - 1) do |i|
                @items[i].to_s.should eql(@strings[i] + "\n")
            end
		end
		
		it "should be able to set a lastReviewed time on the object" do
		    @items[3].schedule(2).reviewed?.should be(false)
		    time = @items[3].schedule(2).markReviewed
		    time.should_not be_nil
		    @items[3].schedule(2).reviewed?.should be(true)
		end
    
        it "should be able to write the last reviewed time to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule(2).markReviewed
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/LastReviewed: " + time.to_i.to_s + "/Potential: 432000/\n")
        end
        
        it "should be able to parse the information in the file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule(2).markReviewed
            newItem = QuizItem.create(@quiz, @items[1].to_s)
            newItem.schedule(2).lastReviewed.to_i.should eql(@items[1].schedule(2).lastReviewed.to_i)
        end
        
        it "should be able to write consecutive to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            @items[1].itemStats.consecutive = 2
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 2/MeaningProblem/Score: 0/Level: 0/Potential: 432000/\n")
        end

        # There's a +- 10% variation in scheduling, so the actual
        # value should be in between those values        
        def should_be_plus_minus_ten_percent(actual, expected)
            variation = expected.to_f / 10.0
            (actual >= (expected.to_f - variation.to_f).to_i).should be(true)
            (actual <= (expected.to_f + variation.to_f).to_i).should be(true)
        end

        it "should schedule new items to maximum value by default" do
		    @items[1].schedule(2).scheduled?.should be(false)
		    time = @items[1].schedule(2).schedule
		    time.should_not be_nil
		    @items[1].schedule(2).scheduled?.should be(true)
		    actual = @items[1].schedule(2).duration
		    expected = days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should schedule old items to based on their elapsed time" do
            # Set reviewed time to 3 days ago
            @items[3].schedule(2).lastReviewed = Time::now - (days(3) - 1)
            @items[3].schedule(2).duration = days(3)
		    @items[3].schedule(2).scheduled?.should be(true)
		    time = @items[3].schedule(2).schedule
		    time.should_not be_nil
		    @items[3].schedule(2).scheduled?.should be(true)
		    # Should be scheduled based on actual duration
		    actual = @items[3].schedule(2).duration
		    expected = Schedule.backoff(days(3))
		    should_be_plus_minus_ten_percent(actual, expected)
        end
        
        it "should set a minimum schedule based on difficulty" do
            # Set reviewed time to 1 day ago
            @items[3].schedule(2).lastReviewed = Time::now - days(1)
		    @items[3].schedule(2).scheduled?.should be(false)
		    @items[3].schedule(2).potential = Schedule.defaultPotential
		    time = @items[3].schedule(2).schedule
		    time.should_not be_nil
		    @items[3].schedule(2).scheduled?.should be(true)
		    # Instead of 2 days it will be 5 because that is the minumum for
		    # an item that has no incorrect.
		    actual = @items[3].schedule(2).duration
		    expected = days(5)
		    should_be_plus_minus_ten_percent(actual, expected)
        end

        it "should be able to write duration to file" do
            @items[1].to_s.should eql(@strings[1] + "\n")
            time = @items[1].schedule(2).schedule
            duration = @items[1].schedule(2).duration
            @items[1].to_s.should eql("/Kanji: 青い/Hint: Obvious/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Duration: " + duration.to_s + "/Potential: 432000/\n")
        end

        it "should be able to parse the schedule information in the file" do
            @items[3].to_s.should eql(@strings[3] + "\n")
            time = @items[3].schedule(2).schedule
            newItem = QuizItem.create(@quiz, @items[3].to_s)
            # Since we aren't using
            # a bin here, we'll cheat and set the bin number manually.
            newItem.bin = 4
            newItem.schedule(2).duration.should eql(time.to_i)
        end
        
        it "should be able to clear the schedule" do
		    @items[1].schedule(2).scheduled?.should be(false)
		    time = @items[1].schedule(2).schedule
		    time.should_not be_nil
		    @items[1].schedule(2).scheduled?.should be(true)
		    @items[1].schedule(2).unschedule
		    @items[1].schedule(2).scheduled?.should be(false)
        end

        def days(n)
            return 60 * 60 * 24 * n
        end
        
        it "should be able to tell if an item has duration in a range" do
            @items[1].schedule(2).schedule(0)
            @items[1].schedule(2).durationWithin?(0...5).should be(true)
            @items[1].schedule(2).durationWithin?(1...5).should be(false)

            @items[1].schedule(2).schedule(1)
            @items[1].schedule(2).durationWithin?(0...5).should be(true)
            @items[1].schedule(2).durationWithin?(0...1).should be(false)
        end
        
        it "should be able to show the reviewed date" do
            @items[3].schedule(2).lastReviewed = Time::now
            @items[3].schedule(2).reviewedDate.should eql("Today")
            @items[3].schedule(2).lastReviewed = Time::now - days(1)
            @items[3].schedule(2).reviewedDate.should eql("Yesterday")
        end
	end

end
