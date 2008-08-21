require 'Context/Gtk/Widget'
require 'jldrill/views/VocabularyTableView'
require 'jldrill/oldUI/GtkVocabTable'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyTableView < JLDrill::VocabularyTableView

        class VocabularyTableWindow < Gtk::Dialog

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

        end	    
        attr_reader :vocabularyTableWindow
        	
		def initialize(context)
			super(context)
			@vocabularyTableWindow = VocabularyTableWindow.new(self)
			@widget = Context::Gtk::Widget.new(@vocabularyTableWindow)
		end
		
		def getWidget
			@widget
		end

        def destroy
            @vocabularyTableWindow.destroy
        end

        def run(quiz)
            super(quiz)
            @vocabularyTableWindow.execute
        end
    end
end

