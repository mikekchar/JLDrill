require 'jldrill/model/DataFile'
require 'Context/Log'

module JLDrill
    module Deinflection

        # Represents a deinflection reason.
        # In other words when you deinflect the verb using a rule, what
        # rule reason was it.  For example "past negative"
        class Reason < String
            def Reason::isReason?(string)
                # All of the rules in the deinflection file are tab separated.
                # Therefore if a line doesn't contain a tab then it is a reason 
                !string.include?("\t")
            end

            def Reason::parse(string)
                if Reason::isReason?(string)
                    return Reason.new(string)
                else
                    return nil
                end
            end
        end

        # Represents a deinflection rule.  It contains the string that
        # will be found in the original text, the text that will be used
        # to replace the original text, and an index into the reason
        # array.
        class Rule

            attr_reader :original, :replaceWith, :reasonIndex

            RULE_RE = /^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t])/

            def initialize(original, replaceWith, reasonIndex)
                @original = original
                @replaceWith = replaceWith
                @reasonIndex = reasonIndex
            end

            def Rule::parse(string)
                retVal = nil
                if RULE_RE.match(string)
                    retVal = Rule.new($1, $2, $4.to_i)
                end
                return retVal
            end
        end
    end

    # An array of Deinflection Rules.
	class DeinflectionRules

        attr_reader :reasons, :rules

        def initialize
            @reasons = []
            @rules = {}
            @readHeader = false
        end

		def parse(string)
            if !@readHeader
                # The first line of the file must be discarded
                @readHeader = true
            else
                entry = Deinflection::Rule.parse(string)
                if(!entry.nil?)
                    @rules[entry.original] = entry
                else
                    reason = Deinflection::Reason.parse(string)
                    if !reason.nil?
                        @reasons.push(reason)
                    else
                        Context::Log::warning("JLDrill::DeinflectionRules",
                                              "Could not parse #{string}")
                    end
                end
            end
		end

        def size
            return @rules.size + @reasons.size
        end
		
		def to_s
			self.join("\n")
		end
	end

    class DeinflectionRulesFile < DataFile
        attr_reader :deinflectionRules
        attr_writer :deinflectionRules

        def initialize
            super
            @deinflectionRules = DeinflectionRules.new
            @stepSize = 20
        end

        def dataSize
            @deinflectionRules.size
        end

        def parser
            @deinflectionRules
        end
    end

end
