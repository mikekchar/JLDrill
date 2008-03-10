require 'jldrill/Gtk/StartupContext'
require 'jldrill/Gtk/MainWindowView'

module JLDrill::Gtk

	describe StartupContext do

		before(:each) do
			Gtk.should_receive(:init)
			@startup = StartupContext.new
		end
		
		it "should start the Gtk main loop when run" do
			Gtk.should_receive(:main)
			@startup.mainContext.should_receive(:enter)
			@startup.enter
		end
		
		it "should quit the Gtk main loop when quit" do
			Gtk.should_receive(:main_quit)
			@startup.exit
		end
		
		it "should have a ViewFactory that creates Gtk type Views" do
			@startup.viewFactory.should be_an_instance_of(JLDrill::Gtk::ViewFactory)
			@startup.viewFactory.createMainWindowView(@startup).should be_an_instance_of(JLDrill::Gtk::MainWindowView)
		end
		
	end

end
