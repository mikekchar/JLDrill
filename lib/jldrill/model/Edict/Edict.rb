# Contains code necessary to read in an EDict file
# Also will parse hacked up JLPT Edict files

require "jldrill/model/Vocabulary"
require "jldrill/model/Edict/Meaning"
require 'kconv'

module JLDrill
    class Edict

        LINE_RE_TEXT = '^([^\[]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$'
        LINE_RE = Regexp.new(LINE_RE_TEXT)
        KANA_RE = /（(.*)）/
        COMMENT_RE = /^\#/
            
            attr_reader :lines, :index, :loaded
            attr_writer :lines

        def initialize(file=nil)
            @file = file
            @vocab = []
            @lines = nil
            @index = 0
            @loaded = false
            @isUTF8 = nil
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

        def eachVocab
            @vocab.each {|vocab|
                yield(vocab)
            }
        end

        def vocab(index)
            return @vocab[index]
        end

        def length
            return @vocab.length
        end

        def add(vocab)
            if vocab
                @vocab.push(vocab)
            end
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
            retVal = false
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

                add(Vocabulary.new(kanji, kana, english.allDefinitions,
                                   english.allTypes, hint, -1))
                retVal = true
            else
                print "Warning: Could not parse - #{line}\n"
            end             
            return retVal                        
        end
        
        def readLines()
            @lines = IO.readlines(@file)
            @index = 0
            @vocab = []
        end

        def parseChunk(chunkSize)
            if @loaded then return true end
            
            if (@index + chunkSize) >= @lines.size
                chunkSize = @lines.size - @index
                @loaded = true
            end

            0.upto(chunkSize - 1) do
                line = @lines[@index]
                parse(line, @index) unless line =~ COMMENT_RE
                @index += 1
            end
            
            @lines = [] if @loaded
            
            return @loaded
        end
        
        def fraction
            retVal = @index.to_f / @lines.size.to_f
            retVal
        end

        def read(&progress)
            if(@file.nil?) then return false end
            i = 0
            size = File.size(@file).to_f
            total = 0.to_f
            report = 0
            IO.foreach(@file) { |line|
                # Only report every 1000 lines because it's expensive  
                total += line.length.to_f
                if progress && (report == 1000)
                    report = 0
                    progress.call(total / size)
                end
                report += 1
                unless line =~ COMMENT_RE
                    if parse(line, i)
                        i += 1
                    end
                end
            }
            @loaded = true
            self
        end

        def shortFile
            pos = @file.rindex('/')
            if(pos)
                return @file[(pos+1)..(@file.length-1)]
            else
                return @file
            end
        end

        def include?(vocab)
            if(!@vocab.nil?)
                return @vocab.include?(vocab)
            else
                return false
            end
        end

        def search(reading)
            result = []
            if @vocab
                @vocab.each { |vocab|
                    if vocab.reading
                        re = Regexp.new("^#{reading}")
                        if re.match(vocab.reading)
                            result.push(vocab)
                        end
                    end
                }
            end
            return result
        end

        def to_s()
            retVal = ""
            @vocab.each { |word|
                retVal += word.to_s + "\n"
            }
            return retVal
        end
    end
end
