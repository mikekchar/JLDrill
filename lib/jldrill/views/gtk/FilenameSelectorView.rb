require 'Context/Gtk/Widget'
require 'jldrill/views/FilenameSelectorView'
require 'gtk2'

module JLDrill::Gtk

	class FilenameSelectorView < JLDrill::FilenameSelectorView

        class SelectorWindow < Gtk::FileChooserDialog

	        attr_reader :chosenFilename, :chosenDirectory
	        attr_writer :chosenFilename, :chosenDirectory

	        def initialize()
	            @chosenFilename = nil
	            @chosenDirectory = nil
		        super("Open File", nil,
				        Gtk::FileChooser::ACTION_OPEN, nil,
				        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
				        [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
	        end
	        
	        # The following 2 routines are only here because I couldn't
	        # figure out a way to set the filename and folder in my tests.
	        def getFilename
	            self.filename
	        end
	        
	        def getCurrentFolder
	            self.current_folder
	        end
	
	        def execute
		        if run == Gtk::Dialog::RESPONSE_ACCEPT
		            @chosenFilename = getFilename
		            @chosenDirectory = getCurrentFolder
		            @chosenFilename
		        else
		            nil
		        end
	        end

        end	    
        attr_reader :selectorWindow
        	
		def initialize(context)
			super(context)
			@selectorWindow = SelectorWindow.new()
			@widget = Context::Gtk::Widget.new(@selectorWindow)
		end
		
		def getWidget
			@widget
		end

        def run
            @selectorWindow.current_folder = @directory unless @directory.nil?
            retVal = @selectorWindow.execute
            @filename = @selectorWindow.chosenFilename
            @directory = @selectorWindow.chosenDirectory
            retVal
        end
    end
end

