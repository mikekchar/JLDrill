require 'jldrill/MainContext'
require 'jldrill/Gtk/ViewFactory'
require 'gtk2'

module JLDrill::Gtk

	# This is Context that starts the application running.
	class StartupContext < JLDrill::Context

		attr_reader :mainContext, :viewFactory

		def initialize
			viewFactory = ViewFactory.new
			super(viewFactory)
			Gtk.init
			@mainContext = JLDrill::MainContext.new(viewFactory)
		end
	
		def enter
			super(nil)
			@mainContext.enter(self)
			Gtk.main
		end
	
		def exit
			super()
			Gtk.main_quit
		end
	end
end


