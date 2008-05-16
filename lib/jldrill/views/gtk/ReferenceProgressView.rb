require 'Context/Gtk/Widget'
require 'jldrill/views/ReferenceProgressView'
require 'gtk2'

module JLDrill::Gtk

	class ReferenceProgressView < JLDrill::ReferenceProgressView
	
		class ProgressWindow < Gtk::Window
		
		    attr_reader :progress
		
		    def initialize(view)
		        @view = view
		        super("Loading Dictionary")
                vbox = Gtk::VBox.new()
                add(vbox)

                @progress = Gtk::ProgressBar.new()
                vbox.add(@progress)
		    end
		    
		    def update(fraction)
		        @progress.fraction = fraction
		    end
        end
    
        attr_reader :progressWindow
        	
		def initialize(context)
			super(context)
			@progressWindow = ProgressWindow.new(self)
			@widget = Context::Gtk::Widget.new(@progressWindow)
		end
		
		def getWidget
			@widget
		end
		
		def update(fraction)
		    @progressWindow.update(fraction)
		end
    end
    
end

