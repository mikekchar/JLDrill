require 'jldrill/model/Edict/Usage'

module JLDrill

	describe Usage do
	
	    it "should have a value and types when created" do
	        usage = Usage.new
	        usage.definitions.size.should be(0)
	        usage.index.should be(0)
	    end
	    
	    it "should be able to parse Edict usages" do
	        usage = Usage.create("fun")
	        usage.definitions.size.should be(1)
	        usage.index.should be(0)
	        usage.definitions[0].should be_eql("fun")

	        usage = Usage.create("fun/silly")
	        usage.definitions.size.should be(2)
	        usage.index.should be(0)
	        usage.definitions[0].should be_eql("fun")
	        usage.definitions[1].should be_eql("silly")

	        usage = Usage.create("(n)fun/(n,suf)(P) silly billy thingy/wow", 2)
	        usage.definitions.size.should be(3)
	        usage.index.should be(2)
	        usage.definitions[0].should be_eql("fun")
	        usage.definitions[1].should be_eql("silly billy thingy")
	        usage.definitions[2].should be_eql("wow")
	    end
	    
	    it "should be able to output the edict usage again" do
	        usage = Usage.create("fun")
	        usage.to_s.should be_eql("fun")
	        usage = Usage.create("(n)fun/(n,suf)(P) silly billy thingy/wow", 2)
	        usage.to_s.should be_eql("(2)(n)fun/(n,suf,P)silly billy thingy/wow")
	    end
	    

    end
    
end
