# encoding: utf-8

require 'jldrill/model/items/JWord'
require 'jldrill/model/DataFile'
require "jldrill/model/items/Vocabulary"
require "jldrill/model/items/edict/Meaning"
require 'Context/Log'
require 'kconv'

module JLDrill

    # A Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create JWords.
    # The JWords can then further parse the entries to
    # create Meanings.
	class Dictionary < DataFile
        attr_reader :jWords

        def initialize
            super
            @stepSize = 1000
        end

        # Ruby 1.8 and 1.9 use different counting mechanisms for the size
        # of strings.  hashSize must return the size of the character that
        # you want to hash on.  This implementation is an example.  You
        # should override it in the concrete Dictionary class.
        def hashSize
            return "雨".size
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

        # Return the meaning for the word at the position in the file.
        # The concrete implementation should override this method.
        def getMeaning(position)
            return ""
        end

        # Parse the line at the given position and return the a Vocabulary
        # containing the information (this is deprecated).
        # It should be overridden in the concrete Dictionary
        def getVocab(position)
            return nil                        
        end

        # Read all the lines into the buffer.
        def readLines
            super
        end

        # Has the word in both the reading and kanji hashes so that
        # we can find them quickly.
        def hashWord(word)
            # We will hash on the first character.
            (@readingHash[word.reading[0..hashSize - 1]] ||= []).push(word)
            (@kanjiHash[word.kanji[0..hashSize - 1]] ||= []).push(word)
        end

        # Parse a line in the dictionary and create JWord
        # This method must be overridden in the concrete dictionary
        def getJWord(index)
            return nil
        end

        def parseLine(index)
            word = getJWord(index)
            if !word.nil?
                word.dictionary = self
                word.position = index
                @jWords[@jWords.size] = word
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
            if reading.size >= hashSize
                bin = (@readingHash[reading[0..hashSize - 1]] ||= [])
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
            if kanji.size >= hashSize
                bin = (@kanjiHash[kanji[0..hashSize - 1]] ||= [])
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
            if reading.size > hashSize 
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
            if kanji.size > hashSize 
                return bin.find_all do |word|
                    word.kanji.start_with?(kanji)
                end
            else
                return bin
            end
        end

        # Return all the JWords that have the reading, reading.
        def findReading(reading)
            relevance = reading.size
            return findBinWithReading(reading).find_all do |word|
                if word.reading.eql?(reading)
                    word.relevance = relevance
                    true
                else
                    false
                end
            end
        end

        # Return all the JWords that have the kanji, kanji.
        def findKanji(kanji)
            relevance = kanji.size
            return findBinWithKanji(kanji).find_all do |word|
                if word.kanji.eql?(kanji)
                    word.relevance = relevance
                    true
                else
                    false
                end
            end
        end

        def findWord(string)
            kanji = findKanji(string)
            reading = findReading(string)
            return kanji + reading
        end

        # Return true if the dictionary contains this vocabulary.
        def include?(vocabulary)
            if vocabulary.reading.nil?
                return false
            end
            return findReading(vocabulary.reading).any? do |word|
                word.toVocab.eql?(vocabulary)
            end
        end

        # Return all the words that occur at the begining of reading
        def findReadingsThatStart(reading)
            findBinWithReading(reading[0..hashSize - 1]).find_all do |word|
                relevance = word.reading.size
                if reading.start_with?(word.reading)
                    word.relevance = relevance
                    true
                else
                    false
                end
            end
        end

        # Return all the words that occur at the begining of kanji
        def findKanjiThatStart(kanji)
            findBinWithKanji(kanji[0..hashSize - 1]).find_all do |word|
                relevance = word.kanji.size
                if kanji.start_with?(word.kanji)
                    word.relevance = relevance
                    true
                else
                    false
                end
            end
        end

        # Return all the words that occur at the begining of the string
        # These are sorted by size with the largest finds given first
        def findWordsThatStart(string)
            kanji = findKanjiThatStart(string)
            reading = findReadingsThatStart(string)
            return kanji + reading
        end
    end
end

