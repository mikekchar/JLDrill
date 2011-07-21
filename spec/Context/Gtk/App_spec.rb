# encoding: utf-8
require 'Context/Gtk/App'
require 'gtk2'

module Context::Gtk

	describe App do

		before(:each) do
			Gtk.should_receive(:init)
			@app = App.new(Context::Gtk, Context::Context)
		end
		
		it "should start the Gtk main loop when run" do
			Gtk.should_receive(:main)
			@app.mainContext.should_receive(:enter)
			@app.enter
		end
		
		it "should quit the Gtk main loop when quit" do
			Gtk.should_receive(:main_quit)
			@app.exit
		end
	end
end
