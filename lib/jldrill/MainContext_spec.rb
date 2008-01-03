require 'MainContext'
require 'ViewFactory'

module JLDrill

	describe MainContext do
		before do
			@context = MainContext.new(ViewFactory.new)
		end
	  
		before(:each) do
		end
		
		after(:each) do
		end  
		
		it "should exit the parent context when it exits" do
			@startup = mock("StartupContext")
			@startup.should_receive(:addView).with(an_instance_of(MainWindowView))
			@context.enter(@startup)
			@startup.should_receive(:exit)
			@context.exit			
		end
		
		it "should have a main window view as the mainView" do
			@context.mainView.should be_an_instance_of(MainWindowView)
		end
	end
end
