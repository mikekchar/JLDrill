require 'jldrill/contexts/LoadReferenceContext'
require 'jldrill/views/gtk/widgets/ProgressBar'
require 'gtk2'

module JLDrill::Gtk

	class FileProgress < JLDrill::LoadReferenceContext::FileProgress
	
        attr_reader :progressWindow
        	
		def initialize(context)
			super(context)
			@progressBar = ProgressBar.new(self)
            @progressBar.expandWidgetWidth
			@block = nil
			@id = nil
		end
		
		def getWidget
			@progressBar
		end
	
		def filename
			return @context.getFilename
		end

		def update(fraction)
		    @progressBar.update(fraction)
		end
		
		def run
		    if @block.call
    		    if !@id.nil?
    		        Gtk.idle_remove(@id)
		            @id = nil
		            @block = nil
		            @context.exit
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

