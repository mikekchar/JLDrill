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
                    return Reason.new(string.chomp)
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

            attr_reader :original, :replaceWith, :reason

            RULE_RE = /^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/

            def initialize(original, replaceWith, reason)
                @original = original
                @replaceWith = replaceWith
                @reason = reason
            end

            def Rule::parse(string, reasons)
                retVal = nil
                if RULE_RE.match(string)
                    retVal = Rule.new($1, $2, reasons[$4.to_i])
                end
                return retVal
            end

            def to_s
                @original + "\t" + @replaceWith + "\t" + reason
            end
        end

        class Transform

            attr_reader :original, :root, :rule

            def initialize(orig, root, rule)
                @orignal = orig
                @root = root
                @rule = rule
            end

            def Transform.start(string)
                Transform.new(string, string, nil)
            end

            def dictionary
                retVal = @root
                if !@rule.nil?
                    retVal = @root + @rule.replaceWith
                end
                return retVal
            end

            def to_s
                @orignal + " " + @root + " " + @rule.to_s
            end
        end

        class Match < Array

            def initialize(transform, history=nil)
                if !history.nil?
                    super(history)
                else
                    super()
                end
                push(transform)
            end

            def Match.start(string)
                Match.new(Transform.start(string))
            end

            def hasReason(rule)
                any? do |transform|
                    if !transform.nil? && !transform.rule.nil?
                        transform.rule.reason.eql?(rule.reason)
                    else
                        false
                    end
                end
            end

            def apply(rule)
                retVal = nil
                if !last.nil? && !hasReason(rule)
                    re = Regexp.new("(.*)#{rule.original}")
                    if re.match(last.dictionary)
                        transform = Transform.new(last.dictionary, $1, rule)
                        retVal = Match.new(transform, self)
                    end
                end
                return retVal
            end

            def transforms
                collect do |transform|
                    if !transform.rule.nil?
                        "(#{transform.root}#{transform.rule.original}) #{transform.rule.reason}: #{transform.dictionary}"
                    else
                        transform.dictionary
                    end
                end.join(" > ")
            end

            def to_s
                transforms
            end
        end
    end

    # An array of Deinflection Rules.
	class DeinflectionRules

        attr_reader :reasons, :rules

        def initialize
            @reasons = []
            @rules = []
            @readHeader = false
        end

		def parse(string)
            if !@readHeader
                # The first line of the file must be discarded
                @readHeader = true
            else
                entry = Deinflection::Rule.parse(string, @reasons)
                if(!entry.nil?)
                    @rules.push(entry)
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

        def match(string)
            retVal = [Deinflection::Match.start(string)]
            i = 0
            while(i < retVal.size) do
                @rules.each do |rule|
                    new = retVal[i].apply(rule)
                    if !new.nil? && !retVal.any? do |match|
                        match.last.dictionary.eql?(new.last.dictionary)
                    end
                        retVal.push(new)
                    end
                end
                i += 1
            end
            return retVal
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

        def match(string)
            @deinflectionRules.match(string)
        end
    end

end
