require 'MainWindowView'
require 'ViewFactory'

module JLDrill

	describe MainWindowView do
	
		before(:each) do
			@context = mock("Context")
			
			# Creating it this way to ensure that the factory method exists
			@factory = ViewFactory.new
			@view = @factory.createMainWindowView(@context)
		end

		it "should do nothing when the window is opened" do
			@view.open
		end
		
		it "should exit the context when the window is closed" do
			@context.should_receive(:exit)
			@view.close
		end

	end

end
