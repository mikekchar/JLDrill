require 'Context/Context'
require 'Context/View'

# These are some useful fakes for testing with

module JLDrill::Fakes
    class View < Context::View
        def initialize(context)
            super(context)
            @widget = Widget.new(nil)
        end

        def getWidget
            return @widget
        end            
    end

    class App < Context::Context
        def intitialize(bridge)
            super(bridge)
            @mainView = View.new
        end
    end
end

module Context::Gtk

    # Hopefully this will turn off the drawing of the widgets in the tests
    def Widget::inTests
        true
    end

end
