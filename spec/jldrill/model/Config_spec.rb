require 'jldrill/model/Config'

module JLDrill

	describe Config do
	
	    it "should have a DATA_DIR" do
	        Config::DATA_DIR.should_not be_nil
	    end
	    
    end
    
end
