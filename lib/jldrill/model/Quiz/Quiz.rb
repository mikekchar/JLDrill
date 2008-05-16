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

module JLDrill
    class Quiz
        attr_reader :savename,  
                    :updated, :length, :info, :name, 
                    :contents, :options, :currentProblem
        attr_writer :savename, :updated, :info, :name, :currentProblem

        def initialize()
            @updated = false
            @name = ""
            @savename = ""
            @info = ""
            @options = Options.new(self)
            @contents = Contents.new(self)            
            @currentProblem = nil
            
            @last = nil

            @oldCorrect = 0
            @oldIncorrect = 0
            @lastEstimate = 0
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
            retVal += "Known: #{@lastEstimate}%" + " "
            retVal += "- " + @options.status
            return retVal
        end

        def to_s
            status
        end

        def reEstimate
            if @oldIncorrect == 0
                if @oldCorrect == 0
                    # Always review old items at the start
                    inst = 0
                else
                    inst = 100
                end
            else
                total = @oldCorrect + @oldIncorrect
                inst = ((@oldCorrect * 100) / total).to_i
            end
            hop = ((inst - @lastEstimate) * 0.3).to_i
            retVal = @lastEstimate + hop
            if (retVal > 100) then retVal = 100 end
            if (retVal < 0) then retVal = 0 end
            @lastEstimate = retVal
        end
        
        def underIntroThresh
            (@contents.bins[1].length + @contents.bins[2].length) < @options.introThresh
        end
  
        def underReviewThresh
            @lastEstimate < @options.oldThresh
        end
        
        def randomBin(from, to)
            if from >= to
                return to
            elsif (@contents.bins[from].length == 0) || (rand(2) == 0)
                return randomBin(from + 1, to)
            else
                return from
            end
        end
        
        def getBin
            retVal = 0
            if (@contents.bins[4].length == @contents.length)
                retVal = 4
            elsif (@contents.bins[0].length == 0)
                if underIntroThresh && underReviewThresh && 
                    (@contents.bins[4].length > 5)
                    retVal = 4
                else
                    retVal = randomBin(1, 3)
                end
            else
                if underIntroThresh
                    if underReviewThresh && (@contents.bins[4].length > 5)
                        retVal = 4
                    else
                        if @contents.bins[4].length > 5
                            if rand(10) > 8
                                retVal = 4
                            else
                                retVal = 0
                            end
                        else
                            retVal = 0
                        end
                    end
                else
                    retVal = randomBin(1, 3)
                end
            end
            retVal
        end

        def getVocab
            if(@contents.length == 0)
                return nil
            end

            deadThresh = 10
            bin = getBin
            until (@contents.bins[bin].length > 0) || (deadThresh == 0)
                bin = getBin
                deadThresh -= 1
            end
            if (deadThresh == 0)
                print "Warning: Deadlock broken in getVocab\n"
                print status + "\n"
            end

            if((!@options.randomOrder) && (bin == 0)) || (bin == 4)
                index = 0
            else
                index = rand(@contents.bins[bin].length)
            end

            vocab = @contents.bins[bin][index] 
            if bin == 0 then promote(vocab) end
            return vocab
        end

        def getUniqueVocab
            if(@contents.length == 0)
                return
            end

            vocab = getVocab
            deadThresh = 10
            if(@contents.length > 1)
                # Don't show the same item twice in a row
                until (vocab != @last) || (deadThresh == 0)
                    vocab = getVocab
                    deadThresh -= 1 
                end
                if (deadThresh == 0)
                    print "Warning: Deadlock broken in getUniqueVocab\n"
                    print status + "\n"
                end
            end
            @last = vocab
            vocab
        end

        # Get an array containing all the vocabulary in the quiz
        def allVocab
            @contents.all
        end

        # Resets the quiz back to it's original state
        def reset
            @contents.reset
        end

        # Move the specified vocab to the specified bin
        def moveToBin(vocab, bin)
            @contents.moveToBin(vocab, bin)
        end

        def promote(vocab)
            if !vocab.nil? && (vocab.status.bin + 1 < @contents.bins.length) 
                if vocab.status.bin != 2 || vocab.status.level == 2
                    moveToBin(vocab, vocab.status.bin + 1)
                else
                    if !vocab.kanji.nil?
                        vocab.status.level += 1
                    else
                        vocab.status.level = 2
                    end
                end
            end
        end

        def demote(vocab, level=0)
            if vocab
                # Reset the level and bin to the one that
                # the user failed on.
 
                vocab.status.level = level
                if level == 0
                    moveToBin(vocab, 1)
                else
                    moveToBin(vocab, 2)
                end
            end
        end
  
        def adjustQuizOld(good)
            if(@currentProblem.vocab.status.bin == 4)
                if good
                    @oldCorrect += 1
                else
                    @oldIncorrect += 1
                end
                reEstimate
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
                    promote(vocab)
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
                demote(@currentProblem.vocab, @currentProblem.level)
                vocab.status.consecutive = 0
                @updated = true
            end
        end

        def drill()
            vocab = getUniqueVocab
    
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