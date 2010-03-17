require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/spec/storyFunctionality/Gtk'
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/model/Quiz/Options'
require 'jldrill/model/Config'

module JLDrill::UserChoosesReviewProblemTypes

    class MyStory < JLDrill::StoryMemento
        include JLDrill::StoryFunctionality::Gtk
        include JLDrill::StoryFunctionality::SampleQuiz

        # Set the current context and view to the setOptionsContext
        # Note: Doesn't enter the context since enterDialogAndPressOK
        # does that.
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
            Story.setup(JLDrill)
            Story.start
			Story.quiz.options.reviewMeaning.should eql(true)
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

            # The two thresholds are written by default
            # ReviewMeaning is set by default, so nothing should be written
            optionsString = "Promotion Threshold: 2\n" + 
                "Introduction Threshold: 10\n"
            Story.quiz.options.to_s.should eql(optionsString)
            
            saveString = Story.quiz.saveToString
            # optionsString has a trailing \n but the resetVocab 
            # starts with a \n so I have to chop one out.
            saveString.should eql(Story.sampleQuiz.header + Story.sampleQuiz.info + 
                                  "\n" + optionsString.chop + 
                                  Story.sampleQuiz.resetVocab +
                                  "Fair\nGood\nExcellent\n")
        end

        it "should show that the quiz needs saving if certain options are changed" do
            # Currently the file needs to be saved as soon as it is loaded
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # ReviewMeaning
            Story.quiz.options.reviewMeaning = false
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)
        end

        it "shouldn't need to save if the options are changed to their current value" do
            Story.quiz.setNeedsSave(false)
            Story.quiz.options.reviewMeaning = true
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
            Story.quiz.options.reviewOptionsSet = false
            Story.quiz.options.reviewMeaning = true
            Story.quiz.options.reviewOptionsSet.should eql(true)
        end
    end
end
