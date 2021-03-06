# encoding: utf-8
require 'jldrill/views/gtk/widgets/ExampleWindow'
require 'jldrill/contexts/ShowExamplesContext'
require 'gtk2'

module JLDrill::Gtk
	class ExampleView < JLDrill::ShowExamplesContext::ExampleView
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

        def updateNativeOnly(examples)
            super(examples)
            @exampleWindow.updateNativeOnly(examples)
        end
		
        def updateTargetOnly(examples)
            super(examples)
            @exampleWindow.updateTargetOnly(examples)
        end
		
		def update(examples)
		    super(examples)
		    @exampleWindow.updateContents(examples)
		end

        def showBusy(bool)
            @exampleWindow.showBusy(bool)
        end
    end   
end
