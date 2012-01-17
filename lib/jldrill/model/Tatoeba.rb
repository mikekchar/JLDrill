
# encoding: utf-8
require 'jldrill/model/DataFile'

module JLDrill::Tatoeba

    class SentenceFile < JLDrill::DataFile
        INDEX_RE = /^(\d*)[\t]/
        SENTENCE_RE = /^(\d*)[\t](.*)[\t](.*)/
        def initialize()
            super
            @sentences = []
            @stepSize = 1000
        end

        def dataSize
            @sentences.size
        end

        def parseEntry
            if INDEX_RE.match(@lines[@parsed])
                index = $1.to_i
                @sentences[index] = @parsed
            end
            @parsed += 1
        end

        # Don't erase @lines because we need them later
        def finishParsing
            setLoaded(true)
        end

        def sentenceAt(index)
            retVal = ""
            entry = @sentences[index]
            if !entry.nil?
                if SENTENCE_RE.match(@lines[entry])
                    retVal = $3
                end
            end
            return retVal
        end
    end
    class LinkFile < JLDrill::DataFile
        LINK_RE = /^(\d*)[\t](\d*)/
        def initialize()
            super
            @links = []
            @stepSize = 1000
        end

        def dataSize
            @links.size
        end

        def parseEntry
            if LINK_RE.match(@lines[@parsed])
                index = $1.to_i
                (@links[index] ||= []).push($2.to_i)
            end
            @parsed += 1
        end

        # Don't erase @lines because we need them later
        def finishParsing
            setLoaded(true)
        end

        def getLinksTo(index)
            retVal = @links[index]
            if retVal.nil?
                retVal = []
            end
            return retVal
        end
    end

    # Represents one of the words stored in the Japanese Indeces
    class IndexWord
        attr_reader :contents

        def initialize(contents)
            @contents = contents
        end

        def IndexWord.create(kanji, reading)
            contents = kanji
            if !reading.nil?
                contents += "(#{reading})"
            end
            return IndexWord.new(contents)
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

    # Represents a sentence in the JapaneseIndeces file
    class IndexSentence

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/
        WORD_RE = /^([^(\[{~]*)(\(([^)]*)\))?(\[([^\]]*)\])?(\{([^}]*)\})?(~)?/u

        attr_reader :kanji, :reading, :sense, :actual, :checked

        def initialize(data)
            @kanji = ""
            @reading = ""
            @sense = 0
            @actual = ""
            @checked = false
            @japaneseIndex = 0
            @englishIndex = 0

            if INDEX_RE.match(data)
                @japaneseIndex = $1.to_i
                @englishIndex = $2.to_i 
                parseWordData($3)
            end
        end

        def parseWordData(wordData)
            if WORD_RE.match(wordData)
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

        def english(sentenceFile)
            return sentenceFile.sentenceAt(@englishIndex)
        end

        def japanese(sentenceFile)
            return sentenceFile.sentenceAt(@japaneseIndex)
        end

        def id
            return @japaneseIndex
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

        def japaneseTo_s(sentenceFile)
            return "#{self.id}: " + word_to_s + "\n\t#{self.japanese(sentenceFile)}"
        end

        def englishTo_s(sentenceFile)
            return "#{self.id}: " + "\n\t#{self.english(sentenceFile)}"
        end

        def to_s(sentenceFile)
            return "#{self.id}: " + word_to_s + "\n\t#{self.japanese(sentenceFile)}\n\t#{self.english(sentenceFile)}"
        end
    end

    # Represents the results of searching the Tatoeba reference library
    # It is composed of a list of sentences.
    class SearchResults

        attr_reader :lines, :connections
        attr_writer :lines, :connections

        def initialize(word, connections, lines)
            @word = word
            @lines = lines
            @connections = connections
        end

        def getSentences
            retVal = []
            if !@connections.nil?
                @connections.each_with_index do |connection, i|
                    retVal.push(IndexSentence.new(@lines[connection]))
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
    end

    class JapaneseIndexFile < JLDrill::DataFile

        attr_reader :words
        attr_writer :words

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/
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

        def parseEntry
            if INDEX_RE.match(@lines[@parsed])
                @sentences += 1
                w = $3.split(' ')
                w.each do |word|
                    addWord(word, @parsed)
                end
            end
            @parsed += 1
        end

        def dataSize
            @sentences
        end

        def search(kanji, reading)
            word = nil
            if !kanji.nil?
                word = IndexWord.create(kanji, reading).to_s
                connections = @words[word]
                if connections.nil?
                    # The corpus only uses readings to disambiguate
                    # kanji.  Most words don't have readings.  So
                    # if we don't find anything, search again without
                    # the reading.
                    word = IndexWord.create(kanji, nil).to_s
                    connections = @words[word]
                end
            else
                # When there is no kanji, use the reading as the kanji
                word = IndexWord.create(reading, nil).to_s
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

