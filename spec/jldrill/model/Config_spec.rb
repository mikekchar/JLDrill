require 'jldrill/model/Config'

module JLDrill

	describe Config do
	
	    it "should have a DATA_DIR" do
	        Config::DATA_DIR.should_not be_nil
	    end

# I can't do this test as written because it interferes with other tests	    
	    it "should have a different DATA_DIR for Gem"
#        do
#	        Config::getDataDir.should eql(File.expand_path("data/jldrill"))
#	        def Gem.datadir(string)
#	            "blah"
#	        end
#	        Config::getDataDir.should eql(File.expand_path("blah"))
#	    end
	    
    end
    
end
