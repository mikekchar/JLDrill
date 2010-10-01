module JLDrill

    # Represents the Tanaka reference library
	class Tanaka
	
        A_RE = /^A: (.*)\#ID=.*$/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*)/

		attr_reader :file, :lines
		attr_writer :file, :lines

		def initialize()
            @sentences = []
            @words = {}
			@file = ""
			@lines = []
			@parsed = 0
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

		def eof?
			return @parsed >= @lines.size
		end

		def loaded?
			return eof? && (@words.size > 0)
		end

		def fraction
			retVal = 0.0
			if @lines.size != 0
				retVal = @parsed.to_f / @lines.size.to_f
			end
			return retVal
		end

		def parse
			parseChunk(@lines.size)
		end

		def parseChunk(size)
			last = @parsed + size
			if last > @lines.size
				last = @lines.size
			end
			while @parsed < last do
				if parseLines(@lines[@parsed], @lines[@parsed + 1])
					@parsed += 2
					# As long as a single line gets parsed it is a success
				else
					@parsed += 1
				end
			end

			# If the parsing is finished dispose of the unparsed lines
			finished = self.eof?
			if finished
				@lines = []
				@parsed = 0
			end

			return finished
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

		def readLines
			@lines = IO.readlines(@file)
			@parsed = 0
		end

		def load(file)
			@file = file
			readLines
			parse
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
