require 'Context/Bridge'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/views/gtk/OptionsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/spec/Fakes'

module JLDrill::Gtk

	describe OptionsView do
	
		class OptionsViewStoryMemento
            attr_reader :mainContext, :mainView, :context, :view
        
            def initialize
                restart
            end
            
            def restart
                @app = nil
                @mainContext = nil
                @mainView = nil
                @context = nil
                @view = nil
            end
            
            # Some useful routines
            def setup
                @app = JLDrill::Fakes::App.new(nil)
                @mainContext = JLDrill::MainContext.new(Context::Bridge.new(JLDrill::Gtk))
                @mainContext.enter(@app)
                @mainView = @mainContext.mainView
                @context = @mainContext.setOptionsContext
                @view = @context.peekAtView
            end
            
            def getNewView
                @view = @context.peekAtView
            end
            
            # This is very important to call when using setup because otherwise
            # you will leave windows hanging open.
            def shutdown
                @view.close unless @view.nil?
                @mainView.close unless @mainView.nil?
                restart
            end

            # Overrides the method on the object with the closure
            # that's passed in.
            def override_method(object, method, &block)
                class << object
                    self
                end.send(:define_method, method, &block)
            end

            # Make the modal dialog run as if the OK button was pressed.	
	        def enterAndPressOK(&block)
                override_method(@view.optionsWindow, :run) do
                    if !block.nil?
                        block.call
                    end
                    Gtk::Dialog::RESPONSE_ACCEPT
                end
                @context.enter(@mainContext)
	        end

            # Make the modal dialog run as if the CANCEL button was pressed.	
	        def enterAndPressCANCEL(&block)
                override_method(@view.selectorWindow, :run) do
                    if !block.nil?
                        block.call
                    end
                    Gtk::Dialog::RESPONSE_CANCEL
                end
                @context.enter(@mainContext)
	        end
        end
        
        before(:all) do
            @story = OptionsViewStoryMemento.new
        end
	    	
		it "should default to the quiz's options" do
		    @story.setup
		    @story.mainContext.quiz.options.randomOrder = true
		    @story.mainContext.quiz.options.promoteThresh = 3
		    @story.mainContext.quiz.options.introThresh = 20
		    @story.mainContext.quiz.options.strategyVersion = 1
		    
		    quizOptions = @story.mainContext.quiz.options.clone

            existingOptions = JLDrill::Options.new(nil)
   		    existingOptions.randomOrder = false
   		    existingOptions.promoteThresh = 4
   		    existingOptions.introThresh = 15
   		    existingOptions.strategyVersion = 0
   		    @story.view.optionsWindow.set(existingOptions)
   		    
   		    @story.enterAndPressOK 
   		    @story.view.options.should be_eql(quizOptions)
   		    @story.shutdown
		end
				
        it "should automatically exit the context after entry" do
            @story.setup
            @story.context.should_receive(:exit) do
                @story.view.destroy
            end
            @story.enterAndPressOK
            @story.mainContext.exit
        end

		it "should destroy the options Window when it closes" do
		    @story.setup
			@story.view.should_receive(:destroy) do
			    @story.view.optionsWindow.destroy
			end
			@story.enterAndPressOK
			@story.shutdown
		end

        it "should be able to run twice" do
            @story.setup
            firstView = @story.view
            @story.enterAndPressOK
            @story.getNewView
            secondView = @story.view
            # This is the main point.  We need to create a new view every
            # time the context is entered, otherwise it won't work.
            firstView.should_not be(secondView)
            # Do it just to be sure it worked.  If it doesn't Gtk will complain.
            @story.enterAndPressOK
            @story.shutdown
        end
        
        def test_setValue(valueString, default, target)
            @story.setup
            eval("@story.mainContext.quiz.options." + valueString).should be(default)
            @story.enterAndPressOK do
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

        it "should be able to set the Strategy Version option" do
            test_setValue("strategyVersion", 0, 1)
        end
        
	end
end
