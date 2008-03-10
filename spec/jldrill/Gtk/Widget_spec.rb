require 'Gtk/Widget.rb'

module JLDrill:Gtk 

	describe Widget do

		it "should add and show the widget when add is called." do
			widget = JLDrill::Gtk::Widget.new(mock("Gtk::Widget"))
			newWidget = JLDrill::Gtk::Widget.new(mock("Gtk::Widget"))
			widget.delegate.should_receive(:add).with(newWidget.delegate)
			widget.delegate.should_receive(:show_all)
			widget.add(newWidget)
		end
	end
end
