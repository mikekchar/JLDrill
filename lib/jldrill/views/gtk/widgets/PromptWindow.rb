require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk
    class PromptWindow < Gtk::Dialog
        include Context::Gtk::Widget

        attr_reader :response
        
        def initialize(view, title, message)
            @view = view
            @response = @view.context.cancel
            super(title, nil,
                  Gtk::Dialog::DESTROY_WITH_PARENT,
                  [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                  [Gtk::Stock::NO, Gtk::Dialog::RESPONSE_NO],
                  [Gtk::Stock::YES, Gtk::Dialog::RESPONSE_YES])
            self.vbox.add(Gtk::Label.new(message))
        end
        
        def execute
            self.run do |response|
                case response
                when Gtk::Dialog::RESPONSE_YES
                    @response = @view.context.yes
                when Gtk::Dialog::RESPONSE_NO 
                    @response = @view.context.no
                else 
                    @response = @view.context.cancel
                end
            end
            @response
        end

        def gtkAddWidget(widget)
            # We currently can't add widgets to this pane. Silently fail.
        end
        
        def gtkRemoveWidget(widget)
            # We currently can't remove widgets from this pane. Silently fail.
        end
    end	    
end
