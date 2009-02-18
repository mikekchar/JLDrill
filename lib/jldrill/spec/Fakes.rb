require 'Context/Context'
require 'Context/View'
require 'Context/Bridge'
require 'Context/Gtk/Widget'

# These are some useful fakes for testing with

module JLDrill
    module Fakes
        # This is a fake App that doesn't start up the GTK
        # initialization.  That way the main run look doesn't
        # get started.
        class App < Context::Context
            attr_reader :mainContext
            
            def initialize(bridgeClass, mainContextClass)
                bridge = Context::Bridge.new(bridgeClass)
                super(bridge)
                @mainContext = mainContextClass.new(bridge)
                @mainContext.inTests = true
            end
            
            def enter
                super(nil)
                @mainContext.enter(self)
            end
        end
    end
end

module Context::Gtk::Widget

    # This will turn off the drawing of the widgets in the tests
    def isInTests?
        true
    end

end
