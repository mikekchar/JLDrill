require 'jldrill/spec/StorySpec'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/MainWindowView'

module JLDrill::Stories

    # The user adds a new Vocabulary to the Quiz
    class UserAddsVocabularyToQuiz < StorySpec

        # There is a control on the MainWindowView that,
        # when selected, allows the user to add a new Vocabulary
        # to the Quiz.
        def s1_MainWindowViewControl
            describe spec_name("Main Window View Control") do
                it "should contact the main context when the user tries to add a Vocabulary" do
                    @context = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
                    @view = JLDrill::MainWindowView.new(@context)
                    @context.should_receive(:addNewVocabulary)
                    @view.addNewVocabulary
                end
                
                it "should have a test for selecting the GTK control but it's not feasible right now"
            end
        end

        # The user enters a Context called AddNewVocabularyContext
        # which allows them to enter the reading for a Vocabulary.
        # The Context contains a View which allows each part of
        # a Vocabulary to be edited (kanji, reading,
        # definitions, markers, hint).
        def s2_EnterAddNewVocabularyContext
            describe spec_name("Enter AddNewVocabularyContext") do
                it "is not implemented yet."
            end
        end
        
        # If any of the fields in the edit box has data in it, the
        # user may add the data as a new Vocabulary in their Quiz.
        # The Vocabulary will be put in Bin 0 (Unseen) and the position
        # will set to the last in the Quiz.
        def s3_UserMayAddVocabularyToQuiz
            describe spec_name("User Adds New Vocabulary To Quiz") do
                it "is not implemented yet."
            end
        end

        # If the new Vocabulary already exists in the Quiz, the user
        # is prompted if they really want to add the vocabulary.  If
        # they don't, the Vocabulary is not added, but the fields
        # in the edit box are not cleared.
        def s4_DoesntAddVocabularyTwice
            describe spec_name("Doesn't Add Same Vocabulary Twice") do
                it "is not implemented yet."
            end
        end

        # When a Vocabulary has been added to the Quiz, the fields
        # in the edit box are cleared.
        def s5_ClearsFieldsWhenVocabularyAdded
            describe spec_name("Clears Fields When Vocabulary Added") do
                it "is not implemented yet."
            end
        end

        # The user can exit the AddNewVocabularyContext at any time.
        def s6_UserCanExitContext
            describe spec_name("User Can Exit Context Any Time") do
                it "is not implemented yet."
            end
        end
        
        run_specs
    end
end
