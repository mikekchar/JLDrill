require 'Context/Gtk/Widget'
require 'jldrill/views/VocabularyView'
require 'jldrill/oldUI/GtkVocabView.rb'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyView < JLDrill::VocabularyView
	
	    class VocabularyWindow < Gtk::Window
	        def initialize(view)
	            @view = view
	            super("Add")
	            @vocabView = GtkVocabView.new(@view.vocabulary)
	            self.add(@vocabView)
	            show_all
	        end
	        
	        def kanji
	            @vocabView.kanji
	        end

            def kanji=(string)
                @vocabView.kanji=(string)
            end

	        def hint
	            @vocabView.hint
	        end

            def hint=(string)
                @vocabView.hint=(string)
            end

	        def reading
	            @vocabView.reading
	        end

            def reading=(string)
                @vocabView.reading=(string)
            end

	        def definitions
	            @vocabView.definitions
	        end

            def definitions=(string)
                @vocabView.definitions=(string)
            end

	        def markers
	            @vocabView.markers
	        end

            def markers=(string)
                @vocabView.markers=(string)
            end
            
            def getVocab
                @vocabView.getVocab
            end
    
	    end
	
        attr_reader :vocabularyWindow
        	
		def initialize(context)
			super(context)
			@vocabularyWindow = VocabularyWindow.new(self)
			@widget = Context::Gtk::Widget.new(@vocabularyWindow)
		end
		
		def getWidget
			@widget
		end
    end
    
end

