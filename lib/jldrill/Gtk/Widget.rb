require 'jldrill/Widget'
require 'gtk2'

module JLDrill::Gtk

	# This is a concrete Gtk version of the Widget class.
	# It merely delegates a few functions so that code does
	# not need to be duplicated at the concrete UI library layer.
	class Widget < JLDrill::Widget
	
		# Add one widget to the next.  This merely adds the
		# Gtk widget to the other one (assuming it is a container)
		# and shows the result.  No effort at packing is done.
		def add(widget)
			@delegate.add(widget.delegate)
			@delegate.show_all
		end
	end

end
