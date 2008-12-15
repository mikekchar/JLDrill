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
			@block = nil
			@id = nil
		end
		
		def getWidget
			@widget
		end
		
		def destroy
		    @progressWindow.destroy
		end
		
		def update(fraction)
		    @progressWindow.update(fraction)
		end
		
		def run
		    fraction = @block.call
		    if fraction < 1.0
    		    update(fraction)
    		else
    		    if !@id.nil?
    		        Gtk.idle_remove(@id)
		            @id = nil
		            @block = nil
		            self.exit
		        end
		    end
		end
		
		def idle_add(&block)
		    if @block.nil? && @id.nil?
		        @block = block
		        @id = Gtk.idle_add do run end
		    end
		end
    end
    
end

