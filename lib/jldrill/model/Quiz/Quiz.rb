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
require 'jldrill/model/Edict/Edict'
require 'jldrill/model/Problem'
require 'jldrill/model/Quiz/Options'
require 'jldrill/model/Quiz/Contents'
require 'jldrill/model/Quiz/Strategy'
require 'jldrill/model/Publisher'

module JLDrill
    class Quiz
        attr_reader :savename,  
                    :needsSave, :info, :name, 
                    :contents, :options, :currentProblem,
                    :strategy, :publisher
        attr_writer :savename, :info, :name, :currentProblem

        def initialize()
            @needsSave = false
            @name = ""
            @savename = ""
            @info = ""
            @options = Options.new(self)
            @contents = Contents.new(self)
            @strategy = Strategy.new(self)            
            @currentProblem = nil
            @publisher = Publisher.new(self)
            
            @last = nil
        end
        
        def length
            @contents.length
        end
        
        def size
            length
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

        def subscribe(subscriber)
            @publisher.subscribe(subscriber, "quiz")
        end

        def update
            @publisher.update("quiz")
        end
        
        def updateNewProblem
            @publisher.update("newProblem")
        end
        
        def problemModified
            @publisher.update("problemModified")
        end

        def setNeedsSave(bool)
            @needsSave = bool
            update
        end
        
        def needsSave?
            @needsSave
        end
        
        def saveToString
            retVal = ""
            retVal += "0.2.0-LDRILL-SAVE #{@name}\n"
            @info.split("\n").each { |line|
                retVal += "# " + line + "\n"
            }
            retVal += @options.to_s
            retVal += @contents.to_s
            retVal
        end

        def save
            retVal = true
            if (@savename != "") && (contents.length != 0) && @needsSave
                begin
                    saveFile = File.new(@savename, "w")
                rescue
                    return false
                end
                if saveFile
                    saveFile.print(saveToString)
                    saveFile.close
                    setNeedsSave(false)
                    retVal = true
                end
            end
            return retVal
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

        def setup
            # Save the publisher so that we continue to get updates
            publisher = @publisher
            initialize()
            @publisher = publisher
        end

        def load(file)
            retVal = false

            # Don't update the status while we're loading the file
            @publisher.block
            if file != ""
                setup
                @savename = file
                IO.foreach(file) do |line|
                    parseLine(line)
                end
                retVal = @contents.length > 0
            end
            # Update status again
            @publisher.unblock
            setNeedsSave(false)
            return retVal
        end

        def loadFromString(name, string)
            setup
            
            @savename = name
            
            # Don't update the status while we're loading the file
            @publisher.block
            string.each_line do |line|
                parseLine(line)
            end
            # Update status again
            @publisher.unblock
            
            setNeedsSave(true)
            @contents.length > 0
        end

        def loadFromDict(dict)
            if dict
                # Don't update the status while we're loading the file
                @publisher.block
                setup
                @name = dict.shortFile
                dict.eachVocab do |vocab|
                    contents.add(vocab, 0)
                end
                # Update status again
                @publisher.unblock
                setNeedsSave(true)
            end
        end    
        
        # Append any new items in the quiz to this quiz
        # Note: Does not add items that are already existing.
        #       nor does it update the status of existing items
        def append(quiz)
            # Don't update the status while we're appending the file
            @publisher.block
            @contents.addContents(quiz.contents)
            # Update status again
            @publisher.unblock
            update
        end
        
        def appendVocab(vocab)
            @contents.addUniquely(vocab)
        end

        def status
            retVal = ""
            if(@needsSave) then retVal += "* " else retVal += "  " end
            retVal += @contents.status + " "
            if !@currentProblem.nil?
                retVal += @currentProblem.status + " "
            end
            retVal += @strategy.status
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
  
        def incorrect
            @strategy.incorrect
        end
        
        def correct
            @strategy.correct
        end

        def drill()
            vocab = @strategy.getVocab
            @currentProblem = @strategy.createProblem(vocab)
            update
            updateNewProblem
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
