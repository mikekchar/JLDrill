require 'Context/Views/Gtk/Widgets/VBox'
require 'Context/View'
require 'gtk2'

module JLDrill::Gtk

    class VBoxView < Context::View

        def initialize(context)
            super(context)
            @widget = Context::Gtk::VBox.new
        end

        def getWidget
            @widget
        end
    end
end
