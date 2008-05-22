require 'jldrill/model/Edict/Definition'

module JLDrill

	describe Definition do
	
	    it "should have a value and types when created" do
	        defn = Definition.new
	        defn.value.should be_eql("")
	        defn.types.size.should be(0)
	    end
	    
	    it "should be able to parse Edict definitions" do
	        string = "holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql(string)
	        defn.types.size.should be(0)
	    end
	    
	    it "should be able to parse Edict definitions with a type" do
	        string = "(exp)holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql("holy cow")
	        defn.types.size.should be(1)
	        defn.types[0].should be_eql("exp")
	    end

	    it "should be able to parse Edict definitions with many types" do
	        string = "(exp,n,funny)holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql("holy cow")
	        defn.types.size.should be(3)
	        defn.types[0].should be_eql("exp")
	        defn.types[1].should be_eql("n")
   	        defn.types[2].should be_eql("funny")
	    end

	    it "should pick up multiple sets of types" do
	        string = "(exp,n,funny)(This)holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql("holy cow")
	        defn.types.size.should be(4)
	        defn.types[0].should be_eql("exp")
	        defn.types[1].should be_eql("n")
   	        defn.types[2].should be_eql("funny")
   	        defn.types[3].should be_eql("This")
	    end
	    
	    it "should be able to match equivalence" do
	        Definition.create("fun").should be_eql(Definition.create("fun"))
	        Definition.create("fun").should_not be_eql(Definition.create("Bob"))
	        Definition.create("fun").should_not be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf)fun").should_not be_eql(Definition.create("fun"))
	        Definition.create("(suf)fun").should be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf,P)fun").should_not be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf,P)fun").should_not be_eql(Definition.create("(suf,P,B)fun"))
	        Definition.create("(suf,P,B)fun").should be_eql(Definition.create("(suf,P,B)fun"))
	    end

        # For profiling	    
#	    it "should be fast" do
#	        string = "(exp,n,funny)(This)holy cow"
#	        startTime = Time::now
#	        0.upto(100000) do
#    	        defn = Definition.create(string)
#	        end
#	        endTime = Time::now
#	        duration1 = endTime - startTime
#	        startTime = Time::now
#	        0.upto(100000) do
#    	        defn = Definition.exp_create(string)
#	        end
#	        endTime = Time::now
#	        duration2 = endTime - startTime
#	        print ((duration1 - duration2)/duration1).to_s + "\n"
#	        (duration2 < duration1).should be(true)
#	    end

    end
    
end
