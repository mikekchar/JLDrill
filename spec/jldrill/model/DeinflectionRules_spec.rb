# encoding: utf-8
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
            reasons = ["This is a reason"]
            rule = Deinflection::Rule.parse("くありませんでした	い	1152	0",
                                           reasons)
            rule.original.should eql("くありませんでした")
            rule.replaceWith.should eql("い")
            rule.reason.should eql("This is a reason")
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
            matches.size.should be(18)
            matches[3].last.dictionary.should eql("できる")
            # The keys should all be different and none of the deinflection
            # rules should be used twice.  Not sure how to write a test.
            
            matches = file.match("です")
            matches.size.should be(2)
            matches[0].last.dictionary.should eql("です")
            matches[1].last.dictionary.should eql("でる")

            # This was a bug
            matches = file.match("こばんで")
            matches.size.should be(5)
            matches[3].last.dictionary.should eql("こばむ")
        end
    end
end
