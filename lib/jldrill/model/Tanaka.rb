require 'jldrill/model/DataFile'

module JLDrill

    # Represents one of the words stored in the Tanaka library
    class TanakaWord
        attr_reader :kanji, :reading
        attr_writer :kanji, :reading

        def initialize(kanji, reading)
            @kanji = kanji
            @reading = reading
        end

        def to_s
            retVal = @kanji
            if !@reading.nil?
                retVal += "(#{@reading})"
            end
            return retVal
        end

        def eql?(word)
            return self.to_s.eql?(word.to_s)
        end

        def hash
            self.to_s.hash
        end
    end

    # Represents the Tanaka reference library
	class Tanaka < DataFile

        attr_reader :words, :sentences
        attr_writer :words, :sentences
	
        A_RE = /^A: (.*)\#ID=.*$/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*)(\(([^)]*)\))?(\[([^\]]*)\])?(\{([^}]*)\})?([~])?/u

		def initialize()
            super
            @sentences = []
            @words = {}
            @stepSize = 500
		end

        def numSentences
            return @sentences.size
        end

        def numWords
            return @words.keys.size
        end

        def addWord(word, pos)
            if WORD_RE.match(word)
                base = TanakaWord.new($1, $3)
                if @words.has_key?(base)
                    @words[base].push(pos)
                else
                    @words[base] = [pos]
                end
            end
        end

        def parseLines(aLine, bLine)
            success = false
            if A_RE.match(aLine)
                sentence = $1
                if B_RE.match(bLine)
                    @sentences.push(sentence)
                    pos = @sentences.size - 1
                    w = $1.split(' ')
                    w.each do |word|
                        addWord(word, pos)
                    end
                    success = true
                end
            end
            return success
        end

        def parsedData
            @sentences
        end

        def parseEntry
            if parseLines(@lines[@parsed], @lines[@parsed + 1])
                @parsed += 2
                # As long as a single line gets parsed it is a success
            else
                @parsed += 1
            end
        end

        def search(kanji, reading)
            if !kanji.nil?
                contents = @words[TanakaWord.new(kanji, reading)]
                if contents.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most words don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    contents = @words[TanakaWord.new(kanji, nil)]
                end
            else
                # When there is no kanji, use the reading as the kanji
                contents = @words[TanakaWord.new(reading, nil)]
            end
            retVal = []
            if !contents.nil?
                contents.each do |pos|
                    retVal.push(@sentences[pos])
                end
            end
            return retVal
        end

	end
end
