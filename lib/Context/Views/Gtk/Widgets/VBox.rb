# encoding: utf-8
require 'Context/Gtk/Widget'
require 'gtk2'

module Context::Gtk

    # Container class for making vertical lists of widgets.
    # The primary purpose of this class is to create a container
    # that respects the packing hints in the Widget mixin.
    # Something tells me that needing this class means 
    # something is screwed up somewhere...
    class VBox < Gtk::VBox
        include Context::Gtk::Widget

        def initialize
            super
            setupWidget
        end
        
        def gtkAddWidget(widget)
            pack_start(widget,
                       widget.expandWidgetHeight?, 
                       widget.expandWidgetWidth?)
        end
        
        def gtkRemoveWidget(widget)
            remove(widget)
        end
    end
end    
