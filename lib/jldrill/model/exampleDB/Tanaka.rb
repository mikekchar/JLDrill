# encoding: utf-8
require 'jldrill/model/util/DataFile'
require 'jldrill/model/ExampleSentence'

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

    class Sentence < JLDrill::ExampleSentence

        RE = /^A: ([^\t]*)\t(.*)#ID=(.*)$/u

        def initialize(data, wordData)
            @data = data
            @key = JLDrill::VocabularyUsage.from_B_line(wordData)
        end

        def nativeLanguage()
            retVal = ""
            if RE.match(@data)
                retVal = $2
            end
            return retVal
        end

        def targetLanguage
            retVal = ""
            if RE.match(@data)
                retVal = $3 + ": " + $1
            end
            return retVal
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
