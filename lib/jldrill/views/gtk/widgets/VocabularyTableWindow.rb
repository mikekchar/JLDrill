require 'Context/Gtk/Widget'
require 'jldrill/oldUI/GtkVocabTable'
require 'gtk2'

module JLDrill::Gtk
    class VocabularyTableWindow < Gtk::Dialog
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
                candView = GtkVocabTable.new(@view.quiz.allVocab) do
                end
                self.vbox.add(candView)
                self.show_all
            end
            run
        end
        
        def gtkAddWidget(widget)
            # We currently can't add widgets to this pane. Silently fail.
        end

        def gtkRemoveWidget(widget)
            # We currently can't remove widgets from this pane. Silently fail.
        end        
    end	    
end
