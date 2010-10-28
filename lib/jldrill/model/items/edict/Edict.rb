# -*- coding: utf-8 -*-
# Contains code necessary to read in an EDict file
# Also will parse hacked up JLPT Edict files

require "jldrill/model/Item"
require "jldrill/model/items/Vocabulary"
require "jldrill/model/items/edict/Meaning"
require 'jldrill/model/items/edict/ComparisonFunctors'
require 'jldrill/model/DataFile'
require 'Context/Publisher'
require 'Context/Log'
require 'kconv'

module JLDrill
    class Edict < DataFile

        LINE_RE_TEXT = '^([^\[\s]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT)
        READING_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?')
        KANA_RE = /（(.*)）/
        COMMENT_RE = /^\#/
            
        attr_reader :readings

        def initialize(file=nil)
            super()
            @readings = []
            @isUTF8 = nil
            if !file.nil?
                @file = file
            end
        end

        def reset
            @readings = []
            @isUTF8 = nil
            super()
        end

        def dataSize
            @readings.size
        end

        def setLoaded(bool)
            @publisher.update("edictLoad")
        end

        def vocab(index)
            if @lines.nil? || (index >= @lines.size)
                return nil
            else
                return parseLine(@lines[index], index)
            end
        end

        def eachVocab
            0.upto(length) do |i|
                yield(vocab(i))
            end
        end

        def length
            return @readings.size
        end

        def add(reading, position)
            @readings.push(reading)
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
            if !linesAreUTF8?
                NKF.nkf("-Ewxm0", line)
            else
                line
            end
        end
        
        def parseLine(line, position)
            retVal = nil
            line = toUTF8(line)
            if line =~ LINE_RE
                kanji = $1
                kana = $3
                english = JLDrill::Meaning.create($4)

                # Hack for JLPT files
                if kana =~ KANA_RE
                    kana = nil
                    hint = $1
                end

                if(kana == "" || kana == nil)
                    kana = kanji
                    kanji = nil
                end

                retVal = Vocabulary.new(kanji, kana, english.allDefinitions,
                                   english.allTypes, hint, position)
            else
                Context::Log::warning("JLDrill::Edict", 
                                      "Could not parse #{line}")
            end             
            return retVal                        
        end
        
        def parseReading(line)
            reading = nil
            line = toUTF8(line)
            if line =~ COMMENT_RE
                # Do nothing
            elsif line =~ READING_RE
                kanji = $1
                reading = $3

                # Hack for JLPT files
                if reading =~ KANA_RE || reading.nil? || reading.empty?
                    reading = kanji
                    kanji = nil
                end

            end
            return reading
        end

        def finishParsing
            setLoaded(true)
        end

        def parseEntry
            line = @lines[@parsed]
            add(parseReading(line), @parsed)
            @parsed += 1
        end

        def search(reading)
            result = []
            re = JLDrill::StartsWith.new(reading)
            0.upto(@readings.size - 1) do |i|
                candidate = @readings[i]
                if !candidate.nil?
                    if re.match(candidate)
                        result.push(Item.create(vocab(i).to_s))
                    end
                end
            end
            return result
        end

        def include?(vocab)
            return search(vocab.reading).any? do |item|
                item.to_o.eql?(vocab)
            end
        end

        def to_s()
            retVal = ""
            eachVocab do |word|
                retVal += word.to_s + "\n"
            end
            return retVal
        end
    end
end
