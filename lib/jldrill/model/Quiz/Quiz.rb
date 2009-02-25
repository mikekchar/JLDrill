require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/items/edict/Edict'
require 'jldrill/model/Problem'
require 'jldrill/model/Quiz/Options'
require 'jldrill/model/Contents'
require 'jldrill/model/Quiz/Strategy'
require 'Context/Publisher'
require 'jldrill/Version'

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
            @publisher = Context::Publisher.new(self)
            
            @last = nil
        end
        
        def length
            @contents.length
        end
        
        def size
            length
        end
        
        def bin
            retVal = nil
            if !@currentProblem.nil?
                retVal = @currentProblem.item.bin
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
            if !currentProblem.nil? && !currentProblem.valid?
                # The current problem has been edited and can't be displayed
                # like it is (i.e., A Kanji problem has had it's kanji removed)
                # Recreate it.  
                recreateProblem
            else
                # When the problem is modified, it means that the item
                # was also updated.  So we need to flag that a save is needed.
                setNeedsSave(true)
                @publisher.update("problemModified")
            end
        end

        def setNeedsSave(bool)
            @needsSave = bool
            update
        end
        
        def needsSave?
            @needsSave
        end

        def fileHeader
            JLDrill::VERSION + "-LDRILL-SAVE #{@name}\n"
        end
        
        def saveToString
            retVal = fileHeader
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

        def Quiz.canLoad?(header)
            retVal = false
            if(header =~ /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE/)
                if($1 != "")
                    if $1 =~ /^(\d+)\.(\d+)\.(\d+)/
                        if $1.to_i > 0 || $2.to_i < 4
                            retVal = true
                        end
                    end
                end
            end
            return retVal
        end

        def Quiz.drillFile?(file)
            retVal = false
            loadFile = File.new(file, "r")
            if(loadFile)
                retVal = Quiz.canLoad?(loadFile.readline)
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

        def parse(name, lines)
            setup
            
            @savename = name
            
            # Don't update the status while we're loading the file
            @publisher.block
            lines.each do |line|
                parseLine(line)
            end
            # Update status again
            @publisher.unblock
            
            setNeedsSave(true)
            @contents.length > 0
        end

        def load(file)
            parse(file, IO.readlines(file))
        end

        def loadFromString(name, string)
            parse(name, string.split("\n"))
        end

        def loadFromDict(dict)
            if dict
                # Don't update the status while we're loading the file
                @publisher.block
                setup
                @name = dict.shortFilename
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
            item = Item.new(vocab)
            @contents.addUniquely(item)
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

        # Get an array containing all the items in the quiz
        def allItems
            @contents.allItems
        end

        # Resets the quiz back to it's original state
        def reset
            @contents.reset()
            drill()
        end
  
        def incorrect
            item = @currentProblem.item
            if !item.nil?
                @strategy.incorrect(item)
                setNeedsSave(true)
            end
        end
        
        def correct
            item = @currentProblem.item
            if !item.nil?
                @strategy.correct(item)
                setNeedsSave(true)
            end
        end

        def createProblem(item)
            @currentProblem = @strategy.createProblem(item)
            update
            updateNewProblem
        end
        
        def recreateProblem
            createProblem(@currentProblem.item) unless @currentProblem.nil?
        end

        def drill()
            item = @strategy.getItem
            createProblem(item)
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
