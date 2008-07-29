require 'jldrill/contexts/MainContext'
require 'jldrill/contexts/AddNewVocabularyContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/views/VocabularyView'
require 'jldrill/views/gtk/VocabularyView'

module JLDrill

    # The user adds a new Vocabulary to the Quiz
    class UserAddsVocabToQuiz
        attr_reader :storyName, :mainContext, :mainView, :context, :view
    
        def initialize
            @storyName = "User Adds Vocab To Quiz"
            @mainContext = nil
            @mainView = nil
            @context = nil
            @view = nil
        end
        
        def stepName(step)
            @storyName + " - " + step
        end
    
        # Some useful routines
        def setupAbstract
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            @mainView = @mainContext.mainView
            @context = @mainContext.addNewVocabularyContext
            @context.enter(@mainContext)
            @view = @context.mainView
        end
        
        def setupGtk
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
            @mainView = @mainContext.mainView
            @context = @mainContext.addNewVocabularyContext
            @context.enter(@mainContext)
            @view = @context.mainView
        end
        
        # This is very important to call when using setupGtk because otherwise
        # you will leave windows hanging open.
        def shutdown
           @view.close unless @view.nil?
        end
    end
    
    Story = UserAddsVocabToQuiz.new
    
    # There is a control on the MainWindowView that,
    # when selected, allows the user to add a new Vocabulary
    # to the Quiz.
    describe Story.stepName("Main Window View Control") do
        it "should contact the main context when the user tries to add a Vocabulary" do
            Story.setupAbstract
            Story.mainContext.should_receive(:addNewVocabulary)
            Story.mainView.addNewVocabulary
        end
        
        it "should have a test for selecting the GTK control but it's not feasible right now"
    end

    # The user enters a Context called AddNewVocabularyContext.
    # The Context contains a View which allows each part of
    # a Vocabulary to be edited (kanji, reading,
    # definitions, markers, hint).
    describe Story.stepName("Enter AddNewVocabularyContext") do
        it "should have an AddNewVocabularyContext" do
            main = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            context = main.addNewVocabularyContext
            context.should_not be_nil                    
        end
        
        it "should enter the AddNewVocabularyContext when instructed" do
            main = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            context = main.addNewVocabularyContext
            context.should_receive(:enter).with(main)
            main.addNewVocabulary
        end
        
        it "should have a view for a Vocabulary when the context is entered" do
            Story.setupAbstract
            Story.view.should_not be_nil
            Story.view.vocabulary.should_not be_nil
            Story.shutdown                    
        end
        
        it "should have a GTK view that allows editing of the Vocabulary" do
            Story.setupGtk
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
    
    # The user can exit the AddNewVocabularyContext at any time.
    describe Story.stepName("User Can Exit Context Any Time") do
        it "should exit the context when the view is closed" do
            Story.setupAbstract
            Story.context.should_receive(:exit)
            Story.view.close
            # We aren't doing shutdown here because this is what we're testing
        end
        
        it "should exit the view when the Gtk window is destroyed" do
            Story.setupGtk
            Story.view.should_receive(:close)
            Story.view.emitDestroyEvent
            # We aren't doing shutdown here because this is what we're testing
        end
    end

    # If the fields create a valid vocabulary, 
    # the user may add the data as a new Vocabulary in their Quiz.
    # A valid vocabulary is one that has a reading and one or both
    # of a kanji and definitions.
    # The Vocabulary will be put in Bin 0 (Unseen) and the position
    # will be set to the last in the Quiz.
    describe Story.stepName("User Adds New Vocabulary To Quiz") do
        it "should be able to add the view's Vocabulary to the Quiz" do
            Story.setupAbstract
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.context.should_receive(:addVocabulary).with(Story.view.vocabulary)
            Story.view.addVocabulary
            Story.shutdown
        end
        
        it "should not add invalid Vocabulary" do
            Story.setupAbstract
            Story.view.vocabulary.should_not be_valid
            Story.context.should_not_receive(:addVocabulary)
            Story.view.addVocabulary
            Story.shutdown           
        end
        
        it "should be able to add vocabulary to the parent's quiz" do
            Story.setupAbstract
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.mainContext.quiz.size.should be(0)
            Story.view.addVocabulary
            Story.mainContext.quiz.size.should be(1)
            Story.mainContext.quiz.contents.bins[0][0].should_not be_nil
            Story.mainContext.quiz.contents.bins[0][0].status.position.should be(0)
            Story.shutdown            
        end
        
        it "should have a button on the Gtk window for adding the vocab" do
            Story.setupGtk
            Story.view.vocabulary.reading = "あう"
            Story.view.vocabulary.definitions = "to meet"
            Story.view.vocabulary.should be_valid
            Story.view.should_receive(:addVocabulary)
            Story.view.emitAddButtonClickedEvent
            Story.shutdown
        end
        
        it "should update the status on the Gtk main window when the vocab has been added"
        
        it "should make the addition button inactive if the vocabulary is invalid"
         
    end

    # When a Vocabulary has been added to the Quiz, the fields
    # in the edit box are cleared.
    describe Story.stepName("Clears Fields When Vocabulary Added") do
        it "should clear the fields in the Gtk window when an item has been added"
    end

    # If the new Vocabulary already exists in the Quiz, the user
    # is informed that the item was not added because it already exists.  
    # The fields in the edit box are not cleared.
    describe Story.stepName("Doesn't Add Same Vocabulary Twice") do
        it "it should refuse to add an item that already exists"
        
        it "should inform the user that the item hasn't been added"
        
        it "should not clear the fields in the Gtk window"
    end

end
