require 'Context'
require 'ViewFactory'
require 'View'

module JLDrill

	describe Context do

		before(:each) do
			@context = Context.new(ViewFactory.new)
			@context.mainView = View.new(@context)
		end
		
		it "should not have a parent set on creation" do
			@context.parent.should be_nil
		end
		
		it "should set the parent on entry" do
			parent = mock("MainContext")
			parent.should_receive(:addView)
			@context.enter(parent)
			@context.parent.should equal(parent)
		end
		
		it "should add new views to the main view on entry" do
			newContext = Context.new(ViewFactory.new)
			newContext.mainView = View.new(newContext)
			@context.mainView.should_receive(:addView).with(newContext.mainView)

			newContext.enter(@context)
		end
		
		it "should remove the main view on exit" do
			newContext = Context.new(ViewFactory.new)
			newContext.mainView = View.new(newContext)
			@context.mainView.should_receive(:addView).with(newContext.mainView)
			@context.mainView.should_receive(:removeView).with(newContext.mainView)
			
			newContext.enter(@context)
			newContext.exit()
		end
		
		it "should do nothing when exiting a context with no parent" do
			@context.exit()
		end
		
	end
	
end
