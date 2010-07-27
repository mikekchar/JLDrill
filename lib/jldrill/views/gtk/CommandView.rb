require 'Context/Gtk/Widget'
require 'Context/Views/Gtk/Widgets/VBox'
require 'jldrill/views/CommandView'
require 'jldrill/views/gtk/MenuWidget'
require 'jldrill/views/gtk/ToolBarWidget'
require 'gtk2'

module JLDrill::Gtk

    class CommandView < JLDrill::CommandView

        def initialize(context)
            super(context)
            @vbox = Context::Gtk::VBox.new
            @menu = Menu.new(self)
            @toolbar = ToolBar.new(self)
            @vbox.pack_start(@menu, false, false)
            @vbox.pack_start(@toolbar, false, false)
			@vbox.afterWidgetIsAdded do |container|
			    container.gtkWidgetMainWindow.add_accel_group(@menu.accelGroup)
			end
			@vbox.expandWidgetWidth
		end
		
		def getWidget
			@vbox
		end

        def update
            @toolbar.update
        end
    end
end
