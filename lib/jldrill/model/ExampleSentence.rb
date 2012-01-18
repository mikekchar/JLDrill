# encoding: utf-8

module JLDrill

    # Describes how a piece of vocabulary has been used in a sentence.
    # It includes the kanji, reading, the sense that the vocabulary
    # was used, the grammatical form that was used and whether
    # the usage has been checked as being accurate.
    class VocabularyUsage
        attr_reader :kanji, :reading, :sense, :usedForm, :checked
        attr_writer :kanji, :reading, :sense, :usedForm, :checked
 
        B_LINE_RE = /^([^(\[{~]*)(\(([^)]*)\))?(\[([^\]]*)\])?(\{([^}]*)\})?(~)?/u

        def initialize()
            @kanji = ""
            @reading = ""
            @sense = 0
            @usedForm = ""
            @checked = false
        end

        def VocabularyUsage::from_B_line(data)
            retVal = VocabularyUsage.new()
            if B_LINE_RE.match(data)
                retVal.kanji = $1
                retVal.reading = $3
                if !$5.nil?
                    retVal.sense = $5.to_i
                else
                    retVal.sense = 0
                end
                retVal.usedForm = $7
                retVal.checked = $8.eql?("~")
            end
            return retVal
        end

        # Output the Vocabulary usage in the same form as used
        # by the B lines in the Tanaka Corpus 
        def to_B_line
            retVal = @kanji.to_s
            if !@reading.nil?
                retVal += "(#{@reading})"
            end
            if @sense != 0
                retVal += "[#{@sense.to_s}]"
            end
            if !@actual.nil?
                retVal += "{#{@actual.to_s}}"
            end
            if @checked
                retVal += "~"
            end
            return retVal
        end

        def to_s
            return to_B_line
        end
    end

    # An example sentence.  Each sentence has a key indicating the vocabulary
    # usage that was searched for to generate the Example Sentence.
    class ExampleSentence
        attr_reader :key

        def initialize()
            @key = nil
        end

        # Returns the version of the sentence in the user's native language
        # Please override in the concrete version
        def nativeLanguage()
            return ""
        end

        # Returns the version of the sentence in the language being studied
        # Please override in the concrete version
        def targetLanguage()
            return ""
        end

        def nativeOnly_to_s()
            return "#{key}\n\t#{self.nativeLanguage}"
        end

        def targetOnly_to_s()
            return "#{key}\n\t#{self.targetLanguage}"
        end

        def to_s()
            return "#{key}\n\t#{self.targetLanguage}\n\t#{self.nativeLanguage}"
        end
    end
end
