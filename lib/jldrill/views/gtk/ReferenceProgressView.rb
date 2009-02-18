require 'jldrill/views/gtk/widgets/ProgressWindow'
require 'jldrill/views/ReferenceProgressView'
require 'gtk2'

module JLDrill::Gtk

	class ReferenceProgressView < JLDrill::ReferenceProgressView
	
        attr_reader :progressWindow
        	
		def initialize(context)
			super(context)
			@progressWindow = ProgressWindow.new(self)
			@block = nil
			@id = nil
		end
		
		def getWidget
			@progressWindow
		end
		
		def destroy
		    @progressWindow.destroy
		end
		
		def update(fraction)
		    @progressWindow.update(fraction)
		end
		
		def run
		    if @block.call
    		    if !@id.nil?
    		        Gtk.idle_remove(@id)
		            @id = nil
		            @block = nil
		            self.exit
		        end
                return false
            else
                return true
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

