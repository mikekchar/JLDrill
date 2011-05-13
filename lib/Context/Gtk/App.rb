require 'Context/Bridge'
require 'Context/Context'
require 'gtk2'

module Context::Gtk
	class App < Context::Context

		attr_reader :mainContext

		def initialize(namespace, context)
			viewBridge = Context::Bridge.new(namespace)
			super(viewBridge)
			Gtk.init
			@mainContext = context.new(viewBridge)
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
