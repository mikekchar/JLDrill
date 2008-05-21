require 'jldrill/model/Edict/Edict'

module JLDrill

	describe Edict do
	
	    it "should be able to be constructed with or without a filename" do
	        edict1 = Edict.new("aFilename")
	        edict1.should_not be_nil
	        edict1.file.should be_eql("aFilename")
	        edict2 = Edict.new()
	        edict2.should_not be_nil
	        edict2.file.should be_nil
	    end
	    
	    it "should not try to read the file if it isn't set" do
	        edict = Edict.new()
	        edict.file.should be_nil
	        edict.read.should be(false)
	    end
	
	    it "should be able to set the filename after creation" do
	        edict = Edict.new
	        edict.file.should be_nil
	        edict.file = "Whoohoo"
	        edict.file.should be_eql("Whoohoo")
	    end
	
    end
    
end
