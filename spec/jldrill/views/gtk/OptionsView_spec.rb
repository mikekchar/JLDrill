require 'Context/ViewFactory'
require 'jldrill/contexts/SetOptionsContext'
require 'jldrill/views/gtk/OptionsView'
require 'jldrill/contexts/MainContext'
require 'jldrill/views/gtk/MainWindowView'
require 'jldrill/views/gtk/ReferenceProgressView'
require 'jldrill/model/Quiz/Quiz'

module JLDrill::Gtk

	describe OptionsView do

		before(:each) do
		    factory = Context::ViewFactory.new(JLDrill::Gtk)
		    @main = JLDrill::MainContext.new(factory)
            @main.quiz = JLDrill::Quiz.new
			@context = @main.setOptionsContext

            # Creates the main view and returns it
            def @context.peakAtView
                createViews
                @mainView
            end
			
			# Makes it so the view is only created if it isn't there
			# there already.  This allowed us to peak at the view
			# ahead of time.
    		def @context.createViews
    		    if @mainView.nil?
    		        super
    		    end
    		end
    		
    		# Make sure the main view is set to nil so that our
    		# createViews substitute works properly.
    		def @context.destroyViews
    		    @mainView = nil
    		end
		end

        # Overrides the method on the object with the closure
        # that's passed in.
        def override_method(object, method, &block)
            class << object
                self
            end.send(:define_method, method, &block)
        end
		
		# Set up for context.enter.  Returns the view that will be used
		def test_getViewForEnter
            mainViewWidget = @main.mainView.getWidget
            view = @context.peakAtView
			view.optionsWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			view.optionsWindow.should_receive(:show_all)
			view
		end

        # Make the modal dialog run as if the OK button was pressed.	
	    def test_runOK(view)
            override_method(view.optionsWindow, :run) do
                Gtk::Dialog::RESPONSE_ACCEPT
            end	    
	    end
	    	
		it "should set the options on OK" do
            view = test_getViewForEnter
            test_runOK(view)
            @main.quiz.options.should_receive(:assign).with(view.options)
            @context.enter(@main)
		end
				
		it "should open a options window transient on the main window when opened" do
            view = test_getViewForEnter
            test_runOK(view)
            @context.enter(@main)
		end

        it "should automatically exit the context after entry" do
            view = test_getViewForEnter
            test_runOK(view)
            @context.should_receive(:exit)
            @context.enter(@main)
        end

		it "should destroy the options Window when it closes" do
            view = test_getViewForEnter
            test_runOK(view)
			view.optionsWindow.should_receive(:destroy)
			# Note: The context automatically exits after entry
            @context.enter(@main)
		end

        it "should be able to run twice" do
            view = test_getViewForEnter
            test_runOK(view)
            @context.enter(@main)
            # The view exits the context after being opened
            @context.mainView.should be_nil
            view = test_getViewForEnter
            test_runOK(view)
            @context.enter(@main)
        end
        
        it "should be able to set the Random Order option" do
            @main.quiz.options.randomOrder.should be(false)
            view = test_getViewForEnter
            override_method(view.optionsWindow, :run) do
                view.optionsWindow.random.active = true
                Gtk::Dialog::RESPONSE_ACCEPT
            end
            @context.enter(@main)
            @context.quiz.options.randomOrder.should be(true)            
        end
        
	end
end
