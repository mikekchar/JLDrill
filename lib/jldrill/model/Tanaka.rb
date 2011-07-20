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

        RE = /^A: ([^\t]*)\t(.*)#ID=(.*)$/u
        WORD_RE = /^([^(\[{~]*)(\(([^)]*)\))?(\[([^\]]*)\])?(\{([^}]*)\})?(~)?/u

        attr_reader :kanji, :reading, :sense, :actual, :checked

        def initialize(data, wordData)
            @data = data
            @wordData = wordData
            parseWordData
        end

        def parseWordData
            if WORD_RE.match(@wordData)
                @kanji = $1
                @reading = $3
                if !$5.nil?
                    @sense = $5.to_i
                else
                    @sense = 0
                end
                @actual = $7
                @checked = $8.eql?("~")
            end
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

        def word_to_s
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

        def japaneseTo_s
            return "#{self.id}: " + word_to_s + "\n\t#{self.japanese}"
        end

        def englishTo_s
            return "#{self.id}: " + "\n\t#{self.english}"
        end

        def to_s
            return "#{self.id}: " + word_to_s + "\n\t#{self.japanese}\n\t#{self.english}"
        end
    end

    # Represents the results of searching the Tanaka reference library
    # It is composed of a list of sentences.
    class SearchResults

        attr_reader :sentences, :connections
        attr_writer :sentences, :connections

        def initialize(word, connections, sentences)
            @word = word
            @sentences = sentences
            @connections = connections
        end

        def getSentences
            retVal = []
            if !@connections.nil?
                wordData = getWordData
                @connections.each_with_index do |connection, i|
                    retVal.push(Sentence.new(@sentences[connection], wordData[i]))
                end
            end
            return retVal
        end

        def findWord(connection)
            connection.split(" ").each do |word|
                if word.start_with?(@word)
                    return word
                end
            end
            return ""
        end

        def getWordData
            wordData = []
            @connections.each_with_index do |connection, i|
                wordData.push(findWord(@sentences[connection + 1]))
            end
            return wordData 
        end

    end

    # Represents the Tanaka reference library
	class Reference < JLDrill::DataFile

        attr_reader :words
        attr_writer :words
	
        A_RE = /^A:/
        B_RE = /^B: (.*)/
        WORD_RE = /([^{(\[~]*(\([^)]*\))?)/u

		def initialize()
            super
            @sentences = 0
            @words = {}
            @stepSize = 1000
		end

        def numSentences
            dataSize
        end

        def numWords
            return @words.keys.size
        end

        def addWord(word, pos)
            if WORD_RE.match(word)
                (@words[$1] ||= []).push(pos)
            end
        end

        def parseLines(aLine, bLine, pos)
            success = false
            if A_RE.match(aLine)
                if B_RE.match(bLine)
                    @sentences += 1
                    w = $1.split(' ')
                    w.each do |word|
                        addWord(word, pos)
                    end
                    success = true
                end
            end
            return success
        end

        def dataSize
            @sentences
        end

        def parseEntry
            if parseLines(@lines[@parsed], @lines[@parsed + 1], @parsed)
                @parsed += 2
                # As long as a single line gets parsed it is a success
            else
                @parsed += 1
            end
        end

        def search(kanji, reading)
            word = nil
            if !kanji.nil?
                word = Word.create(kanji, reading).to_s
                connections = @words[word]
                if connections.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most words don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    word = Word.create(kanji, nil).to_s
                    connections = @words[word]
                end
            else
                # When there is no kanji, use the reading as the kanji
                word = Word.create(reading, nil).to_s
                connections = @words[word]
            end

            return SearchResults.new(word, connections, @lines).getSentences
        end

        # Don't erase @lines because we need them later
        def finishParsing
            setLoaded(true)
        end

	end
end
