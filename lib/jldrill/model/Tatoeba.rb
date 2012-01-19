# encoding: utf-8
require 'jldrill/model/DataFile'
require 'jldrill/model/VocabularyUsage.rb'
require 'jldrill/model/ExampleSentence.rb'

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

    # Represents a sentence in the JapaneseIndeces file
    class JapaneseExample < JLDrill::ExampleSentence

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/

        def initialize(data, vocabUsageData, sentences)
            @sentences = sentences
            
            if INDEX_RE.match(data)
                @japaneseIndex = $1.to_i
                @englishIndex = $2.to_i 
                @key = JLDrill::VocabularyUsage.from_B_line(vocabUsageData)
            else
                @japaneseIndex = 0
                @englishIndex = 0
                @key = JLDrill::VocabularyUsage.new()
            end
        end

        def nativeLanguage()
            return "#{@englishIndex}: #{@sentences.sentenceAt(@englishIndex)}"
        end

        def targetLanguage()
            return "#{@japaneseIndex}: #{@sentences.sentenceAt(@japaneseIndex)}"
        end
    end

    # Represents the results of searching the Tatoeba reference library
    # It is composed of a list of sentences.
    class SearchResults

        attr_reader :lines, :connections, :sentences
        attr_writer :lines, :connections

        def initialize(word, connections, lines, sentences)
            @word = word
            @lines = lines
            @connections = connections
            @sentences = sentences
        end

        def getSentences
            retVal = []
            if !@connections.nil?
                wordData = getWordData
                @connections.each_with_index do |connection, i|
                    retVal.push(JapaneseExample.new(@lines[connection], wordData[i], @sentences))
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
                wordData.push(findWord(@lines[connection]))
            end
            return wordData 
        end
    end

    class ChineseIndexFile < JLDrill::DataFile

        INDEX_RE = /^(\d*)[\t]cmn/

        def initialize(sentences)
            super()
            @sentences = sentences
            @file = "Chinese Indeces"
            @chineseIndeces = []
            @stepSize = 1000
        end

        # This isn't a real file, so we will overload the
        # readLines method to simply point to the main
        # sentences lines.
        def readLines
            @lines = @sentences.lines
            @parsed = 0
        end

        def parseEntry
            if INDEX_RE.match(@lines[@parsed])
                @chineseIndeces.push($1.to_i)
            end
            @parsed += 1
        end

        def dataSize
            @chineseIndeces.size
        end

        # Don't erase @lines because we need them later
        def finishParsing
            setLoaded(true)
        end

        def getConnections(kanji)
            return @chineseIndeces.collect do |index|
                @sentences.sentenceAt(index).match(kanji)
            end
        end
    end

    class JapaneseIndexFile < JLDrill::DataFile

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/

		def initialize()
            super
            @sentences = 0
            @usageMap = JLDrill::VocabularyUsage::Map.new
            @stepSize = 1000
		end

        def parseEntry
            if INDEX_RE.match(@lines[@parsed])
                @sentences += 1
                @usageMap.add_B_line($3, @parsed)
            end
            @parsed += 1
        end

        def dataSize
            @sentences
        end

        def search(kanji, reading, sentences)
            result = @usageMap.search(kanji, reading)
            return SearchResults.new(result.successfulHash, result.positions, 
                                     @lines, sentences).getSentences
        end

        # Don't erase @lines because we need them later
        def finishParsing
            setLoaded(true)
        end
    end

    # Represents the Tatoeba database
    class Database
        attr_reader :sentences, :japaneseIndeces, :chineseIndeces
    
        def initialize()
            @sentences = SentenceFile.new
            @japaneseIndeces = JapaneseIndexFile.new
            @chineseIndeces = nil
        end

        def createChineseIndeces()
            if @sentences.loaded?
                @chineseIndeces = ChineseIndexFile.new(@sentences)
            end
        end

        def loaded?()
            return @japaneseIndeces.loaded?
        end

        def search(kanji, reading)
            @japaneseIndeces.search(kanji, reading, @sentences)
        end
    end
end

