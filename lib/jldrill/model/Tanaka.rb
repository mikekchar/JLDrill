module JLDrill

    # Represents the Tanaka reference library
	class Tanaka
	
        A_RE = /^A: (.*)\#ID=.*$/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*)/

		def initialize()
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

        def parse(text)
            success = false
            if A_RE.match(text)
                sentence = $1
                if B_RE.match(text)
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
