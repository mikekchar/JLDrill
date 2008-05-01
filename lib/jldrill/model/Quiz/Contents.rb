require 'jldrill/model/Bin'


module JLDrill

    # Where all the vocabulary items are stored
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
                vocab.status.reset
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
end    

