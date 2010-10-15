require 'jldrill/model/items/edict/Edict'

module JLDrill

	describe Edict do
	
	    it "should be able to be constructed with or without a filename" do
	        edict1 = Edict.new("aFilename")
	        edict1.should_not be_nil
	        edict1.file.should be_eql("aFilename")
	        edict2 = Edict.new()
	        edict2.should_not be_nil
	        edict2.file.should eql("")
	    end
	    
	    it "should be able to set the filename after creation" do
	        edict = Edict.new
	        edict.file.should eql("")
	        edict.file = "Whoohoo"
	        edict.file.should be_eql("Whoohoo")
	    end
	    
	    it "should be able to read the file in chunks" do
			dictDir = File.join(Config::DATA_DIR, "dict")
            filename = File.join(dictDir, "edict")
            edict = Edict.new
            edict.file = filename
            edict.readLines
            edict.lines.size.should be(162808)
            edict.parseChunk(1000)
            edict.length.should be(1000)
            edict.parsed.should be(1000)
            edict.loaded?.should be(false)
# This part of the test is too slow to run every time right now
#            while !edict.parseChunk(1000) do end
#            edict.length.should be(142339)
	    end
	
    end
    
end
