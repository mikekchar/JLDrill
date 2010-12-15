require 'jldrill/model/DeinflectionRules'
require 'jldrill/model/Config'

module JLDrill

	describe Deinflection::Reason do
	
		it "should be able to parse an reason from the deinflect file" do
			reasonString = "This is a reason"

            Deinflection::Reason.isReason?(reasonString).should eql(true)
            ruleString = "This is\ta rule\t1250\t0"
            Deinflection::Reason.isReason?(ruleString).should eql(false)
            reason = Deinflection::Reason.parse(reasonString)
            reason.should eql("This is a reason")
            yuck = Deinflection::Reason.parse(ruleString)
            yuck.should be_nil
		end
	end
	
    describe Deinflection::Reason do
        it "should parse a reason" do
            rule = Deinflection::Rule.parse("くありませんでした	い	1152	0")
            rule.original.should eql("くありませんでした")
            rule.replaceWith.should eql("い")
            rule.reasonIndex.should eql(0)
        end
    end

    describe DeinflectionRulesFile do
        it "should load the file properly" do
            filename = File.join(Config::DEINFLECTION_DIR, 
                                 Config::DEINFLECTION_NAME)
            file = DeinflectionRulesFile.new
            file.load(filename)
            file.parse
            file.deinflectionRules.reasons.size.should be(28)
            file.deinflectionRules.rules.size.should be(306)

            matches = file.match("できませんでした")
            print matches.join("\n") + "\n\n\n"
#            matches.size.should be(13)
#            matches[3].key.should eql("できる")
            # The keys should all be different and none of the deinflection
            # rules should be used twice.  Not sure how to write a test.
            
            matches = file.match("です")
            print matches.join("\n") + "\n"
        end
    end
end
