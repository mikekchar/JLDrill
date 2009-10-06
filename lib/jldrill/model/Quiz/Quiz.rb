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

        JLDRILL_HEADER_RE = /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE (.*)/
        COMMENT_RE = /^\#[ ]?(.*)/
        VERSION_RE = /^(\d+)\.(\d+)\.(\d+)/
        JLDRILL_CANLOAD_RE = /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE/

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

        def unsubscribe(subscriber)
            @publisher.unsubscribe(subscriber, "quiz")
        end

        def update
            @publisher.update("quiz")
        end

        def updateLoad
            @publisher.update("load")
        end

        def updateItemDeleted(item)
            @publisher.update("itemDeleted", item)
        end

        def updateItemAdded(item)
            @publisher.update("itemAdded", item)
        end
        
        def updateNewProblem(problem)
            @publisher.update("newProblem", problem)
        end
        
        def problemModified(problem)
            @publisher.update("problemModified", problem)
            setNeedsSave(true)
            if !problem.valid? &&
                    !@currentProblem.nil? && (problem == @currentProblem)
                # The current problem has been edited and can't be displayed
                # like it is (i.e., A Kanji problem has had it's kanji removed)
                # Recreate it.  
                recreateProblem
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
            if header =~ JLDRILL_CANLOAD_RE
                if $1 != ""
                    if $1 =~ VERSION_RE
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
            # These are put in a specific order for performance
            # By checking the most common items first we avoid doing
            # needless regular expression checks.  It's not a huge
            # savings, but it helps for very big files.
            # Normal contents are the most common
            if !@contents.parseLine(line)
                # Quiz options are the next most common
                if !@options.parseLine(line)
                    # Comments, headers and unparsable lines are 
                    # the least common
                    case line
                    when JLDRILL_HEADER_RE
                        @name = $2
                    when COMMENT_RE
                        @info += $1 + "\n"
                    else 
                        # Ignore things we don't understand
                    end
                end
            end
        end

        def setup
            # Save the publisher so that we continue to get updates
            publisher = @publisher
            initialize()
            @publisher = publisher
            # We've reinitialized the quiz, so tell everyone
            updateLoad
            update
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
            
            # Need to sort the new set to deal with older files that
            # may not be sorted.
            @strategy.newSet.sort! do |x, y|
                x.position <=> y.position
            end
            setNeedsSave(true)
            updateLoad
            return @contents.length > 0
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
            lastItem = @contents.addContents(quiz.contents)
            # Update status again
            @publisher.unblock
            # The quiz has been modified
            update
            # A file has been loaded
            updateLoad
            # Indicate the last item that was loaded
            updateItemAdded(lastItem) unless lastItem.nil?
            if @currentProblem.nil?
                # Drill a problem if there wasn't one before
                drill
            end
        end

        # Returns true if the vocabulary already exists in the Quiz
        def exists?(vocab)
            @contents.exists?(vocab)
        end
        
        def appendVocab(vocab)
            item = Item.new(vocab)
            @contents.addUniquely(item)
            return item
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

        # Delete an item from the quiz
        def deleteItem(item)
            @contents.delete(item)
            updateItemDeleted(item)
        end
  
        def incorrect
            if !@currentProblem.nil?
                item = @currentProblem.item
                if !item.nil?
                    @strategy.incorrect(item)
                    setNeedsSave(true)
                end
            end
        end
        
        def correct
            if !@currentProblem.nil?
                item = @currentProblem.item
                if !item.nil?
                    @strategy.correct(item)
                    setNeedsSave(true)
                end
            end
        end

        def setCurrentProblem(problem)
            @currentProblem = problem
            update
            updateNewProblem(@currentProblem)
        end
        
        # Creates a problem to be quizzed
        def createProblem(item)
            setCurrentProblem(@strategy.createProblem(item))
        end

        # Creates a problem to be displayed only
        def displayProblem(item)
            problem = @strategy.createProblem(item)
            problem.setDisplayOnly(true)
            setCurrentProblem(problem)
        end

        # Creates a preview for a problem
        def previewProblem(item)
            problem = @strategy.createProblem(item)
            problem.setDisplayOnly(true)
            problem.setPreview(true)
            setCurrentProblem(problem)
        end
        
        def recreateProblem
            createProblem(@currentProblem.item) unless @currentProblem.nil?
        end

        def drill()
            item = @strategy.getItem
            if !item.nil?
                createProblem(item)
            end
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
