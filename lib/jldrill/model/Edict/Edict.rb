# Contains code necessary to read in an EDict file
# Also will parse hacked up JLPT Edict files

require "jldrill/model/Vocabulary"
require "jldrill/model/Edict/Meaning"
require 'jldrill/model/Publisher'
require 'kconv'

module JLDrill
    class Edict

        LINE_RE_TEXT = '^([^\[\s]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT)
        READING_RE = Regexp.new('^([^\[\s]*)\s+(\[(.*)\]\s+)?')
        KANA_RE = /（(.*)）/
        COMMENT_RE = /^\#/
            
            attr_reader :lines, :numLinesParsed, :loaded, :readings, :publisher
            attr_writer :lines

        def initialize(file=nil)
            @file = file
            @readings = []
            @lines = nil
            @numLinesParsed = 0
            @numReadingsAdded = 0
            @loaded = false
            @isUTF8 = nil
            @publisher = Publisher.new(self)
        end

        def file=(filename)
            @file = filename
        end
        
        def file
            @file
        end

        def loaded?
            @loaded
        end

        def setLoaded(bool)
            @loaded = bool
            @publisher.update("edictLoad")
        end

        def vocab(index)
            if @lines.nil? || (index >= @lines.size)
                return nil
            else
                return parse(@lines[index], index)
            end
        end

        def eachVocab
            0.upto(length) do |i|
                yield(vocab(i))
            end
        end

        def length
            return @numReadingsAdded
        end

        def add(reading, position)
            @readings.push(reading)
            @numReadingsAdded += 1
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
        
        def parse(line, position)
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
                print "Warning: Could not parse - #{line}\n"
            end             
            return retVal                        
        end
        
        def readLines()
            setLoaded(false)
            @lines = IO.readlines(@file)
            @numLinesParsed = 0
            @numReadingsAdded = 0
            @readings = []
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

        def parseNextLine
            line = @lines[@numLinesParsed]
            add(parseReading(line), @numLinesParsed)
            @numLinesParsed += 1
        end

        def parseChunk(chunkSize)
            if loaded? 
                return true 
            end
            
            if (@numLinesParsed + chunkSize) >= @lines.size
                chunkSize = @lines.size - @numLinesParsed
                setLoaded(true)
            end

            0.upto(chunkSize - 1) do
                parseNextLine()
            end
            
            return loaded?
        end

        def parseLines
            parseChunk(@lines.size)
        end

        # Reads in the whole file at once
        def read
            readLines()
            parseLines()
        end
        
        def fraction
            if loaded?
                1.0
            else
                @numLinesParsed.to_f / @lines.size.to_f
            end
        end

        def shortFilename
            if @file.nil? || @file.empty?
                return "No name"
            end
            pos = @file.rindex('/')
            if(pos)
                return @file[(pos+1)..(@file.length-1)]
            else
                return @file
            end
        end

        def search(reading)
            result = []
            re = Regexp.new("^#{reading}")
            0.upto(@readings.size - 1) do |i|
                candidate = @readings[i]
                if !candidate.nil?
                    if re.match(candidate)
                        result.push(vocab(i))
                    end
                end
            end
            return result
        end

        def include?(vocab)
            return search(vocab.reading).include?(vocab)
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
