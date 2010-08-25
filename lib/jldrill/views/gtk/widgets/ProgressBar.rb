require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class ProgressBar < Gtk::HBox
		include Context::Gtk::Widget
        
        attr_reader :progress
		
        def initialize(view)
            super
            @view = view
            
            @progress = Gtk::ProgressBar.new
            self.add(Gtk::Label.new("Loading Dictionary:"))
            self.add(@progress)
        end
        
        def update(fraction)
            @progress.fraction = fraction
        end
    end
end
