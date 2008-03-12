
module JLDrill

    # A memento that keeps track of the drill status for this
    # vocabulary.
    # * score is the number of times the item has been successfully
    # drilled in the current bin.
    # * bin is the number of the bin
    # * level is 0 if meaning has not been introduced 1 if kanji has not been introduced, 2 otherwise (is this right?)
    # * position is the original ordinal position of the item in the quiz
    # * index is the ordinal position of the item in the bin
    #
    # Note: item is not currently being stored in the files and is not outputted
    # in to_s()
    class VocabularyStatus

        SCORE_RE = /^Score: (.*)/
        BIN_RE = /^Bin: (.*)/
        LEVEL_RE = /^Level: (.*)/
        POSITION_RE = /^Position: (.*)/

        attr_reader :score, :bin, :level, :position, :index
        attr_writer :score, :bin, :level, :position, :index


        def initialize(vocab)
            @vocab = vocab
            @score = 0
            @bin = 0
            @level = 0
            @position = 0
            @index = nil
        end
        
        # Parses a vocabulary value in save format.
        def parse(string)
            parsed = true
            case string
                when SCORE_RE 
                    @score = $1.to_i
                when BIN_RE 
                    @bin = $1.to_i
                when LEVEL_RE
                    @level = $1.to_i
                when POSITION_RE 
                    @position = $1.to_i
            else # Not something we understand
                parsed = false
            end
            parsed
        end
        
        def to_s
            "/Score: #{@score}" + "/Bin: #{@bin}" + "/Level: #{@level}" +
                "/Position: #{@position}"
        end
    end
end
