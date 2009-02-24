require 'jldrill/model/items/edict/HashedEdict'

module JLDrill

	describe HashedEdict do
	
	    it "should be able to be constructed with or without a filename" do
	        edict1 = HashedEdict.new("aFilename")
	        edict1.should_not be_nil
	        edict1.file.should eql("aFilename")
	        edict2 = HashedEdict.new()
	        edict2.should_not be_nil
	        edict2.file.should be_nil
	    end
	
    end
    
end
