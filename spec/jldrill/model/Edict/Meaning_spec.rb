require 'jldrill/model/items/edict/Meaning'

module JLDrill

	describe Meaning do
	
	    it "should have types and usages when created" do
	        meaning = Meaning.new
	        meaning.types.size.should be(0)
	        meaning.usages.size.should be(0)
	    end
	    
	    it "should be able to parse a single usage" do
	        meaning = Meaning.create("fun")
	        meaning.usages.size.should be(1)
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(0)
	    end
	    
	    it "should be able to parse a single usage with types" do
	        meaning = Meaning.create("(n,suf)(P) fun")
	        meaning.usages.size.should be(1)
	        meaning.types.size.should be(0)
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(3)
	        meaning.usages[0].allTypes[0].should be_eql("n")
	        meaning.usages[0].allTypes[1].should be_eql("suf")
	        meaning.usages[0].allTypes[2].should be_eql("P")
        end
        
        it "should be able to parse a specific single usage with types" do
	        meaning = Meaning.create("(1)(n,suf)(P) fun")
	        meaning.usages.size.should be(1)
	        meaning.types.size.should be(0)
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(3)
	        meaning.usages[0].allTypes[0].should be_eql("n")
	        meaning.usages[0].allTypes[1].should be_eql("suf")
	        meaning.usages[0].allTypes[2].should be_eql("P")
	    end

        it "should be able to parse a meaning with types and a specific single usage without types" do
	        meaning = Meaning.create("(n,suf)(P) (1)fun")
	        meaning.usages.size.should be(1)
	        meaning.types.size.should be(3)
	        meaning.types[0].should be_eql("n")
	        meaning.types[1].should be_eql("suf")
	        meaning.types[2].should be_eql("P")
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(0)
	    end

        it "should be able to parse a meaning with types and a specific single usage with types" do
	        meaning = Meaning.create("(n,suf)(P) (1)(exp)fun")
	        meaning.usages.size.should be(1)
	        meaning.types.size.should be(3)
	        meaning.types[0].should be_eql("n")
	        meaning.types[1].should be_eql("suf")
	        meaning.types[2].should be_eql("P")
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(1)
	        meaning.usages[0].allTypes[0].should be_eql("exp")
	    end

        it "should be able to parse multiple usages" do
	        meaning = Meaning.create("(n,suf)(P)(1)(exp)fun (2) foo/bar")
	        meaning.usages.size.should be(2)
	        meaning.types.size.should be(3)
	        meaning.types[0].should be_eql("n")
	        meaning.types[1].should be_eql("suf")
	        meaning.types[2].should be_eql("P")
	        meaning.usages[0].allDefinitions.size.should be(1)
	        meaning.usages[0].allDefinitions[0].should be_eql("fun")
	        meaning.usages[0].allTypes.size.should be(1)
	        meaning.usages[0].allTypes[0].should be_eql("exp")            
	        meaning.usages[1].allDefinitions.size.should be(2)
	        meaning.usages[1].allDefinitions[0].should be_eql("foo")
	        meaning.usages[1].allDefinitions[1].should be_eql("bar")
	        meaning.usages[1].allTypes.size.should be(0)
        end
        
        it "should be able to get all types in the meaning" do
	        meaning = Meaning.create("((1)fun (2) foo/bar")
	        meaning.allTypes.size.should be(0)
	        meaning = Meaning.create("(n,suf)(P)(1)(exp)fun (2) (adj)foo/(adv,pref)bar")
	        meaning.allTypes.size.should be(7)
	        meaning.allTypes[0].should be_eql("n")
	        meaning.allTypes[1].should be_eql("suf")
	        meaning.allTypes[2].should be_eql("P")
	        meaning.allTypes[3].should be_eql("exp")
	        meaning.allTypes[4].should be_eql("adj")
	        meaning.allTypes[5].should be_eql("adv")
	        meaning.allTypes[6].should be_eql("pref")
        end
        
        it "should be able to get all definitions in the meaning" do
            meaning = Meaning.create("(n,P)(1)(exp)(2)(adv,adj)")
            meaning.allDefinitions.size.should be(0)
            meaning = Meaning.create("(n,P)(1)(exp)This/is/a(2)(adv,adj)hack")
            meaning.allDefinitions.size.should be(4)
            meaning.allDefinitions[0].should be_eql("(1) This")
            meaning.allDefinitions[1].should be_eql("is")
            meaning.allDefinitions[2].should be_eql("a")
            meaning.allDefinitions[3].should be_eql("(2) hack")
            meaning = Meaning.create("fun")
            meaning.allDefinitions.size.should be(1)
            meaning.allDefinitions[0].should be_eql("fun")
        end
        
        it "should be able to output the meaning as a string" do
	        meaning = Meaning.create("(n,suf)(P)(1)(exp)fun (2) (adj)foo/(adv,pref)bar")
	        meaning.to_s.should be_eql("(n,suf,P) (1)(exp)fun (2)(adj)foo/(adv,pref)bar\n")
        end
    end 
end
