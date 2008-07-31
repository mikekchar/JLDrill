require 'jldrill/contexts/MainContext'
require 'jldrill/contexts/AddNewVocabularyContext'
require 'jldrill/views/MainWindowView'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/QuizStatusView'
require 'jldrill/views/VocabularyView'
require 'jldrill/views/gtk/VocabularyView'
require 'jldrill/spec/Fakes'

# The user adds a new Vocabulary to the Quiz
#
# 1. There is a control on the MainWindowView that,
#    when selected, allows the user to add a new Vocabulary
#    to the Quiz.
#
# 2. The user enters a Context called AddNewVocabularyContext.
#    The Context contains a View which allows each part of
#    a Vocabulary to be edited (kanji, reading,
#    definitions, markers, hint).
#
# 3. The user can exit the AddNewVocabularyContext at any time.
#
# 4. If the fields create a valid vocabulary, 
#    the user may add the data as a new Vocabulary in their Quiz.
#    A valid vocabulary is one that has a reading and one or both
#    of a kanji and definitions.
#    The Vocabulary will be put in Bin 0 (Unseen) and the position
#    will be set to the last in the Quiz.
#
# 5. When a Vocabulary has been added to the Quiz, the fields
#    in the edit box are cleared.
#
# 6. If the new Vocabulary already exists in the Quiz, the user
#    is informed that the item was not added because it already exists.  
#    The fields in the edit box are not cleared.
#
module JLDrill::UserAddsVocabToQuiz

    class StoryMemento
        attr_reader :storyName, :mainContext, :mainView, :context, :view
    
        def initialize
            @storyName = "User Adds Vocab To Quiz"
            restart
        end
        
        def restart
            @app = nil
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
            @app = JLDrill::Fakes::App.new(nil)
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill))
            @mainContext.enter(@app)
            @mainView = @mainContext.mainView
            @context = @mainContext.addNewVocabularyContext
            @context.enter(@mainContext)
            @view = @context.mainView
        end
        
        def setupGtk
            @app = JLDrill::Fakes::App.new(nil)
            @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
            @mainContext.enter(@app)
            @mainView = @mainContext.mainView
            @context = @mainContext.addNewVocabularyContext
            @context.enter(@mainContext)
            @view = @context.mainView
        end
        
        # This is very important to call when using setupGtk because otherwise
        # you will leave windows hanging open.
        def shutdown
            @view.close unless @view.nil?
            @mainView.close unless @mainView.nil?
            restart
        end
    end
    
    Story = StoryMemento.new

###########################################
    
    describe Story.stepName("There is a control on the main window view for adding new items") do
        it "should contact the main context when the user tries to add a Vocabulary" do
            Story.setupAbstract
            Story.mainContext.should_receive(:addNewVocabulary)
            Story.mainView.addNewVocabulary
        end
        
        it "should have a test for selecting the GTK control but it's not feasible right now"
    end

###########################################

    describe Story.stepName("The user enters AddNewVocabularyContext") do
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

###########################################
    
    describe Story.stepName("The user can exit the context at any time") do

        # This step is difficult since we can't call Story.shutdown because
        # the important cleanup methods are mocked.  I try as best as I
        # can to clean up by hand.
    
        it "should exit the context when the view is closed" do
            Story.setupAbstract
            # We really should try to clean up here, but I can't think
            # of a way to do it since Story.context#exit is already mocked.
            # What we really need to do is call Context#exit, but I can't.
            Story.context.should_receive(:exit)
            Story.view.close
            # Clean up the memento
            Story.restart
        end
        
        it "should exit the view when the Gtk window is destroyed" do
            Story.setupGtk
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
        
        it "should add the vocabulary to the parent context's quiz" do
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
        
        it "should update the status on the Gtk main window when the vocab has been added" do
            Story.setupGtk
            Story.view.vocabularyWindow.reading = "あう"
            Story.view.vocabularyWindow.definitions = "to meet"
            Story.view.vocabularyWindow.getVocab.should be_valid
            Story.mainContext.displayQuizStatusContext.should_receive(:update)
            Story.view.addVocabulary
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
