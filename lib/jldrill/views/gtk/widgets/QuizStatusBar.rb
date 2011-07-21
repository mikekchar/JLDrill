# encoding: utf-8
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
    end
end
