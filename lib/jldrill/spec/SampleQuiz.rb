# encoding: utf-8
require 'jldrill/model/items/Vocabulary'
require 'jldrill/Version'

module JLDrill
    # This is a helper class for the tests.  It simply represents
    # a small quiz.  The various parts of the quiz are broken down
    # to facilitate testing.
    class SampleQuiz
        # The following constants represent a sample quiz file.
        # It is split into the header, info, options and vocab for convenience
##################################################        
        FileHeader = JLDrill::VERSION + "-LDRILL-SAVE Testfile"

        FileInfo   = %Q[
# This is the info line]

        FileOptions = %Q[
Random Order
Promotion Threshold: 4
Introduction Threshold: 17
Review Meaning
Review Kanji]

        FileDefaultOptions = %Q[
Promotion Threshold: 2
Introduction Threshold: 10
Review Meaning
Review Kanji]

        FileVocab = %Q[
Unseen
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 0/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
Poor
Fair
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
Good
Excellent
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 2/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/LastReviewed: 1230076403/Duration: 10/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 3/Consecutive: 1/MeaningProblem/Score: 0/Level: 0/LastReviewed: 1230076403/Duration: 10/Difficulty: 0/
Forgotten
]
#################################

# The following is the same vocabulary but with the quiz reset so 
# that every item is unseen.

        ResetVocab = %Q[
Unseen
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P/Position: 1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P/Position: 2/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj/Position: 3/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
Poor
/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P/Position: 0/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/
]

# This is the result of allVocab joined with \n
        AllVocab = 
%Q[/Kanji: 会う/Reading: あう/Definitions: to meet,to interview/Markers: v5u,P
/Kanji: 青い/Reading: あおい/Definitions: blue,pale,green,unripe,inexperienced/Markers: adj,P
/Kanji: 赤い/Reading: あかい/Definitions: red/Markers: adj,P
/Kanji: 明い/Reading: あかるい/Definitions: bright,cheerful/Markers: adj]

        # This is a new vocabulary to use for adding to the quiz
        NewVocab = "/Kanji: 秋/Reading: あき/Definitions: autumn,fall/Markers: n-adv,P/Position: -1/Consecutive: 0/MeaningProblem/Score: 0/Level: 0/Difficulty: 0/"


        FileString = FileHeader + FileInfo + FileOptions + FileVocab
        ResetString = FileHeader + FileInfo + FileOptions + ResetVocab
        DefaultString = FileHeader + FileInfo + ResetVocab
        
        attr_reader :quiz, :resetQuiz, :emptyQuiz, :defaultQuiz
        
        def initialize
            @quiz = Quiz.new
            @quiz.loadFromString("SampleQuiz", FileString)
            @resetQuiz = Quiz.new
            @resetQuiz.loadFromString("ResetQuiz", ResetString)
            @emptyQuiz = Quiz.new
            @defaultQuiz = Quiz.new
            @defaultQuiz.loadFromString("DefaultQuiz", DefaultString)
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
            AllVocab
        end
        
        def allResetVocab
            AllVocab
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

        def defaultSaveFile
            FileHeader + FileInfo + FileDefaultOptions + ResetVocab + "Fair\nGood\nExcellent\nForgotten\n"
        end
    end
end
