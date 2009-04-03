require 'Context/Bridge'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/views/gtk/OptionsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/spec/StoryMemento'

module JLDrill::Gtk

	describe OptionsView do

        before(:all) do
            @story = JLDrill::StoryMemento.new("FilenameSelectorView")
            @OK = Gtk::Dialog::RESPONSE_ACCEPT
            @CANCEL = Gtk::Dialog::RESPONSE_CANCEL

            def @story.setup(type)
                super(type)
                @context = @mainContext.setOptionsContext
                @view = @context.peekAtView
            end
        end
		    	
		it "should default to the quiz's options" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
		    @story.mainContext.quiz.options.randomOrder = true
		    @story.mainContext.quiz.options.promoteThresh = 3
		    @story.mainContext.quiz.options.introThresh = 20
		    
		    quizOptions = @story.mainContext.quiz.options.clone

            existingOptions = JLDrill::Options.new(nil)
   		    existingOptions.randomOrder = false
   		    existingOptions.promoteThresh = 4
   		    existingOptions.introThresh = 15
   		    @story.view.optionsWindow.set(existingOptions)
   		    
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK)
   		    @story.view.options.should be_eql(quizOptions)
   		    @story.shutdown
		end
				
        it "should automatically exit the context after entry" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
            @story.context.should_receive(:exit) do
                @story.view.destroy
            end
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK)
            @story.mainContext.exit
        end

		it "should destroy the options Window when it closes" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
			@story.view.should_receive(:destroy) do
			    @story.view.optionsWindow.destroy
			end
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK)
			@story.shutdown
		end

        it "should be able to run twice" do
		    @story.setup(JLDrill::Gtk)
		    @story.start
            firstView = @story.view
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK)
            @story.getNewView
            secondView = @story.view
            # This is the main point.  We need to create a new view every
            # time the context is entered, otherwise it won't work.
            firstView.should_not be(secondView)
            # Do it just to be sure it worked.  If it doesn't Gtk will complain.
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK)
            @story.shutdown
        end
        
        def test_setValue(valueString, default, target)
		    @story.setup(JLDrill::Gtk)
		    @story.start
            eval("@story.mainContext.quiz.options." + valueString).should be(default)
   		    @story.enterAndPressButton(@story.view.optionsWindow, @OK) do
                eval("@story.view.optionsWindow." + valueString + " = " + target.to_s)
            end
            eval("@story.mainContext.quiz.options." + valueString).should be(target)
            @story.shutdown
        end
        
        it "should be able to set the Random Order option" do
            test_setValue("randomOrder", false, true)
        end

        it "should be able to set the Promote Threshold option" do
            test_setValue("promoteThresh", 2, 1)
        end

        it "should be able to set the Intro Threshold option" do
            test_setValue("introThresh", 10, 20)
        end

	end
end
