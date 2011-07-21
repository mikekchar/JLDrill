# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/contexts/GetFilenameContext'
require 'gtk2'

module JLDrill::Gtk
    class SelectorWindow < Gtk::FileChooserDialog
        include Context::Gtk::Widget

        attr_reader :chosenFilename, :chosenDirectory
        attr_writer :chosenFilename, :chosenDirectory
    
        def initialize(type)
            @chosenFilename = nil
            @chosenDirectory = nil
            if (type == JLDrill::GetFilenameContext::SAVE)
                super("Save File", nil,
                      Gtk::FileChooser::ACTION_SAVE, nil,
                      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                      [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
            else
                super("Open File", nil,
                      Gtk::FileChooser::ACTION_OPEN, nil,
                      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                      [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
            end
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
                return @chosenFilename
            else
                return nil
            end
        end
    end	    
end
