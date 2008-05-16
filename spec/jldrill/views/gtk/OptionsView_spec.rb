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
			@context = @main.setOptionsContext

            def @context.peakAtView
                createViews
                @mainView
            end
			
    		def @context.createViews
    		    if @mainView.nil?
    		        super
    		    end
    		end
    		
    		def @context.destroyViews
    		    @prev = @mainView
    		    @mainView = nil
    		end
		end
		
		def test_getViewForEnter(ok=false)
		    if ok then
		        ret = Gtk::Dialog::RESPONSE_ACCEPT
		    else
		        ret = Gtk::Dialog::RESPONSE_CANCEL
		    end
            mainViewWidget = @main.mainView.getWidget
            view = @context.peakAtView
			view.optionsWindow.should_receive(:set_transient_for).with(mainViewWidget.delegate)
			view.optionsWindow.should_receive(:show_all)
			view.optionsWindow.should_receive(:run).and_return(ret)
			view
		end
		
		it "should set the options on OK" do
            @main.quiz = JLDrill::Quiz.new
            view = test_getViewForEnter(true)
            @main.quiz.options.should_receive(:assign).with(view.options)
            @context.enter(@main)
		end
				
		it "should open a options window transient on the main window when opened" do
            @main.quiz = JLDrill::Quiz.new
            view = test_getViewForEnter
			view.should_receive(:exit)
            @context.enter(@main)
		end
	
        it "should destroy the progress window when closed" do
            view = @context.peakAtView
            view.optionsWindow.should_receive(:destroy)
            view.close
        end
        
        it "should be able to run twice" do
            @main.quiz = JLDrill::Quiz.new
            view = test_getViewForEnter
            @context.enter(@main)
            # The view exits the context after being opened
            @context.mainView.should be_nil
            view = test_getViewForEnter
            @context.enter(@main)
        end
        
	end
end
