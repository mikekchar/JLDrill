require 'jldrill/model/Config'

module JLDrill

	describe Config do
	
	    it "should have a DATA_DIR" do
	        Config::DATA_DIR.should_not be_nil
	    end
	    
	    it "should have a different DATA_DIR for Gem" do
	        Config::getDataDir.should be_eql("data/jldrill")
	        def Gem.datadir(string)
	            "blah"
	        end
	        Config::getDataDir.should be_eql("blah")
	    end
	    
    end
    
end
