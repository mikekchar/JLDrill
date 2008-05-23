require 'jldrill/model/Edict/GrammarType'

module JLDrill

	describe GrammarType do
	
	    it "should have a list of grammar markings" do
	        GrammarType.types.should_not be_nil
	        GrammarType.types.keys.size.should be(106)
	    end
	    
	    it "should be able to look up the types" do
	        GrammarType.exists?("fun").should be(false)
	        GrammarType.types.keys.each do |tag|
	            GrammarType.exists?(tag).should be(true)
	        end
	    end
	    
	    it "should be able to look up the special language tags" do
	        GrammarType.exists?("fr:").should be(true)
	    end
	    
	    it "should be able to parse a string of types" do
	        string = "(n)"
	        types = GrammarType.create(string)
	        types.size.should be(1)
	        types[0].should be_eql("n")

	        string = "(n,P)"
	        types = GrammarType.create(string)
	        types.size.should be(2)
	        types[0].should be_eql("n")
	        types[1].should be_eql("P")
	    end
	    
	    it "should be able to reject non-types" do
	        string = "(usually)"
	        types = GrammarType.create(string)
	        types.size.should be(0)
	    end

#       For profiling.  Want to make sure 100000 can be done in less than 3 sec	    
#	    it "should be fast" do
#	        startTime = Time::now
#	        0.upto(1000) do
#    	        GrammarType.types.keys.each do |tag|
#    	            GrammarType.create("(" + tag + ")")
#    	        end
#	        end
#	        endTime = Time::now
#	        duration = endTime - startTime
#	        print duration.to_s + "\n"
#	        (duration < 3.0).should be(true)
#        end
    end
end
