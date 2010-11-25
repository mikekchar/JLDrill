# -*- coding: utf-8 -*-

require 'jldrill/model/items/JWord'
require 'jldrill/model/DataFile'
require 'kconv'

module JLDrill

    # A JEDictionary is a Japanese to English Dictionary.
    # It is composed of an array of entries from an EDict
    # dictionary. These entries are parsed to create JWords.
    # The JWords can then further parse the entries to
    # create Meanings.
	class JEDictionary < DataFile
        GET_JWORD_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?')
        KANA_RE = /（(.*)）/

        def initialize
            super
        end

        def reset
            @jWords = []
            @readingHash = {}
            @kanjiHash = {}
            @isUTF8 = nil
            super
        end

        def dataSize
            return @jWords.size
        end

        def isUTF8?(index)
            !Kconv.isutf8(@lines[index]).nil?
        end

        def isEUC?(index)
            !Kconv.iseuc(@lines[index]).nil?
        end

        # returns true if the lines are UTF8
        def linesAreUTF8?
            if @isUTF8.nil?
                if @lines.nil?
                    return true
                    # There are no lines so assume we don't need to
                    # convert.  This is for the benefit of a few tests.
                end
                index = 0
                while (index < @lines.size) && @isUTF8.nil?
                    utf = isUTF8?(index)
                    euc = isEUC?(index)
                    if !utf && !euc
                        @isUTF8 = false
                        # It's neither UTF8 nor EUC.  We'll have to hope
                        # that conversion works. exit loop.
                    elsif utf && !euc
                        @isUTF8 = true
                        # it is UTF8. exit loop.
                    elsif euc && !utf
                        @isUTF8 = false
                        # it is EUC. exit loop.
                    else
                        # can't tell yet.  Keep going
                        index += 1
                    end
                end
                if @isUTF8.nil?
                    @isUTF8 = true
                    # We got to the bottom and determined that UTF8
                    # will work.  So use it.
                end
            end
            return @isUTF8
        end

        # returns the line as UTF8
        def toUTF8(line)
            NKF.nkf("-Ewxm0", line)
        end

        def linesToUTF8
            if !linesAreUTF8?
                0.upto(lines.size - 1) do |i|
                    lines[i] = toUTF8(lines[i])
                end
            end
        end

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

        def hashWord(word)
            # UTF8 kanji and kana characters are usually 3 bytes each.
            # We will hash on the first two characters.
            (@readingHash[word.reading[0..5]] ||= []).push(word)
            (@kanjiHash[word.kanji[0..5]] ||= []).push(word)
        end

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

        def finishParsing
            # Don't reset the lines because we need them later
            setLoaded(true)
        end

        def readingsStartingWith(reading)
            if reading.size >= 6
                bin = (@readingHash[reading[0..5]] ||= []).find_all do |word|
                        word.reading.start_with?(reading)
                end
            else
                keys = @readingHash.keys.find_all do |key|
                    key.start_with?(reading)
                end
                bin = []
                keys.each do |key|
                    bin += @readingHash[key]
                end
            end
            return bin.sort do |x, y|
                x.reading.size <=> y.reading.size
            end
        end
    end
end
