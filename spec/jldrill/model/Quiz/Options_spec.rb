require 'jldrill/model/Quiz/Options'

module JLDrill

	describe Options do
	
	    before(:each) do
	        @quiz = mock("Quiz")
	        @options = Options.new(@quiz)
	    end
	    
	    def test_changeOption(optionString, originalValue, newValue)
		    eval("@options.#{optionString}").should be(originalValue)
	        @quiz.should_receive(:setNeedsSave).with(true)
		    eval("@options.#{optionString} = #{newValue}")
		    eval("@options.#{optionString}").should be(newValue)
		end
		
		def test_parseOption(parseString, optionString, originalValue, newValue)
		    eval("@options.#{optionString}").should be(originalValue)
	        @quiz.should_receive(:setNeedsSave).with(true)
		    eval("@options.parseLine(\"#{parseString}\")")
		    eval("@options.#{optionString}").should be(newValue)
		end

	    it "should be able to set Random Order" do
	        test_changeOption("randomOrder", false, true)
	    end

	    it "should be able to parse Random Order" do
	        test_parseOption("Random Order", "randomOrder", false, true)
	    end

	    it "should be able to set Promote Threshold" do
	        test_changeOption("promoteThresh", 2, 1)
	    end

	    it "should be able to parse Promote Threshold" do
	        test_parseOption("Promotion Threshold: 5", "promoteThresh", 2, 5)
	    end

	    it "should be able to set Intro Threshold" do
	        test_changeOption("introThresh", 10, 20)
	    end

	    it "should be able to parse Intro Threshold" do
	        test_parseOption("Introduction Threshold: 20", "introThresh", 10, 20)
	    end

	    it "should be able to set Old Threshold" do
	        test_changeOption("oldThresh", 90, 85)
	    end
	    
	    it "should be able to set the Strategy Version" do
	        test_changeOption("strategyVersion", 0, 1)
	    end
	    
	    it "should be able to parse Strategy Version" do
	        test_parseOption("Strategy Version: 1", "strategyVersion", 0, 1)
	    end

	    it "should be able to write out the options" do
	        @quiz.should_receive(:setNeedsSave).with(true).exactly(4).times
	        @options.randomOrder = true
	        @options.promoteThresh = 1
	        @options.introThresh = 20
	        @options.strategyVersion = 1
            @options.to_s.should be_eql("Random Order\nPromotion Threshold: 1\nIntroduction Threshold: 20\nStrategy Version: 1\n")
            @options.status.should be_eql("1R(1,20)")
	    end
	    
	    it "should be able to assign the options to another options object" do
	        @quiz.should_receive(:setNeedsSave).with(true).exactly(4).times
	        @options.randomOrder = true
	        @options.promoteThresh = 1
	        @options.introThresh = 20
	        @options.strategyVersion = 1
            @options.to_s.should be_eql("Random Order\nPromotion Threshold: 1\nIntroduction Threshold: 20\nStrategy Version: 1\n")
            newOptions = Options.new(nil)
            newOptions.to_s.should_not be_eql("Random Order\nPromotion Threshold: 1\nIntroduction Threshold: 20\nStrategy Version: 1\n")            
            newOptions.assign(@options)
            newOptions.to_s.should be_eql("Random Order\nPromotion Threshold: 1\nIntroduction Threshold: 20\nStrategy Version: 1\n")            
        end	    
	
    end
    
end
