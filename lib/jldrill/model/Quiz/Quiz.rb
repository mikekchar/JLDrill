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


require 'jldrill/model/Vocabulary'
require 'jldrill/model/Edict'
require 'jldrill/model/Problem'
require 'jldrill/model/Quiz/Options'
require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Quiz/Strategy'

module JLDrill
    class Quiz
        attr_reader :savename,  
                    :updated, :length, :info, :name, 
                    :contents, :options, :currentProblem,
                    :strategy
        attr_writer :savename, :updated, :info, :name, :currentProblem

        def initialize()
            @updated = false
            @name = ""
            @savename = ""
            @info = ""
            @options = Options.new(self)
            @contents = Contents.new(self)
            @strategy = Strategy.new(self)            
            @currentProblem = nil
            
            @last = nil
        end

        def vocab
            retVal = nil
            if !@currentProblem.nil?
                retVal = @currentProblem.vocab
            end
            retVal
        end

        def bin
            retVal = nil
            if !@currentProblem.nil?
                retVal = @currentProblem.vocab.status.bin
            end
            retVal
        end

        def update
            @updated = true
        end

        def saveToString
            retVal = ""
            retVal += "0.2.0-LDRILL-SAVE #{@name}\n"
            @info.split("\n").each { |line|
                retVal += "# " + line + "\n"
            }
            retVal += @options.to_s
            retVal += @contents.to_s
            @updated = false
            retVal
        end

        def save
            retVal = false
            if (@savename != "") && (contents.length != 0) && @updated
                saveFile = File.new(@savename, "w")
                if saveFile
                    saveFile.print(saveToString)
                    saveFile.close
                    retVal = true
                end
            end
            return retVal
        end
        
        def export(filename)
            saveFile = File.new(filename, "w")
            if saveFile
                @contents.bins[4].each { |word|
                    saveFile.print(word.to_tsv + "\n")
                }
                saveFile.close()
            end
        end

        def Quiz.drillFile?(file)
            retVal = false
            loadFile = File.new(file, "r")
            if(loadFile)
                if(loadFile.readline =~ /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE/)
                    retVal = true
                    if($1 != "")
                        if $1 =~ /^(\d+)\.(\d+)\.(\d+)/
                            if $1.to_i != 0 || $2.to_i > 2
                                retVal = false
                            end
                        end
                    end
                end
            end
            return retVal
        end

        def parseLine(line)
            if !@options.parseLine(line)
                if !@contents.parseLine(line)
                    case line
                        when /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE (.*)/ then @name = $2
                        when /^\#[ ]?(.*)/ then @info += $1 + "\n"
                        else # ignore stuff we don't understand
                    end
                end
            end
        end

        def load(file)
            retVal = false

            if file != ""
                initialize()
                @savename = file
                IO.foreach(file) do |line|
                    parseLine(line)
                end
                retVal = @contents.length > 0
            end
            return retVal
        end

        def loadFromString(name, string)
            initialize()
            
            @savename = name
            
            string.each_line do |line|
                parseLine(line)
            end
            
            @contents.length > 0
        end

        def loadFromDict(dict)
            if dict
                initialize()
                @name = dict.shortFile
                dict.eachVocab do |vocab|
                    contents.add(vocab, 0)
                end
            end
        end    

        def status
            retVal = ""
            if(@updated) then retVal += "* " else retVal += "  " end
            retVal += @name + ": "
            retVal += @contents.status + " "
            if !@currentProblem.nil?
                retVal += @currentProblem.status + " "
            end
            retVal += @strategy.status + " "
            retVal += "- " + @options.status
            return retVal
        end

        def to_s
            status
        end

        # Get an array containing all the vocabulary in the quiz
        def allVocab
            @contents.all
        end

        # Resets the quiz back to it's original state
        def reset
            @contents.reset
        end
  
        def adjustQuizOld(good)
            if(@currentProblem.vocab.status.bin == 4)
                if(good)
                    @strategy.correct
                else
                    @strategy.incorrect
                end
            end
        end
  
        def correct
            vocab = @currentProblem.vocab
            adjustQuizOld(true)
            if(vocab)
                vocab.status.schedule
                vocab.status.markReviewed
                vocab.status.score += 1
                if(vocab.status.score >= @options.promoteThresh)
                    @strategy.promote(vocab)
                end
                if vocab.status.bin == 4
                    vocab.status.consecutive += 1
                    @contents.bins[4].sort! do |x, y|
                        x.status.scheduledTime <=> y.status.scheduledTime
                    end
                end
                @updated = true
            end
        end

        def incorrect
            adjustQuizOld(false)
            if(@currentProblem.vocab)
                vocab.status.unschedule
                vocab.status.markReviewed
                @strategy.demote(@currentProblem.vocab, @currentProblem.level)
                vocab.status.consecutive = 0
                @updated = true
            end
        end

        def drill()
            vocab = @strategy.getUniqueVocab
    
            # Kind of screwy logic...  In the "fair" bin, only drill
            # at the current level.  At other levels, drill at a random levels
            # this enforces introduction of the material in the "fair" bin.

            if vocab.status.bin == 2 || vocab.status.level == 0
                level = vocab.status.level
            elsif vocab.status.bin == 4
                # Don't drill reading in the excellent bin
                level = rand(2) + 1
            else
                if vocab.kanji == nil
                    # Don't try to drill kanji if there isn't any
                    level = rand(2)
                else
                    level = rand(vocab.status.level + 1)
                end
            end

            case level
                when 0
                    @currentProblem = ReadingProblem.new(vocab)
                when 1
                    @currentProblem = MeaningProblem.new(vocab)
                when 2
                    if vocab.kanji
                        @currentProblem = KanjiProblem.new(vocab)
                    else
                        @currentProblem = ReadingProblem.new(vocab)
                    end
            end
            @currentProblem.requestedLevel = level

            return @currentProblem.question
        end

        def answer()
            @currentProblem.answer
        end

        def currentDrill
            @currentProblem.question
        end

        def currentAnswer
            @currentProblem.answer
        end
     
    end
end
