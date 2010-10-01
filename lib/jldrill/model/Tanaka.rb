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

		def parse(lines)
			index = 0
			success = false
			while index < lines.size do
				if parseLines(lines[index], lines[index + 1])
					index += 2
					# As long as a single line gets parsed it is a success
					success = true
				else
					index += 1
				end
			end
			return success
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

		def load(file)
			parse(IO.readlines(file))
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
