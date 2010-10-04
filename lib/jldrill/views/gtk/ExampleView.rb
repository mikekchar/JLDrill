require 'jldrill/views/gtk/widgets/ExampleWindow.rb'
require 'jldrill/views/ExampleView'
require 'gtk2'

module JLDrill::Gtk
	class ExampleView < JLDrill::ExampleView
        attr_reader :exampleWindow
        	
		def initialize(context)
			super(context)
			@exampleWindow = ExampleWindow.new(self)
		end
		
		def getWidget
			@exampleWindow
		end

        def mainWindow
            getWidget.gtkWidgetMainWindow
        end
		
        def destroy
            @exampleWindow.explicitDestroy
        end
		
		def emitDestroyEvent
			@exampleWindow.signal_emit("destroy")
		end
		
		def update(examples)
		    super(examples)
		    @exampleWindow.updateContents(examples)
		end
    end   
end
