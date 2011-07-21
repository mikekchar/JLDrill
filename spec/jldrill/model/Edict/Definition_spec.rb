# encoding: utf-8
require 'jldrill/model/items/edict/Definition'

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
	        string = "(exp,n,suf)holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql("holy cow")
	        defn.types.size.should be(3)
	        defn.types[0].should be_eql("exp")
	        defn.types[1].should be_eql("n")
   	        defn.types[2].should be_eql("suf")
	    end

	    it "should pick up multiple sets of types" do
	        string = "(exp,n,suf)(uK)holy cow"
	        defn = Definition.create(string)
	        defn.value.should be_eql("holy cow")
	        defn.types.size.should be(4)
	        defn.types[0].should be_eql("exp")
	        defn.types[1].should be_eql("n")
   	        defn.types[2].should be_eql("suf")
   	        defn.types[3].should be_eql("uK")
	    end
	    
	    it "should be able to match equivalence" do
	        Definition.create("fun").should be_eql(Definition.create("fun"))
	        Definition.create("fun").should_not be_eql(Definition.create("Bob"))
	        Definition.create("fun").should_not be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf)fun").should_not be_eql(Definition.create("fun"))
	        Definition.create("(suf)fun").should be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf,P)fun").should_not be_eql(Definition.create("(suf)fun"))
	        Definition.create("(suf,P)fun").should_not be_eql(Definition.create("(suf,P,uk)fun"))
	        Definition.create("(suf,P,uk)fun").should be_eql(Definition.create("(suf,P,uk)fun"))
	    end
	    
	    it "should be able to handle parenthesis" do
	        defn = Definition.create("(usually) eats grass")
	        # It isn't one of the normal tags
	        defn.types.size.should be(0)
	        defn.value.should be_eql("(usually) eats grass")
	    end

        it "should be able to handle special language tags" do
            defn = Definition.create("(de:) part time job")
            defn.types.size.should be(1)
            defn.types[0].should be_eql("de:")
            defn.value.should be_eql("part time job")
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
