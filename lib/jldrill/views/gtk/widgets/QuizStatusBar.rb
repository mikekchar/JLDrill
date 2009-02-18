require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class QuizStatusBar < Gtk::Statusbar
        include Context::Gtk::Widget

        attr_reader :text

        def initialize(view)
            super()
            @view = view
            @text = ""
            @id = get_context_id("Update quiz status")
        end
	        
        def update(string)
            @text = string
            pop(@id)
            push(@id, string)
        end

        def gtkAddWidget(widget)
            # We currently can't add widgets to this bar. Silently fail.
        end
        
        def gtkRemoveWidget(widget)
            # We currently can't remove widgets from this bar. Silently fail.
        end
    end
end
