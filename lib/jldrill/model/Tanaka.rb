require 'jldrill/model/DataFile'

module JLDrill::Tanaka

    # Represents one of the words stored in the Tanaka library
    class Word
        attr_reader :contents

        def initialize(contents)
            @contents = contents
        end

        def Word.create(kanji, reading)
            contents = kanji
            if !reading.nil?
                contents += "(#{reading})"
            end
            return Word.new(contents)
        end

        def to_s
            @contents
        end

        def eql?(word)
            return @contents.eql?(word.contents)
        end

        def hash
            @contents.hash
        end
    end

    class Sentence

        RE = /([^\t]*)\t(.*)#ID=(.*)$/u

        def initialize(data)
            @data = data
        end

        def english
            retVal = ""
            if RE.match(@data)
                retVal = $2
            end
            return retVal
        end

        def japanese
            retVal = ""
            if RE.match(@data)
                retVal = $1
            end
            return retVal
        end

        def id
            retVal = ""
            if RE.match(@data)
                retVal = $3.to_i
            end
            return retVal
        end
        
        def to_s
            return @data
        end
    end

    # Represents the connection between a word and a sentence.  It keeps
    # track of what sense the word is used in the sentence and
    # whether or not the usage is typical and checked.
    class Connection
        attr_reader :pos
        attr_writer :pos

        DATA_RE = /(\[([^\]]*)\])?(\{([^}]*)\})?([~])?/u

        def initialize(pos, data)
            @pos = pos
            @data = data
        end
    end

    # Represents the results of searching the Tanaka reference library
    # It is composed of a list of sentences.
    class SearchResults

        attr_reader :sentences, :connections
        attr_writer :sentences, :connections

        def initialize(connections, sentences)
            @sentences = sentences
            @connections = connections
        end

        def getSentences
            retVal = []
            if !connections.nil?
                connections.each do |connection|
                    retVal.push(@sentences[connection.pos])
                end
            end
            return retVal
        end

    end

    # Represents the Tanaka reference library
	class Reference < JLDrill::DataFile

        attr_reader :words, :sentences
        attr_writer :words, :sentences
	
        A_RE = /^A: (.*)$/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*(\([^)]*\))?)(.*)/u

		def initialize()
            super
            @sentences = []
            @words = {}
            @stepSize = 100
		end

        def numSentences
            return @sentences.size
        end

        def numWords
            return @words.keys.size
        end

        def addWord(word, pos)
            if WORD_RE.match(word)
                base = Word.new($1)
                connection = Connection.new(pos, $3)
                (@words[base] ||= []).push(connection)
            end
        end

        def parseLines(aLine, bLine)
            success = false
            if A_RE.match(aLine)
                sentence = $1
                if B_RE.match(bLine)
                    @sentences.push(Sentence.new(sentence))
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
                connections = @words[Word.create(kanji, reading)]
                if connections.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most words don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    connections = @words[Word.create(kanji, nil)]
                end
            else
                # When there is no kanji, use the reading as the kanji
                connections = @words[Word.create(reading, nil)]
            end

            return SearchResults.new(connections, @sentences).getSentences
        end

	end
end
