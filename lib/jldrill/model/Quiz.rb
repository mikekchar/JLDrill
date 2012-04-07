# encoding: utf-8
require 'jldrill/model/items/Vocabulary'
require 'jldrill/model/Problem'
require 'jldrill/model/quiz/QuizItem'
require 'jldrill/model/quiz/Options'
require 'jldrill/model/quiz/Contents'
require 'jldrill/model/quiz/Strategy'
require 'jldrill/model/util/DataFile'
require 'Context/Publisher'
require 'jldrill/Version'

module JLDrill
    class Quiz < DataFile

        JLDRILL_HEADER_RE = /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE (.*)/
        COMMENT_RE = /^\#[ ]?(.*)/
        VERSION_RE = /^(\d+)\.(\d+)\.(\d+)/
        JLDRILL_CANLOAD_RE = /^(\d+\.\d+\.\d+)?-?LDRILL-SAVE/

        attr_reader :needsSave, :info, :name, 
                    :contents, :options, :currentProblem,
                    :strategy
        attr_writer :info, :name, :currentProblem

        def initialize()
            super
            # Make the file progress indicator report every 10 lines
            @stepSize = 10
        end

        def reset
            @name = ""
            @info = ""
            @options = Options.new(self)
            @options.subscribe(self)
            @contents = Contents.new(self)
            @strategy = Strategy.new(self)
            @currentProblem = nil
            @needsSave = false
            @last = nil
            update
            super
        end

        def optionsUpdated(options)
            @contents.updateSchedules
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

        def setLoaded(bool)
            if bool
                updateLoad
            end
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

        def modifyProblem(problem, vocab)
            if !problem.nil?
                problem.vocab = vocab
                problemModified(problem)
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
            if (@contents.length == 0) || !@needsSave
                return true
            elsif @file == "" 
                return false
            else
                begin
                    saveFile = File.new(@file, "w")
                    if saveFile
                        saveFile.print(saveToString)
                        saveFile.close
                        setNeedsSave(false)
                        retVal = true
                    end
                rescue
                    return false
                end
            end
        end

        # Returns the filename relative to the Quiz's current
        # path.  If a filename hasn't been set, the file is
        # expanded using the applications current path.
        def useSavePath(filename)
            if !@file.empty?
                dirname = File.expand_path(File.dirname(@file))
                return File.expand_path(filename, dirname)
            else
                return File.expand_path(filename)
            end
        end

        def Quiz.canLoad?(header)
            retVal = false
            if header =~ JLDRILL_CANLOAD_RE
                if $1 != ""
                    if $1 =~ VERSION_RE
                        if $1.to_i > 0 || $2.to_i < 7
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

        def parseEntry
            parseLine(@lines[@parsed])
            @parsed += 1
        end

        def dataSize
            @contents.size
        end

        def finishParsing
            # Indicate to the options that we have finished loading
            # and that any other changes are due to the user.
            @options.optionsFinishedLoading
            # Need to sort the new set to deal with older files that
            # may not be sorted.
            @contents.newSet.sort! do |x, y|
                x.position <=> y.position
            end
            # Resort the review set according to schedule
            reschedule
            setNeedsSave(true)
            update
            super
        end

        def loadFromString(file, string)
            reset
            @file = file
            @lines = string.split("\n")
            parse
        end

        def loadFromDict(dict)
            if dict
                # Don't update the status while we're loading the file
                @publisher.block
                reset
                @name = dict.shortFilename
                dict.eachVocab do |vocab|
                    @contents.add(vocab, 0)
                end
                reschedule
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

        def reschedule
            @contents.reschedule
        end

        # Returns true if the vocabulary already exists in the Quiz
        def exists?(vocab)
            @contents.exists?(vocab)
        end
        
        def appendVocab(vocab)
            item = QuizItem.new(self, vocab)
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
        def resetContents
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
                    item.incorrect
                    setNeedsSave(true)
                end
            end
        end
        
        def correct
            if !@currentProblem.nil?
                item = @currentProblem.item
                if !item.nil?
                    item.correct
                    setNeedsSave(true)
                end
            end
        end

        # Promote the current problem into the review set
        # if it is in the working set without any further
        # practice.
        def learn
            if !@currentProblem.nil?
                item = @currentProblem.item
                if !item.nil?
                    item.learn
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
