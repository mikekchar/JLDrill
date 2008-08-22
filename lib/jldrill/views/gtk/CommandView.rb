require 'Context/Gtk/Widget'
require 'jldrill/views/CommandView'
require 'jldrill/views/gtk/MenuWidget'
require 'jldrill/views/gtk/ToolBarWidget'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::CommandView

        def initialize(context)
            super(context)
            @menu = Menu.new(self)
            @toolbar = ToolBar.new(self)
            @vbox = Gtk::VBox.new
            def @vbox.accelGroup
                @accelGroup
            end
            def @vbox.addAccelGroup(accelGroup)
                @accelGroup = accelGroup
            end
            @vbox.pack_start(@menu, false)
            @vbox.pack_end(@toolbar, false)
            @vbox.addAccelGroup(@menu.accelGroup)
			@widget = Context::Gtk::Widget.new(@vbox)
			def @widget.addedTo(widget)
			    widget.mainWindow.add_accel_group(delegate.accelGroup)
			end
			@widget.expandWidth = true
			@widget.expandHeight = false
		end
		
		def getWidget
			@widget
		end
    end
end
