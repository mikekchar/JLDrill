require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class SelectorWindow < Gtk::FileChooserDialog
        include Context::Gtk::Widget

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

        def gtkAddWidget(widget)
            # We currently can't add widgets to this bar. Silently fail.
        end
        
        def gtkRemoveWidget(widget)
            # We currently can't remove widgets from this bar. Silently fail.
        end
    end	    
end
