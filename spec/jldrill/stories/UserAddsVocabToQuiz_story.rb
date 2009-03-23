require 'jldrill/contexts/AddNewVocabularyContext'
require 'jldrill/views/gtk/QuizStatusView'
require 'jldrill/views/VocabularyView'
require 'jldrill/views/gtk/VocabularyView'
require 'jldrill/spec/StoryMemento'

module JLDrill::UserAddsVocabToQuiz

    Story = JLDrill::StoryMemento.new("User Adds Vocab To Quiz")
    def Story.setup(type)
        super(type)
        @context = @mainContext.addNewVocabularyContext
        @view = @context.peekAtView
    end
    
    def Story.addVocab
        Story.view.vocabulary.reading = "あう"
        Story.view.vocabulary.definitions = "to meet"
        Story.view.addVocabulary
    end

###########################################
    
    describe Story.stepName("The user can begin adding new items") do
        before(:each) do
            Story.setup(JLDrill)
        end

        after(:each) do
            Story.shutdown
        end

        it "should have a method to add items from the main Context" do
            Story.start
            cc = Story.mainContext.runCommandContext
            cc.should_not be_nil
            cv = cc.mainView
            cv.should_not be_nil

            # Why the hell did make all the methods in the CommandView
            # procs?  I can't remember.  Maybe to try to distiguish
            # between outgoing and incoming methods in the view???
            cv.addNewVocabulary.should_not be_nil
            Story.mainContext.should_receive(:addNewVocabulary)
            cv.addNewVocabulary.call
        end
    end

###########################################

    describe Story.stepName("The user enters AddNewVocabularyContext") do
        it "should have an AddNewVocabularyContext" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabularyContext.should_not be_nil
            Story.shutdown
        end
        
        it "should enter the AddNewVocabularyContext when instructed" do
            Story.setup(JLDrill)
            Story.start
            Story.context.should_receive(:enter).with(Story.mainContext)
            Story.mainContext.addNewVocabulary
            Story.shutdown
        end
        
        it "should have a view for a Vocabulary when the context is entered" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.should_not be_nil
            Story.view.vocabulary.should_not be_nil
            Story.shutdown                    
        end
        
        it "should have a GTK view that allows editing of the Vocabulary" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.should_not be_nil
            Story.view.vocabularyWindow.getVocab.should eql(Story.view.vocabulary)
            kanjiString = "会う"
            hintString = "No hints!"
            readingString = "あう"
            definitionsString = "to meet, to interview"
            markersString = "v5u, P"
            vocabString = "/Kanji: #{kanjiString}/" +
                "Hint: #{hintString}/" +
                "Reading: #{readingString}/" +
                "Definitions: #{definitionsString}/" +
                "Markers: #{markersString}/"
            testVocab = JLDrill::Vocabulary.create(vocabString)
            Story.view.vocabularyWindow.kanji = kanjiString
            Story.view.vocabularyWindow.kanji.should be_eql(kanjiString)
            Story.view.vocabularyWindow.hint = hintString
            Story.view.vocabularyWindow.hint.should be_eql(hintString)
            Story.view.vocabularyWindow.reading = readingString
            Story.view.vocabularyWindow.reading.should be_eql(readingString)
            Story.view.vocabularyWindow.definitions = definitionsString
            Story.view.vocabularyWindow.definitions.should be_eql(definitionsString)
            Story.view.vocabularyWindow.markers = markersString
            Story.view.vocabularyWindow.markers.should be_eql(markersString)
            
            Story.view.vocabularyWindow.getVocab.should be_eql(testVocab)
            
            Story.shutdown
        end
    end

###########################################
    
    describe Story.stepName("The user can exit the context at any time") do

        # This step is difficult since we can't call Story.shutdown because
        # the important cleanup methods are mocked.  I try as best as I
        # can to clean up by hand.
    
        it "should exit the context when the view is closed" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            # We really should try to clean up here, but I can't think
            # of a way to do it since Story.context#exit is already mocked.
            # What we really need to do is call Context#exit, but I can't.
            Story.context.should_receive(:exit)
            Story.view.close
            # Clean up the memento
            Story.restart
        end
        
        it "should exit the view when the Gtk window is destroyed" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.should_receive(:close) do 
                Story.context.exit
            end
            Story.view.emitDestroyEvent
            Story.mainView.close
            # Clean up the memento
            Story.restart
        end
    end

###########################################
    
    describe Story.stepName("The user chooses to add the entered Vocabulary") do
        it "should be able to add the view's Vocabulary to the Quiz" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.context.should_receive(:addVocabulary).with(Story.view.vocabulary)
            Story.addVocab
            Story.shutdown
        end
        
        it "should not add invalid Vocabulary" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.vocabulary.should_not be_valid
            Story.context.should_not_receive(:addVocabulary)
            Story.view.addVocabulary
            Story.shutdown           
        end
        
        it "should add the vocabulary to the parent context's quiz" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.mainContext.quiz.size.should be(0)
            Story.addVocab
            Story.mainContext.quiz.size.should be(1)
            Story.mainContext.quiz.contents.bins[0][0].should_not be_nil
            Story.mainContext.quiz.contents.bins[0][0].position.should be(0)
            Story.shutdown            
        end
        
        it "should have a button on the Gtk window for adding the vocab" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.vocabularyWindow.reading = "あう"
            Story.view.vocabularyWindow.definitions = "to meet"
            Story.view.should_receive(:addVocabulary)
            Story.view.emitAddButtonClickedEvent
            Story.shutdown
        end
         
    end

###########################################
    
    describe Story.stepName("The fields in the view are cleared when a Vocabulary is added") do
        it "should clear the fields in the Gtk window when an item has been added" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.vocabularyWindow.reading = "あう"
            Story.view.vocabularyWindow.definitions = "to meet"
            Story.view.addVocabulary
            Story.view.vocabularyWindow.reading.should be_eql("")
            Story.view.vocabularyWindow.definitions.should be_eql("")
            Story.shutdown
        end

        it "should not clear the fields if the item was invalid" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.vocabularyWindow.definitions = "yuck"
            Story.view.addVocabulary.should be(false)
            Story.view.vocabularyWindow.definitions.should be_eql("yuck")
            Story.shutdown
        end
    end

###########################################
    
    describe Story.stepName("Doesn't add the same Vocabulary twice") do
        it "it should refuse to add an item that already exists" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.mainContext.quiz.size.should be(0)
            Story.addVocab
            Story.mainContext.quiz.size.should be(1)
            Story.addVocab
            # It's the same one so it shouldn't get added
            Story.mainContext.quiz.size.should be(1)
        end
    end

###########################################
    
    describe Story.stepName("The user can search the dictionary") do
        before(:each) do
            Story.setup(JLDrill)
        end

        after(:each) do
            Story.shutdown
        end

        it "can load the and search the dictionary from this context" do
            Story.start
            Story.mainContext.addNewVocabulary
            # The dictionary isn't loaded yet.
            Story.view.dictionaryLoaded?.should be(false)

            # Searching should find nothing
            Story.view.search("あめ").should be_empty

            # Override with the small test dictionary
            Story.useTestDictionary

            # Load the dictionary
            Story.view.loadDictionary
            Story.view.dictionaryLoaded?.should be(true)

            # Note: Usually I'd do this in separate tests, but loading
            # the dictionary is expensive, so I have to jam it all
            # into one test.  It would be nice to be able to have tests
            # that can build on one another.

            # Searching for nil or empty string should find nothing
            Story.view.search(nil).should be_empty
            Story.view.search("").should be_empty

            # It should find entries
            Story.view.search("あ").should have_at_least(1).item
        end
    end
end
