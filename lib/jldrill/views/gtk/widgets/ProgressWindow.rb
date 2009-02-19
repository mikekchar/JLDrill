require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class ProgressWindow < Gtk::Window
		include Context::Gtk::Widget
        
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
end
