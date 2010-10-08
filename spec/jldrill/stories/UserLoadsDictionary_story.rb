require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/test/FileProgress'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/VocabularyView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'

require 'gtk2'

# This story tests loading the reference dictionary.
# Unfortunately, I can't test it under GTK because in order
# for the idle loop to work GTK has to be started.
module JLDrill::UserLoadsDictionary

    Story = JLDrill::StoryMemento.new("User Loads Dictionary")
    def Story.setupLoadReference(type)
        setup(type)
        @context = @mainContext.loadReferenceContext
        @view = @context.peekAtView
    end

    def Story.setupAddNewVocabulary(type)
        setup(type)
        @context = @mainContext.addNewVocabularyContext
        @view = @context.peekAtView
    end

    def Story.setupEditVocabulary(type)
        setup(type)
        @context = @mainContext.editVocabularyContext
        @view = @context.peekAtView
    end


#    describe Story.stepName("There is a context for loading the dictionary") do
#        before(:each) do
#            Story.setupLoadReference(JLDrill::Gtk)
#        end
#        
#        after(:each) do
#            Story.shutdown
#        end
#
#        # I suppose this test is a bit worrisome.  If the test
#        # fails then in all probability the context won't
#        # exit, and the test will hang.  
#        # Not only that, but it takes as much time as the rest of
#        # the test suite put together.  Commenting out the meat
#        # of it for now
#
#        it "should load the reference dictionary" do
#            Story.start
#            Story.context.should_not be_nil
#            context = Story.context
#            def context.exit
#                super
#                ::Gtk::main_quit
#            end
#            Story.startGtk do
#                Story.view.should_receive(:update).at_least(1000).times
#                Story.mainContext.loadReference
#            end
#        end
#    end
    # Note: For AddNewVocabulary and Edit Vocabulary I can't test the
    # key accelerators in Gtk.  So I'll only test that the call backs work.
    
    describe Story.stepName("You can load the reference from AddNewVocabulary") do
        before(:each) do
            Story.setupAddNewVocabulary(JLDrill::Test)
        end
        
        after(:each) do
            Story.shutdown
        end
        
        it "should load the reference when requested" do
            Story.start
            Story.mainContext.addNewVocabulary
            Story.mainContext.should_receive(:loadReference)
            Story.context.loadDictionary
        end
    end

    describe Story.stepName("You can load the reference from EditVocabulary") do
        before(:each) do
            Story.setupEditVocabulary(JLDrill::Test)
        end
        
        after(:each) do
            Story.shutdown
        end
        
        it "should load the reference when requested" do
            Story.start
            # EditVocabulary won't come up unless there is a vocabulary
            # to edit.  So we'll get one from the SampleQuiz
            Story.mainContext.quiz = JLDrill::SampleQuiz.new.quiz
            Story.mainContext.quiz.drill

            Story.mainContext.editVocabulary
            Story.mainContext.should_receive(:loadReference)
            Story.context.loadDictionary
        end
    end

    describe Story.stepName("The dictionary to load is in the save file.") do
        before(:each) do
            Story.setupLoadReference(JLDrill::Test)
        end

        it "should save the dictionary filename in the save file" do
            Story.start
            options = Story.mainContext.quiz.options
            options.dictionary.should be_nil
            options.to_s.should eql("Promotion Threshold: 2\nIntroduction Threshold: 10\nReview Meaning\nReview Kanji\n")

            options.dictionary = "TestDictionary"
            options.to_s.should eql("Promotion Threshold: 2\nIntroduction Threshold: 10\nDictionary: TestDictionary\nReview Meaning\nReview Kanji\n")
        end

        it "should load the dictionary relative to the install directory" do
            Story.start
            options = Story.mainContext.quiz.options
            context = Story.context
            def context.readReference
                # Remove the reference reading code.  We just
                # want to enter the context to test the filenames
            end
            Story.mainContext.loadReference

            Story.context.dictionaryName.should be(JLDrill::Config::DICTIONARY_NAME)
            options.dictionary = "tempDictionary"
            Story.context.dictionaryName.should eql("tempDictionary")

            Story.context.getFilename.should eql(File.join(JLDrill::Config::DICTIONARY_DIR, "tempDictionary"))
            Story.context.exit
        end

    end
end
