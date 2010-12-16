# -*- coding: utf-8 -*-

require 'jldrill/model/items/JWord'
require 'jldrill/model/DataFile'
require "jldrill/model/items/Vocabulary"
require "jldrill/model/items/edict/Meaning"
require 'Context/Log'
require 'kconv'

module JLDrill

    # A JEDictionary is a Japanese to English Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create JWords.
    # The JWords can then further parse the entries to
    # create Meanings.
	class JEDictionary < DataFile
        attr_reader :jWords

        LINE_RE_TEXT = '^([^\[\s]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT)
        GET_JWORD_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?')
        KANA_RE = /（(.*)）/
        FIRST_CHAR_RE = Regexp.new("^(.)", "U")

        def initialize
            super
            @stepSize = 1000
        end

        # Reset the dictionary back to empty
        def reset
            @jWords = []
            @readingHash = {}
            @kanjiHash = {}
            super
        end

        # The number of items we have indexed in the dictionary.
        def dataSize
            return @jWords.size
        end

        def length
            return dataSize
        end

        # Returns true if the line at the given index is UTF8
        def isUTF8?(index)
            !Kconv.isutf8(@lines[index]).nil?
        end

        # Parse the line at the given position and return the a Vocabulary
        # containing the information (this is deprecated).
        def getVocab(position)
            retVal = nil
            if lines[position] =~ LINE_RE
                kanji = $1
                reading = $3
                english = JLDrill::Meaning.create($4)
                
                # Hack for JLPT files
                if reading =~ KANA_RE
                    reading = nil
                    hint = $1
                end

                if(reading == "" || reading == nil)
                    reading = kanji
                    kanji = nil
                end

                retVal = Vocabulary.new(kanji, reading, english.allDefinitions,
                                   english.allTypes, hint, position)
            else
                Context::Log::warning("JLDrill::JEDictionary", 
                                      "Could not parse #{position}")
            end             
            return retVal                        
        end

        # modifies the line at position to be UTF8
        def toUTF8(position)
            lines[position] = NKF.nkf("-Ewxm0", lines[position])
        end

        # Read all the lines into the buffer.
        # This method also converts them the UTF8
        def readLines
            super
        end

        # Compensate for files that have missing kanji or
        # JLPT files which have a strange format.
        def hackWord(word)
            # Hack for JLPT files
            if word.reading =~ KANA_RE || word.reading.nil? ||
                    word.reading.empty?
                word.reading = word.kanji
                word.kanji = ""
            end
            if word.kanji.nil?
                word.kanji = ""
            end
            return word
        end

        # Has the word in both the reading and kanji hashes so that
        # we can find them quickly.
        def hashWord(word)
            # UTF8 kanji and kana characters are usually 3 bytes each.
            # We will hash on the first two characters.
            (@readingHash[word.reading[0..5]] ||= []).push(word)
            (@kanjiHash[word.kanji[0..5]] ||= []).push(word)
        end

        def parseLine(index)
            if !isUTF8?(index)
                toUTF8(index)
            end
            if lines[index] =~ GET_JWORD_RE
                word = JWord.new
                word.kanji = $1
                word.reading = $3
                word.dictionary = self
                word.position = index
                @jWords[@jWords.size] = word
                word = hackWord(word)
                hashWord(word)
            end
        end

        def vocab(index)
            word = @jWords[index]
            if !word.nil?
                return word.toVocab
            else
                return nil
            end
        end

        def eachVocab(&block)
            @jWords.each do |word|
                block.call(word.toVocab)
            end
        end

        # Create the indeces for the item at the current line.
        def parseEntry
            parseLine(@parsed)
            @parsed += 1
        end

        # This is what to do when we are finished parsing.
        def finishParsing
            # Don't reset the lines because we need them later
            setLoaded(true)
        end

        # Find the items that may have been hashed with this reading.
        def findBinWithReading(reading)
            if reading.size >= 6
                bin = (@readingHash[reading[0..5]] ||= [])
            else
                keys = @readingHash.keys.find_all do |key|
                    key.start_with?(reading)
                end
                bin = []
                keys.each do |key|
                    bin += @readingHash[key]
                end
            end
            return bin
        end

        # Find the items that may have been hashed with this kanji.
        def findBinWithKanji(kanji)
            if kanji.size >= 6
                bin = (@kanjiHash[kanji[0..5]] ||= [])
            else
                keys = @kanjiHash.keys.find_all do |key|
                    key.start_with?(kanji)
                end
                bin = []
                keys.each do |key|
                    bin += @kanjiHash[key]
                end
            end
            return bin
        end

        # Return all the JWords that have a reading starting with reading.
        def findReadingsStartingWith(reading)
            bin = findBinWithReading(reading)
            if reading.size > 6 
                return bin.find_all do |word|
                    word.reading.start_with?(reading)
                end
            else
                return bin
            end
        end

        # Return all the JWords that have kanji starting with kanji.
        def findKanjiStartingWith(kanji)
            bin = findBinWithKanji(kanji)
            if kanji.size > 6 
                return bin.find_all do |word|
                    word.kanji.start_with?(kanji)
                end
            else
                return bin
            end
        end

        # Return all the JWords that have the reading, reading.
        def findReading(reading)
            return findBinWithReading(reading).find_all do |word|
                word.reading.eql?(reading)
            end
        end

        # Return all the JWords that have the kanji, kanji.
        def findKanji(kanji)
            return findBinWithKanji(kanji).find_all do |word|
                word.kanji.eql?(kanji)
            end
        end

        def findWord(string)
            kanji = findKanji(string).sort do |x, y|
                y.kanji <=> x.kanji
            end
            reading = findReading(string).sort do |x, y|
                y.reading <=> x.reading
            end
            return kanji + reading
        end

        # Return true if the dictionary contains this vocabulary.
        def include?(vocabulary)
            return findReading(vocabulary.reading).any? do |word|
                word.toVocab.eql?(vocabulary)
            end
        end

        # Return all the words that occur at the begining of reading
        def findReadingsThatStart(reading)
            findBinWithReading(reading[0..2]).find_all do |word|
                reading.start_with?(word.reading)
            end
        end

        # Return all the words that occur at the begining of kanji
        def findKanjiThatStart(kanji)
            findBinWithKanji(kanji[0..2]).find_all do |word|
                kanji.start_with?(word.kanji)
            end
        end

        # Return all the words that occur at the begining of the string
        # These are sorted by size with the largest finds given first
        def findWordsThatStart(string)
            kanji = findKanjiThatStart(string).sort do |x, y|
                y.kanji <=> x.kanji
            end
            reading = findReadingsThatStart(string).sort do |x, y|
                y.reading <=> x.reading
            end
            return kanji + reading
        end
    end
end
