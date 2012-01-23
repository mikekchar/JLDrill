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

    # Represents an Example sentence in the Tatoeba database
    class TatoebaExample < JLDrill::ExampleSentence

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/

        def initialize(targetIndex, nativeIndex, key, sentences)
            @sentences = sentences
            
            @targetIndex = targetIndex
            @nativeIndex = nativeIndex
            @key = key
        end

        def nativeLanguage()
            return "#{@nativeIndex}: #{@sentences.sentenceAt(@nativeIndex)}"
        end

        def targetLanguage()
            return "#{@targetIndex}: #{@sentences.sentenceAt(@targetIndex)}"
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

        # Return an array of positions in the sentence file
        # that contain the given kanji
        def getPositions(kanji)
            return @chineseIndeces.find_all do |index|
                @sentences.sentenceAt(index).match(kanji)
            end
        end

        def search(kanji, reading)
            retVal = []
            positions = getPositions(kanji)
            positions.each do |index|
                usage = JLDrill::VocabularyUsage.from_B_line(kanji)
                retVal.push(TatoebaExample.new(index, 0, usage, @sentences))
            end
            return retVal
        end
    end

    class JapaneseIndexFile < JLDrill::DataFile

        INDEX_RE = /^(\d*)[\t](\d*)[\t](.*)/

        attr_reader :sentences

		def initialize(sentences)
            super()
            @sentences = sentences
            @numSentences = 0
            @usageMap = JLDrill::VocabularyUsage::Map.new
            @stepSize = 1000
		end

        def parseEntry
            if INDEX_RE.match(@lines[@parsed])
                @numSentences += 1
                @usageMap.add_B_line($3, @parsed)
            end
            @parsed += 1
        end

        def dataSize
            @numSentences
        end

        # Find the usage data that matches the usageHash in the
        # supplied B line.  If it doesn't exist, return empty string
        def findUsageData(usageHash, b_line)
            retVal = b_line.split(" ").find do |usageData|
                usageData.start_with?(usageHash)
            end
            if retVal.nil?
                retVal = ""
            end
            return retVal
        end

        def parseDataOnLine(pos)
            if INDEX_RE.match(@lines[pos])
                return $1.to_i, $2.to_i, $3
            else
                return 0, 0, ""
            end
        end

        def search(kanji, reading)
            retVal = []
            result = @usageMap.search(kanji, reading)
            result.positions.each do |position|
                jidx, eidx, b_line = parseDataOnLine(position)
                usageData = findUsageData(result.successfulHash, b_line)
                usage = JLDrill::VocabularyUsage.from_B_line(usageData)
                retVal.push(TatoebaExample.new(jidx, eidx, usage, @sentences))
            end
            return retVal
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
            @japaneseIndeces = JapaneseIndexFile.new(@sentences)
            @chineseIndeces = ChineseIndexFile.new(@sentences)
        end

        def indeces(options)
            if options.language.eql?("Chinese")
                return @chineseIndeces
            else
                return @japaneseIndeces
            end
        end

        def loaded?(options)
            return indeces(options).loaded?
        end

        def search(kanji, reading, options)
            indeces(options).search(kanji, reading)
        end
    end
end

