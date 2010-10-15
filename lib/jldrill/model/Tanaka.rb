require 'jldrill/model/DataFile'

module JLDrill

    # Represents the Tanaka reference library
	class Tanaka < DataFile
	
        A_RE = /^A: (.*)\#ID=.*$/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*)/

		def initialize()
            super
            @sentences = []
            @words = {}
		end

        def numSentences
            return @sentences.size
        end

        def numWords
            return @words.keys.size
        end

        def addWord(word, pos)
            if WORD_RE.match(word)
                base = $1
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

        def search(word)
            contents = @words[word]
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
