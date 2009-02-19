require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class InfoWindow < Gtk::Dialog
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
            super("Info", nil,
                    Gtk::Dialog::DESTROY_WITH_PARENT,
                    [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

            sw = Gtk::ScrolledWindow.new
            sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            sw.shadow_type = Gtk::SHADOW_IN
            self.vbox.add(sw)
            
            @contents = Gtk::TextView.new
            @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
            @contents.editable = false
            @contents.cursor_visible = false
            sw.add(@contents)
            self.set_default_size(600, 360)
        end

        def addContents(string)
            @contents.buffer.text = string
        end
        
        def execute(string)
            addContents(string)
            run
        end
    end
end
