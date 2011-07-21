# encoding: utf-8
require 'gtk2'

module JLDrill::Gtk

    class GtkEnterFilename < Gtk::FileChooserDialog

        attr_reader :resp

        def initialize(directory,mainWindow)
            super("Save File",
                  mainWindow,
                  Gtk::FileChooser::ACTION_SAVE,
                  nil,
                  [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                  [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])
            @resp = Gtk::Dialog::RESPONSE_CANCEL
            self.current_folder = "/home/mike/Desktop"
            print self.filename
            print "\n"
            print self.current_folder
            print "\n"
        end
        
        def run
            @resp = super()
            if @resp == Gtk::Dialog::RESPONSE_ACCEPT
                return filename
            else
                return ""
            end
        end

    end
end
