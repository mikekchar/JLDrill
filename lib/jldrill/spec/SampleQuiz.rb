require 'jldrill/model/Vocabulary'

module JLDrill
    # This is a helper class for the tests.  It simply represents
    # a small quiz.  The various parts of the quiz are broken down
    # to facilitate testing.
    class SampleQuiz
        # The following constants represent a sample quiz file.
        # It is split into the header, info, options and vocab for convenience
##################################################        
        FileHeader = 
%Q[0.2.0-LDRILL-SAVE Testfile]

        FileInfo   = %Q[
# This is the info line]

        FileOptions = %Q[
Random Order
Promotion Threshold: 4
Introduction Threshold: 17
Strategy Version: 0]

        FileVocab = %Q[
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 0/Consecutive: 0/Difficulty: 0/
Poor
Fair
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 2/Level: 0/Position: 1/Consecutive: 0/Difficulty: 0/
Good
Excellent
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 4/Level: 0/Position: 2/Consecutive: 1/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 4/Level: 0/Position: 3/Consecutive: 1/Difficulty: 0/
]
#################################

# The following is the same vocabulary but with the quiz reset so that ever item
# is unseen.

        ResetVocab = %Q[
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Score: 0/Bin: 0/Level: 0/Position: 0/Consecutive: 0/Difficulty: 0/
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 1/Consecutive: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Score: 0/Bin: 0/Level: 0/Position: 2/Consecutive: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Score: 0/Bin: 0/Level: 0/Position: 3/Consecutive: 0/Difficulty: 0/
]

        # This is a new vocabulary to use for adding to the quiz
        NewVocab = "/Kanji: 秋/Reading: あき/Definitions: autumn,fall/Markers: n-adv,P/Score: 0/Bin: 0/Level: 0/Position: -1/Consecutive: 0/Difficulty: 0/"


        FileString = FileHeader + FileInfo + FileOptions + FileVocab
        ResetString = FileHeader + FileInfo + FileOptions + ResetVocab
        
        attr_reader :quiz, :resetQuiz, :emptyQuiz
        
        def initialize
            @quiz = Quiz.new
            @quiz.loadFromString("SampleQuiz", FileString)
            @resetQuiz = Quiz.new
            @resetQuiz.loadFromString("ResetQuiz", ResetString)
            @emptyQuiz = Quiz.new
        end
        
        def header
            FileHeader
        end
        
        def info
            FileInfo
        end
        
        def vocab
            FileVocab
        end
        
        def resetVocab
            ResetVocab
        end
        
        def onlyVocab(string)
            retVal = ""
            string.split("\n").each do |line|
                if line =~ /^\//
                    retVal += line + "\n"
                end
            end
            retVal
        end
        
        def allVocab
            onlyVocab(vocab)
        end
        
        def allResetVocab
            onlyVocab(resetVocab)
        end
        
        def file
            FileString
        end
        
        def resetFile
            ResetString
        end
        
        def sampleVocab
            Vocabulary::create(NewVocab)
        end
    end
end
