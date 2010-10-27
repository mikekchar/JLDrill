require 'jldrill/model/DataFile'

module JLDrill::Tanaka

    # Represents one of the words stored in the Tanaka library
    class Word
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

    class Sentence
        attr_reader :english, :japanese, :id
        attr_writer :english, :japanese, :id

        RE = /([^\t]*)\t(.*)#ID=(.*)$/u

        def initialize(japanese, english, id)
            @japanese = japanese
            @english = english
            @id = id
        end

        def Sentence.create(string)
            retVal = nil
            if RE.match(string)
                retVal = Sentence.new($1, $2, $3.to_i)
            else
                print "Tanaka: Couldn't parse Sentence #{string}\n"
            end
            return retVal
        end 

        def to_s
            return @japanese.to_s + "\t" + @english.to_s + "#ID=#{@id}"
        end
    end

    # Represents the connection between a word and a sentence.  It keeps
    # track of what sense the word is used in the sentence and
    # whether or not the usage is typical and checked.
    class Connection
        attr_reader :pos, :sense
        attr_writer :pos, :sense, :typical

        def initialize(pos, sense, typical)
            @pos = pos
            @sense = sense
            @typical = typical
        end

        def isTypical?
            return @typical
        end
    end

    # Represents the Tanaka reference library
	class Reference < JLDrill::DataFile

        attr_reader :words, :sentences
        attr_writer :words, :sentences
	
        A_RE = /^A: (.*)$/
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
                base = Word.new($1, $3)
                connection = Connection.new(pos, $5, !$8.nil?)
                if @words.has_key?(base)
                    @words[base].push(connection)
                else
                    @words[base] = [connection]
                end
            end
        end

        def parseLines(aLine, bLine)
            success = false
            if A_RE.match(aLine)
                sentence = $1
                if B_RE.match(bLine)
                    @sentences.push(Sentence.create(sentence))
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
                connections = @words[Word.new(kanji, reading)]
                if connections.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most words don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    connections = @words[Word.new(kanji, nil)]
                end
            else
                # When there is no kanji, use the reading as the kanji
                connections = @words[Word.new(reading, nil)]
            end
            retVal = []
            if !connections.nil?
                connections.each do |connection|
                    retVal.push(@sentences[connection.pos])
                end
            end
            return retVal
        end

	end
end
