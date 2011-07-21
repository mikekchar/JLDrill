# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/spec/storyFunctionality/Gtk'
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/model/Quiz/Options'
require 'jldrill/model/Config'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::UserChoosesReviewProblemTypes

    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::Gtk
        include JLDrill::StoryFunctionality::SampleQuiz

        # Set the current context and view to the setOptionsContext
        def setOptions
            @context = @mainContext.setOptionsContext
            @view = @context.peekAtView
        end

        def setup(type)
            super(type)
            hasDefaultQuiz
        end
    end

    Story = MyStory.new("User Chooses the Review Problem Types")

    describe Story.stepName("Options are stored and read") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
            Story.quiz.options.reviewOptionsSet.should eql(false)
			Story.quiz.options.reviewMeaning.should eql(true)
            Story.quiz.options.reviewKanji.should eql(true)
            Story.quiz.options.reviewReading.should eql(false)
        end

        after(:each) do
            Story.shutdown
        end

        it "should have the correct defaults" do
            # the before each has this covered, so there's nothing to do
            # Note that the sample file doesn't set the options, so this
            # checks the defaults.
        end

        it "should store the default options" do
            # Even though no options have been changed they should be written
            # to the output file.
            saveString = Story.quiz.saveToString
            saveString.should eql(Story.sampleQuiz.defaultSaveFile)
        end

        it "should store changed options" do
            Story.quiz.options.reviewMeaning = false
            Story.quiz.options.reviewMeaning.should eql(false)
            Story.quiz.options.reviewKanji = false
            Story.quiz.options.reviewKanji.should eql(false)
            Story.quiz.options.reviewReading = true
            Story.quiz.options.reviewReading.should eql(true)

            # The two thresholds are written by default
            optionsString = "Promotion Threshold: 2\n" + 
                "Introduction Threshold: 10\n" +
                "Review Reading\n"
            Story.quiz.options.to_s.should eql(optionsString)
            
            saveString = Story.quiz.saveToString
            # optionsString has a trailing \n but the resetVocab 
            # starts with a \n so I have to chop one out.
            saveString.should eql(Story.sampleQuiz.header + Story.sampleQuiz.info + 
                                  "\n" + optionsString.chop + 
                                  Story.sampleQuiz.resetVocab +
                                  "Fair\nGood\nExcellent\nForgotten\n")
        end

        it "should show that the quiz needs saving if certain options are changed" do
            # Currently the file needs to be saved as soon as it is loaded
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # ReviewMeaning
            Story.quiz.options.reviewMeaning = false
            Story.quiz.needsSave.should eql(true)
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # ReviewKanji
            Story.quiz.options.reviewKanji = false
            Story.quiz.needsSave.should eql(true)
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # ReviewReading
            Story.quiz.options.reviewReading = true
            Story.quiz.needsSave.should eql(true)
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)
        end

        # For legacy reasons, if the review options haven't been
        # set, then it should review both kanji and meaning.
        # But if any of the review options are set, then it
        # should only do the ones that are set
        it "should know if the review options have been set" do
            # It should initially be false
            Story.quiz.options.reviewOptionsSet.should eql(false)
            Story.quiz.options.reviewMeaning = false
            Story.quiz.options.reviewOptionsSet.should eql(true)

            # We'll set it so that we can keep testing
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.options.reviewMeaning = true
            Story.quiz.options.reviewOptionsSet.should eql(true)

            # We'll set it so that we can keep testing
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.options.reviewKanji = false
            Story.quiz.options.reviewOptionsSet.should eql(true)

            # We'll set it so that we can keep testing
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.options.reviewKanji = true
            Story.quiz.options.reviewOptionsSet.should eql(true)

            # We'll set it so that we can keep testing
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.options.reviewReading = false
            Story.quiz.options.reviewOptionsSet.should eql(true)

            # We'll set it so that we can keep testing
            Story.quiz.options.setReviewOptions(false)
            Story.quiz.options.reviewReading = true
            Story.quiz.options.reviewOptionsSet.should eql(true)
        end

        it "should clear the review defaults when the reviewOptions are set" do
            # These are the defaults
            Story.quiz.options.reviewMeaning.should eql(true)
            Story.quiz.options.reviewKanji.should eql(true)
            Story.quiz.options.reviewReading.should eql(false)

            # Even if we set something to it's default...
            Story.quiz.options.reviewReading = false
            # It should clear all the options before doing it's thing
            Story.quiz.options.reviewMeaning.should eql(false)
            Story.quiz.options.reviewKanji.should eql(false)
        end

        it "should create a list of allowed levels" do
            # It should default to meaning and kanji levels
            Story.quiz.options.allowedLevels.should eql([1,2])

            # This should reset all the options to false
            Story.quiz.options.reviewMeaning = false
            # And ironically, this should cause it to use the default
            # of meaning and kanji levels
            Story.quiz.options.allowedLevels.should eql([1,2])

            # Only Meaning
            Story.quiz.options.reviewMeaning = true            
            Story.quiz.options.allowedLevels.should eql([2])

            # Only Kanji
            Story.quiz.options.reviewMeaning = false
            Story.quiz.options.reviewKanji = true
            Story.quiz.options.allowedLevels.should eql([1])

            # Only Reading
            Story.quiz.options.reviewKanji = false
            Story.quiz.options.reviewReading = true
            Story.quiz.options.allowedLevels.should eql([0])

            # Kanji and Reading
            Story.quiz.options.reviewKanji = true
            Story.quiz.options.reviewReading = true
            Story.quiz.options.allowedLevels.should eql([0,1])

            # All three
            Story.quiz.options.reviewMeaning = true
            Story.quiz.options.allowedLevels.should eql([0,1,2])
        end
    end

    describe Story.stepName("Options view can modify options") do
        before(:each) do
            Story.setup(JLDrill::Gtk)
            Story.start
            Story.setOptions
        end

        after(:each) do
            Story.shutdown
        end

        def setValueAndTest(valueString, default, target)
            modelString = "Story.mainContext.quiz.options." + valueString
            setUIString = "Story.view.optionsWindow." + valueString + " = " + 
                           target.to_s 
            eval(modelString).should be(default)
   		    Story.pressOKAfterEntry(Story.view.optionsWindow) do
                eval(setUIString)
            end
            Story.context.enter(Story.mainContext)
            eval(modelString).should be(target)
        end

        it "should be able to set the review reading option" do
            setValueAndTest("reviewReading", false, true)
        end

        it "should be able to set the review kanji option" do
            setValueAndTest("reviewKanji", true, false)
        end

        it "should be able to set the review meaning option" do
            setValueAndTest("reviewMeaning", true, false)
        end

    end
end
