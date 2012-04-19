# encoding: utf-8
require 'jldrill/spec/StoryMemento'
require 'jldrill/spec/SampleQuiz'
require 'jldrill/spec/storyFunctionality/Gtk'
require 'jldrill/spec/storyFunctionality/SampleQuiz'
require 'jldrill/model/quiz/Options'
require 'jldrill/model/Config'
require 'jldrill/views/test/MainWindowView'
require 'jldrill/views/test/CommandView'
require 'jldrill/views/test/ProblemView'
require 'jldrill/views/test/QuizStatusView'
require 'jldrill/views/test/ItemHintView'

module JLDrill::UserChangesOptions

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

    Story = MyStory.new("User Changes Options Story")

    describe Story.stepName("Options are stored and read") do
        before(:each) do
            Story.setup(JLDrill::Test)
            Story.start
            Story.quiz.options.randomOrder.should eql(false)
            Story.quiz.options.promoteThresh.should eql(2)
            Story.quiz.options.introThresh.should eql(10)
            Story.quiz.options.reviewMode.should eql(false)
			Story.quiz.options.dictionary.should be_nil
            Story.quiz.options.autoloadDic.should eql(false)
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
            Story.quiz.resetContents
            saveString = Story.quiz.saveToString
            saveString.should eql(Story.sampleQuiz.defaultSaveFile)
        end

        it "should store changed options" do
            Story.quiz.options.randomOrder = true
            Story.quiz.options.promoteThresh = 4
            Story.quiz.options.introThresh = 20
            Story.quiz.options.reviewMode = true

            # Note that the reviewMode isn't saved
            optionsString = "Random Order\n" +
                "Promotion Threshold: 4\n" +
                "Introduction Threshold: 20\n" +
                "Review Meaning\n" +
                "Review Kanji\n"
            Story.quiz.options.to_s.should eql(optionsString)
            
            saveString = Story.quiz.saveToString
            # optionsString has a trailing \n but the resetVocab 
            # starts with a \n so I have to chop one out.
            saveString.should eql(Story.sampleQuiz.header + Story.sampleQuiz.info + 
                                  "\n" + optionsString.chop + 
                                  Story.sampleQuiz.resetVocab +
                                  "Review\nForgotten\n")
        end

        it "should show that the quiz needs saving if certain options are changed" do
            # Currently the file needs to be saved as soon as it is loaded
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # Random order
            Story.quiz.options.randomOrder = true
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # Promote threshold
            Story.quiz.options.promoteThresh = 4
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # Intro Threshold
            Story.quiz.options.introThresh = 20
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)

            # Review mode doesn't need saving
            Story.quiz.options.reviewMode = true
            Story.quiz.needsSave.should eql(false)

            # Dictionary Language
            Story.quiz.options.language = "Chinese"
            Story.quiz.needsSave.should eql(true)
            Story.quiz.setNeedsSave(false)
            Story.quiz.needsSave.should eql(false)
        end

        it "shouldn't need to save if the options are changed to their current value" do
            Story.quiz.setNeedsSave(false)
            Story.quiz.options.randomOrder = false
            Story.quiz.needsSave.should eql(false)
            Story.quiz.options.promoteThresh = 2
            Story.quiz.needsSave.should eql(false)
            Story.quiz.options.introThresh = 10
            Story.quiz.needsSave.should eql(false)
            Story.quiz.options.language = "Japanese"
            Story.quiz.needsSave.should eql(false)
        end

        it "should load a file with different options" do
            optionsString = "Random Order\n" +
                "Promotion Threshold: 4\n" +
                "Introduction Threshold: 20\n" +
                "Language: Chinese\n" +
                "Review Meaning\n" +
                "Review Kanji\n" 
            fileString = Story.sampleQuiz.header + Story.sampleQuiz.info + "\n" +
                optionsString.chop + Story.sampleQuiz.resetVocab +
                "Review\n"
            Story.quiz.loadFromString("nothing", fileString)
            Story.quiz.options.to_s.should eql(optionsString)
            Story.quiz.options.randomOrder.should eql(true)
            Story.quiz.options.promoteThresh.should eql(4)
            Story.quiz.options.introThresh.should eql(20)
            Story.quiz.options.language.should eql("Chinese")
        end

        it "should be able to assign the options to another options object" do
            optionsString = "Random Order\n" +
                "Promotion Threshold: 1\n" + "Introduction Threshold: 20\n" +
                "Review Meaning\n" +
                "Review Kanji\n"# +
#                "Autoload Dictionary\n"
	        Story.quiz.options.randomOrder = true
	        Story.quiz.options.promoteThresh = 1
	        Story.quiz.options.introThresh = 20
#            Story.quiz.options.autoloadDic = true
            Story.quiz.options.to_s.should eql(optionsString)

            newOptions = JLDrill::Options.new(nil)
            newOptions.to_s.should_not be_eql(optionsString)
            newOptions.assign(Story.quiz.options)
            newOptions.to_s.should be_eql(optionsString)
        end	    

        it "should add and remove problem schedule types when options change" do
            item = Story.quiz.contents.workingSet[0]
            item.should_not be_nil
            item.state.level = 3
            item.state.promote()

            # Sort the schedules by duration so that I can keep track
            # of which one is which.
            schedules = item.state.schedules.sort do |x, y|
                x.duration <=> y.duration
            end
            schedules.size.should eql(2)

            # Adjust the schedules so that 10 seconds has passed.
            # Otherwise the results can depend on whether or not the clock
            # has ticked over.
            rt = Time::at(Time::now.to_i - 10)

            schedules[0].should be_scheduled
            schedules[0].lastReviewed = rt
            d1 = schedules[0].duration
            schedules[1].should be_scheduled
            schedules[1].lastReviewed = rt
            d2 = schedules[1].duration

           Story.quiz.options.reviewKanji.should be_true
           Story.quiz.options.reviewMeaning.should be_true
           Story.quiz.options.reviewReading.should be_false
           Story.quiz.options.reviewReading = true
           Story.quiz.options.reviewReading.should be_true
           Story.quiz.options.reviewKanji.should be_true
           Story.quiz.options.reviewMeaning.should be_true

           # When adding the new schedule it uses information
           # from the schedule with the lowest reviewLoad.  Since
           # no time has passed since we scheduled, this will be
           # the one with the shortest duration.  Hence, there will
           # be two items with the lowest duration and one with the
           # higher duration.
            schedules = item.state.schedules.sort do |x, y|
                x.duration <=> y.duration
            end
           schedules.size.should eql(3)
           schedules[0].duration.should eql(d1)
           schedules[1].duration.should eql(d1)
           schedules[2].duration.should eql(d2)
           
           Story.quiz.options.reviewReading = false
           Story.quiz.options.reviewReading.should be_false
           Story.quiz.options.reviewKanji.should be_true
           Story.quiz.options.reviewMeaning.should be_true

            schedules = item.state.schedules.sort do |x, y|
                x.duration <=> y.duration
            end
            schedules.size.should eql(2)
           schedules[0].duration.should eql(d1)
           schedules[1].duration.should eql(d2)

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

		it "should destroy the options Window when it closes" do
			Story.view.should_receive(:destroy) do
			    Story.view.optionsWindow.destroy
			end
   		    Story.pressOKAfterEntry(Story.view.optionsWindow)
            Story.context.enter(Story.mainContext)
		end

        it "should be able to run twice" do
            firstView = Story.view
   		    Story.pressOKAfterEntry(Story.view.optionsWindow)
            Story.context.enter(Story.mainContext)
            Story.getNewView
            secondView = Story.view
            # This is the main point.  We need to create a new view every
            # time the context is entered, otherwise it won't work.
            firstView.should_not be(secondView)
            # Do it just to be sure it worked.  If it doesn't Gtk will complain.
   		    Story.pressOKAfterEntry(Story.view.optionsWindow)
            Story.context.enter(Story.mainContext)
        end

        def setValueAndTest(valueString, default, target)
            modelString = "Story.mainContext.quiz.options." + valueString
            setUIString = "Story.view.optionsWindow." + valueString + " = " + 
                           target.to_s 
            eval(modelString).should eql(default)
   		    Story.pressOKAfterEntry(Story.view.optionsWindow) do
                eval(setUIString)
            end
            Story.context.enter(Story.mainContext)
            eval(modelString).should eql(eval("#{target}"))
        end

        it "should be able to set the Random Order option" do
            setValueAndTest("randomOrder", false, true)
        end

        it "should be able to set the Promote Threshold option" do
            setValueAndTest("promoteThresh", 2, 1)
        end

        it "should be able to set the Intro Threshold option" do
            setValueAndTest("introThresh", 10, 20)
        end

        it "should be able to set the language option" do
            setValueAndTest("language", "Japanese", "\"Chinese\"")
        end

        # Autoload Dictionary is not tested because it will load the
        # dictionary, which makes the tests too slow.
    end
end
