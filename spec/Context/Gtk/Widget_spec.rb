# encoding: utf-8
require 'Context/Gtk/Widget.rb'

module Context::Gtk 

	describe Widget do

        class FakeWidget
            include Widget
        end

        before(:each) do
			@widget = FakeWidget.new()
			@newWidget = FakeWidget.new()  
 			@oldWidget = FakeWidget.new()
       end

        it "should keep track of the main Window" do
            @widget.gtkWidgetMainWindow.should be_nil
            @widget.isAMainWindow
            @widget.gtkWidgetMainWindow.should be_eql(@widget)

			@widget.should_receive(:gtkAddWidget).with(@newWidget)
			@widget.addToThisWidget(@newWidget)
            @newWidget.gtkWidgetMainWindow.should be_eql(@widget)

			@widget.should_receive(:gtkRemoveWidget).with(@newWidget)
			@widget.removeFromThisWidget(@newWidget)            
            @newWidget.gtkWidgetMainWindow.should be_nil
        end
	end
end
