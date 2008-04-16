require 'Context/Gtk/Widget'
require 'jldrill/views/ReferenceProgressView'
require 'gtk2'

module JLDrill::Gtk

	class ReferenceProgressView < JLDrill::MainWindowView
	
		class ProgressWindow < Gtk::Window
		
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
		    
		    def open(parentWindow)
		        set_transient_for(parentWindow)
		        window_position = Gtk::Window::POS_CENTER_ON_PARENT
                show_all
            end		    
		    
		    def close
		        destroy
		    end
        end
    
        attr_reader :progressWindow
        	
		def initialize(context)
			super(context)
			@progressWindow = ProgressWindow.new(self)
			@widget = Context::Gtk::Widget.new(@progressWindow)
		end
		
		def open
			@progressWindow.open(context.parent.mainView.getWidget.delegate)
		end
		
		def close
		    @progressWindow.close
		end
				
		def getWidget
			@widget
		end
		
		def update(fraction)
		    @progressWindow.update(fraction)
		end
    end
    
end

