require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/widgets/ItemTable'
require 'gtk2'

module JLDrill::Gtk
    class ItemTableWindow < Gtk::Dialog
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
            super("All Vocabulary", nil,
                  Gtk::Dialog::DESTROY_WITH_PARENT,
                  [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
            
            self.set_default_size(450, 300)
        end

        def execute
            if !@view.quiz.nil?
                candView = ItemTable.new(@view.quiz.allItems) do
                end
                self.vbox.add(candView)
                self.show_all
            end
            run
        end
    end	    
end
