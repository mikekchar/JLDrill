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

###########################################
    
    describe Story.stepName("There is a control on the main window view for adding new items") do
        it "should contact the main context when the user tries to add a Vocabulary" do
            Story.setup(JLDrill)
            Story.start
            Story.mainContext.should_receive(:addNewVocabulary)
            Story.mainView.addNewVocabulary
            Story.shutdown
        end
        
        it "should have a test for selecting the GTK control but it's not feasible right now"
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
            Story.view.vocabularyWindow.getVocab.should be_eql(Story.view.vocabulary)
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
            testVocab = Vocabulary.create(vocabString)
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
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.context.should_receive(:addVocabulary).with(Story.view.vocabulary)
            Story.view.addVocabulary
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
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.mainContext.quiz.size.should be(0)
            Story.view.addVocabulary
            Story.mainContext.quiz.size.should be(1)
            # Adding the vocabulary to an empty quiz triggers the
            # quiz to be drilled.  This automatically moves the item
            # from bin 0 to bin 1.
            Story.mainContext.quiz.contents.bins[1][0].should_not be_nil
            Story.mainContext.quiz.contents.bins[1][0].status.position.should be(0)
            Story.shutdown            
        end
        
        it "should have a button on the Gtk window for adding the vocab" do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.mainContext.addNewVocabulary
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.view.should_receive(:addVocabulary)
            Story.view.emitAddButtonClickedEvent
            Story.shutdown
        end
        
        it "should make the addition button inactive if the vocabulary is invalid"
         
    end

###########################################
    
    describe Story.stepName("The fields in the view are cleared when a Vocabulary is added") do
        it "should clear the fields in the Gtk window when an item has been added"
    end

###########################################
    
    describe Story.stepName("Doesn't add the same Vocabulary twice") do
        it "it should refuse to add an item that already exists"
        
        it "should inform the user that the item hasn't been added"
        
        it "should not clear the fields in the Gtk window"
    end

end
