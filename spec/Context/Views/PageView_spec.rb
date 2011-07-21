# encoding: utf-8
require 'Context/Bridge'
require 'Context/Context'
require 'Context/Views/PageView'

module Context

	describe PageView do

		before(:each) do
		    @bridge = Bridge.new(Context)
			@context = Context.new(@bridge)
			@view = @bridge.PageView.new(@context)
		end
		
		it "should close the context when the view is closed" do
		    @context.should_receive(:close)
		    @view.close
		end
    end
end
