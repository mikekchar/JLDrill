require 'jldrill/contexts/MainContext'
require 'Context/Bridge'

module JLDrill

	describe MainContext do

		before(:each) do
			@context = MainContext.new(Context::Bridge.new(JLDrill))
		end

        def test_openMainView
		    @parent = mock("App")
		    @parent.should_receive(:addView)
		    @context.mainView.should_receive(:open)
		    @context.enter(@parent)        
        end
		
		it "should open the main view when it is entered" do
            test_openMainView
		end

		it "should exit the App when it is exited" do
            test_openMainView
		    @parent.should_receive(:exit)
		    @context.exit
		end

		it "should exit the App when it is closed" do
            test_openMainView
		    @parent.should_receive(:exit)
		    @context.close
		end
	end
end
