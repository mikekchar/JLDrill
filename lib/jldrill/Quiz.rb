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


require 'jldrill/Vocabulary'
require 'jldrill/Edict'
require 'jldrill/Bin'

module JLDrill
    class Quiz

        class Options
            attr_reader :randomOrder, :promoteThresh, :introThresh, :oldThresh

            RANDOM_ORDER_RE = /^Random Order/
            PROMOTE_THRESH_RE = /^Promotion Threshold: (.*)/
            INTRO_THRESH_RE = /^Introduction Threshold: (.*)/
            OLD_THRESH_RE = /^Old Threshold: (.*)/
            
            def initialize(quiz)
                @quiz = quiz
                @randomOrder = false
                @promoteThresh = 2
                @introThresh = 10
                @oldThresh = 90
            end
            
            def update
                @quiz.update
            end

            def randomOrder=(value)
                @randomOrder = value
                update
            end

            def promoteThresh=(value)
                @promoteThresh = value
                update
            end

            def introThresh=(value)
                @introThresh = value
                update
            end

            def oldThresh=(value)
                @oldThresh = value
                update
            end
            
            def parseLine(line)
                parsed = true
                case line
                    when RANDOM_ORDER_RE
                        self.randomOrder = true
                    when PROMOTE_THRESH_RE
                        self.promoteThresh = $1.to_i
                    when INTRO_THRESH_RE 
                        self.introThresh = $1.to_i
                    else
                        parsed = false
                end
                parsed
            end
            
            def to_s
                retVal = ""
                if(@randomOrder)
                    retVal += "Random Order\n"
                end
                retVal += "Promotion Threshold: #{@promoteThresh}\n"
                retVal += "Introduction Threshold: #{@introThresh}\n"
                retVal
            end
        end

        class Contents
            attr_reader :quiz, :bins
        
            def initialize(quiz)
                @quiz = quiz
                @bins = []
                addBin("Unseen")
                addBin("Poor")
                addBin("Fair")
                addBin("Good")
                addBin("Excellent")
                @parsingBin = 0
            end
            
            def update
                @quiz.update
            end
            
            def addBin(name)
                @bins.push(Bin.new(name, @bins.length))
            end
            
            def length
                total = 0
                @bins.each do |bin|
                    total += bin.length
                end
                total
            end

            def add(vocab, bin)
                if !vocab.nil? && vocab.valid?
                    vocab.status.score = 0
                    if vocab.status.position == -1
                        vocab.status.position = length 
                    end
                    @bins[bin].push(vocab)
                    update
                end
            end

            def parseVocab(line)
                vocab = Vocabulary.create(line)
                add(vocab, @parsingBin)
            end

            def parseLine(line)
                parsed = false
                @bins.each do |bin|
                    re = Regexp.new("^#{bin.name}$")
                    if line =~ re
                        @parsingBin = bin.number
                        parsed = true
                    end
                end
                if line =~ /^\// 
                        parseVocab(line)
                        parsed = true
                end
                parsed
            end

            # Return an array of all the vocab in the bins
            def all
                retVal = []
                bins.each do |bin|
                    retVal += bin.contents
                end
                retVal
            end

            # Reset the contents back to their original order and status
            def reset
                1.upto(@bins.length - 1) do |i|
                    @bins[0].contents += @bins[i].contents
                    @bins[i].contents = []
                end
                @bins[0].each do |vocab|
                    vocab.status.score = 0
                end
                @bins[0].sort! { |x,y| x.status.position <=> y.status.position }
                update
            end

            # Move the specified vocab to the specified bin
            def moveToBin(vocab, bin)
                if !vocab.nil?
                    @bins[vocab.status.bin].delete_at(vocab.status.index)
                    @bins[bin].push(vocab)
                    update
                end
            end

            def to_s
                retVal = ""
                @bins.each do |bin|
                    retVal += bin.to_s
                end
                retVal
            end
            
        end
        
        class Strategy
        
            def initialize(quiz)
                @quiz = quiz
                @contents = quiz.contents
                @options = quiz.options
            end
        end
        
        attr_reader :savename,  
                    :updated, :vocab, :length, :info, :name, :currentLevel,
                    :contents, :options 
        attr_writer :savename, :updated, :info, :name, :vocab, :bin

        def initialize()
            @updated = false
            @name = ""
            @savename = ""
            @info = ""
            @options = Options.new(self)
            @contents = Contents.new(self)            
            
            @vocab = nil
            @last = nil
            @bin = 0

            @oldCorrect = 0
            @oldIncorrect = 0
            @lastEstimate = 0

            @currentDrill = nil
            @currentAnswer = nil
            @currentLevel = 0
        
            @readingDrill = Proc.new{kanji + hint + reading}
            @readingAnswer = Proc.new{definitions}
            @kanjiDrill = Proc.new{kanji}
            @kanjiAnswer = Proc.new{hint + reading + definitions}
            @meaningDrill = Proc.new{definitions}
            @meaningAnswer = Proc.new{kanji + hint + reading}
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
                @bins[4].each { |word|
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
                @bin = 0
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
            @bin = 0
            
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
            retVal += @name + ": Level "
            retVal += "U: #{@contents.bins[0].length} P: #{@contents.bins[1].length} "
            retVal += "F: #{@contents.bins[2].length} "
            retVal += "G: #{@contents.bins[3].length} E: #{@contents.bins[4].length}"
            retVal += " Current: #{@bin} "
            retVal += " Known: #{@lastEstimate}%"
            retVal += " - "
            if(@options.randomOrder) then retVal += "R" end
            retVal += "(#{@options.promoteThresh},#{@options.introThresh})"
            return retVal
        end

        def to_s
            status
        end

        def underIntroThreshold
            ((@contents.bins[1].length + @contents.bins[2].length) < @options.introThresh) && 
                ((@contents.bins[0].length > 0) || (@contents.bins[4].length > 0))
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
  
        def getBin
            if underIntroThreshold
                # >5 to avoid a bug where it constantly loops around picking
                # the same item.  This will ensure the the "review" has some
                # variety.
                if @contents.bins[4].length > 5
                    if @lastEstimate < @options.oldThresh
                        # Keep drawing old ones until we hit our learning threshold
                        @bin = 4
                    else
                        # Always test old ones 10% if the time
                        if rand(10) > 8
                            @bin = 4
                        else
                            @bin = 0
                        end          
                    end
                else
                    # We don't have any old values, so just introduce new ones
                    @bin = 0
                end
            else
                # Otherwise quiz one that has already been introduced.
                @bin = case rand(7)
                    when 0..3 then 1
                    when 4..5 then 2
                    else 3
                end
            end
        end

        def getVocab
            if(@contents.length == 0)
                return nil
            end

            getBin
            getBin until @contents.bins[@bin].length > 0

            if((!@options.randomOrder) && (@bin == 0))
                index = 0
            else
                index = rand(@contents.bins[@bin].length)
            end

            @vocab = @contents.bins[@bin][index] 
            if @bin == 0 then promote end
            return @vocab
        end

        def randomVocab!
            if(@contents.length == 0)
                return
            end

            getVocab
            deadThresh = 10
            if(@contents.length > 1)
                # Don't show the same item twice in a row
                until (@vocab != @last) || (deadThresh == 0)
                    getVocab
                    deadThresh -= 1 
                end
                if (deadThresh == 0)
                    print "Warning: Deadlock broken in randomVocab!"
                end
            end
            @last = @vocab
        end

        # Get an array containing all the vocabulary in the quiz
        def allVocab
            @contents.all
        end

        # Resets the quiz back to it's original state
        def reset
            @contents.reset
        end

        # Move the current vocabular to the specified bin
        def moveToBin(bin)
            @contents.moveToBin(@vocab, bin)
            @bin = bin
        end

        def promote
            if !@vocab.nil? && (@vocab.status.bin + 1 < @contents.bins.length) 
                if @vocab.status.bin != 2 || @vocab.status.level == 2
                    moveToBin(@vocab.status.bin + 1)
                else
                    if @vocab.kanji
                        @vocab.status.level += 1
                    else
                        @vocab.status.level = 2
                    end
                end
            end
        end

        def demote(level=0)
            if @vocab
                # Reset the level and bin to the one that
                # the user failed on.
 
                @vocab.status.level = level
                if level == 0
                    moveToBin(1)
                else
                    moveToBin(2)
                end
            end
        end
  
        def adjustQuizOld(good)
            if(@bin == 4)
                if good
                    @oldCorrect += 1
                else
                    @oldIncorrect += 1
                end
                reEstimate
            end
        end
  
        def correct
            adjustQuizOld(true)
            if(@vocab)
                @vocab.status.score += 1
                if(@vocab.status.score >= @options.promoteThresh)
                    promote
                end
                @updated = true
            end
        end

        def incorrect
            adjustQuizOld(false)
            if(@vocab)
                demote(@currentLevel)
                @updated = true
            end
        end

        def drill()
            randomVocab!
    
            # Kind of screwy logic...  In the "fair" bin, only drill
            # at the current level.  At other levels, drill at a random levels
            # this enforces introduction of the material in the "fair" bin.

            if @vocab.status.bin == 2 || @vocab.status.level == 0
                @currentLevel = @vocab.status.level
            else
                if @vocab.kanji == nil
                    # Don't try to drill kanji if there isn't any
                    @currentLevel = rand(1)
                else
                    @currentLevel = rand(@vocab.status.level)
                end
            end

            case @currentLevel
                when 0
                    @currentDrill = @readingDrill
                    @currentAnswer = @readingAnswer
                when 1
                    @currentDrill = @meaningDrill
                    @currentAnswer = @meaningAnswer
                when 2
                    if @vocab.kanji
                        @currentDrill = @kanjiDrill
                        @currentAnswer = @kanjiAnswer
                    else
                        @currentDrill = @meaningDrill
                        @currentAnswer = @meaningAnswer
                    end
            end        

            return @currentDrill.call
        end

        def answer()
            text = ""

            text = @currentAnswer.call

            return text
        end

        def currentDrill
            text = ""
            if @currentDrill
                text = @currentDrill.call
            end
            return text
        end

        def currentAnswer
            text = ""
            if @currentAnswer
                text = @currentAnswer.call
            end
            return text
        end

        def kanji
            text = ""

            if @vocab
                if @vocab.kanji
                    text = @vocab.kanji + "\n"
                end
            end

            return text
        end

        def reading
            text = ""

            if @vocab
                text = @vocab.reading + "\n"
            end

            return text
        end

        def hint
            text = ""

            if @vocab
                if @vocab.hint
                    text += @vocab.hint + "\n"
                end
            end

            return text
        end

        def definitions
            text = ""

            if @vocab
                text = @vocab.definitions + "\n"
            end

            return text
        end
        
    end
end
