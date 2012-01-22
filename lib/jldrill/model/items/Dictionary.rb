# encoding: utf-8

require 'jldrill/model/items/DictionaryEntry'
require 'jldrill/model/DataFile'
require "jldrill/model/items/Vocabulary"
require "jldrill/model/items/edict/Meaning"
require 'Context/Log'
require 'kconv'

module JLDrill

    # A Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create DictionaryEntry.
    # The DictionaryEntry can then further parse the entries to
    # create Meanings.
	class Dictionary < DataFile
        attr_reader :dictEntries

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
            @dictEntries = []
            @readingHash = {}
            @kanjiHash = {}
            @simplifiedHash = {}
            super
        end

        # The number of items we have indexed in the dictionary.
        def dataSize
            return @dictEntries.size
        end

        def length
            return dataSize
        end

        # Return the meaning for the word at the position in the file.
        # The concrete implementation should override this method.
        def getMeaning(position)
            return ""
        end

        # Read all the lines into the buffer.
        def readLines
            super
        end

        # Hash the word in both the reading and kanji hashes so that
        # we can find them quickly.
        def hashWord(word)
            # We will hash on the first character.
            if !word.reading.empty?
                (@readingHash[word.reading[0..hashSize - 1]] ||= []).push(word)
            end
            if !word.kanji.empty?
                (@kanjiHash[word.kanji[0..hashSize - 1]] ||= []).push(word)
            end
            if !word.simplified.empty? && !word.kanji.eql?(word.simplified)
                (@simplifiedHash[word.simplified[0..hashSize - 1]] ||= []).push(word)
            end
        end

        def parseLine(index)
            word = getDictionaryEntry(index)
            if !word.nil?
                @dictEntries[@dictEntries.size] = word
                hashWord(word)
            end
            return word
        end

        def vocab(index)
            word = @dictEntries[index]
            if !word.nil?
                return word.toVocab
            else
                return nil
            end
        end

        def eachVocab(&block)
            @dictEntries.each do |word|
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

        # Find the items that may have been hashed with this simplified kanji.
        def findBinWithSimplified(kanji)
            if kanji.size >= hashSize
                bin = (@simplifiedHash[kanji[0..hashSize - 1]] ||= [])
            else
                keys = @simplifiedHash.keys.find_all do |key|
                    key.start_with?(kanji)
                end
                bin = []
                keys.each do |key|
                    bin += @simplifiedHash[key]
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
            if bin.empty?
                bin = findBinWithSimplified(kanji)
            end
            return bin
        end

        # Return all the DictionaryEntry that have a reading 
        # starting with reading.
        def findReadingsStartingWith(reading)
            bin = findBinWithReading(reading)
            if reading.size > hashSize 
                return bin.find_all do |word|
                    word.readingStartsWith?(reading)
                end
            else
                return bin
            end
        end

        # Return all the DictionaryEntry that have kanji starting with kanji.
        def findKanjiStartingWith(kanji)
            bin = findBinWithKanji(kanji)
            if kanji.size > hashSize 
                return bin.find_all do |word|
                    word.kanjiStartsWith?(kanji)
                end
            else
                return bin
            end
        end

        # Return all the DictionaryEntry that have the reading, reading.
        def findReading(reading)
            relevance = reading.size
            return findBinWithReading(reading).find_all do |word|
                if word.readingEql?(reading)
                    word.relevance = relevance
                    true
                else
                    false
                end
            end
        end

        # Return all the DictionaryEntry that have the kanji, kanji.
        def findKanji(kanji)
            relevance = kanji.size
            return findBinWithKanji(kanji).find_all do |word|
                if word.kanjiEql?(kanji)
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
                if word.keyStartsWithReading?(reading)
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
                if word.keyStartsWithKanji?(kanji)
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

