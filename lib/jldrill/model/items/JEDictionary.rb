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
        LINE_RE_TEXT = '^([^\[\s]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT)
        GET_JWORD_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?')
        KANA_RE = /（(.*)）/

        def initialize
            super
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

        # Returns true if the line at the given index is UTF8
        def isUTF8?(index)
            !Kconv.isutf8(@lines[index]).nil?
        end

        # Returns true if the line at the given index is EUC 
        def isEUC?(index)
            !Kconv.iseuc(@lines[index]).nil?
        end

        # returns true if the lines are UTF8
        def linesAreUTF8?
            isUTF8 = nil
            index = 0
            while (index < @lines.size) && isUTF8.nil?
                utf = isUTF8?(index)
                euc = isEUC?(index)
                if !utf && !euc
                    isUTF8 = false
                    # It's neither UTF8 nor EUC.  We'll have to hope
                    # that conversion works. exit loop.
                elsif utf && !euc
                    isUTF8 = true
                    # it is UTF8. exit loop.
                elsif euc && !utf
                    isUTF8 = false
                    # it is EUC. exit loop.
                else
                    # can't tell yet.  Keep going
                    index += 1
                end
            end
            if isUTF8.nil?
                isUTF8 = true
                # We got to the bottom and determined that UTF8
                # will work.  So use it.
            end
            return isUTF8
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
                Context::Log::warning("JLDrill::Edict", 
                                      "Could not parse #{position}")
            end             
            return retVal                        
        end

        # returns the line as UTF8
        def toUTF8(line)
            NKF.nkf("-Ewxm0", line)
        end

        # Transforms all the lines to UTF8
        def linesToUTF8
            if !linesAreUTF8?
                0.upto(lines.size - 1) do |i|
                    lines[i] = toUTF8(lines[i])
                end
            end
        end

        # Read all the lines into the buffer.
        # This method also converts them the UTF8
        def readLines
            super
            linesToUTF8
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

        # Create the indeces for the item at the current line.
        def parseEntry
            if lines[@parsed] =~ GET_JWORD_RE
                word = JWord.new
                word.kanji = $1
                word.reading = $3
                word.dictionary = self
                word.position = @parsed
                @jWords[@jWords.size] = word
                word = hackWord(word)
                hashWord(word)
            end
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

        # Return all the JWords that have a reading starting with reading.
        def findReadingsStartingWith(reading)
            return findBinWithReading(reading).find_all do |word|
                word.reading.start_with?(reading)
            end
        end

        # Return all the JWords that have the reading, reading.
        def findReading(reading)
            return findBinWithReading(reading).find_all do |word|
                word.reading.eql?(reading)
            end
        end

        # Return true if the dictionary contains this vocabulary.
        def include?(vocabulary)
            return findReading(vocabulary.reading).any? do |word|
                word.toVocab.eql?(vocabulary)
            end
        end
    end
end
