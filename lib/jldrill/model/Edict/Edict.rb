#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005  Mike Charlton
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

# Contains code necessary to read in an EDict file
# Also will parse hacked up JLPT Edict files

require "jldrill/model/Vocabulary"
require "jldrill/model/Edict/Meaning"

module JLDrill
    class Edict

        LINE_RE = /^([^\[]*)\s+(\[(.*)\]\s+)?\/(([^\/]*\/)+)\s*$/
        KANA_RE = /（(.*)）/
        COMMENT_RE = /^\#/
            
            attr_reader :lines, :index, :loaded

        def initialize(file=nil)
            @file = file
            @vocab = []
            @lines = nil
            @index = 0
            @loaded = false
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

        def parse(line, position)
            retVal = false
            # Replace commas with the Japanese comma as a workaround for
            # the bug where it becomes a separator.
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
