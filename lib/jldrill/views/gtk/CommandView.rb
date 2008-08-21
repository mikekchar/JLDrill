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
            @vbox.pack_start(@menu, false)
            @vbox.pack_end(@toolbar, false)
			@widget = Context::Gtk::Widget.new(@vbox)
			@widget.expandWidth = true
			@widget.expandHeight = false
		end
		
		def getWidget
			@widget
		end
    end
end
