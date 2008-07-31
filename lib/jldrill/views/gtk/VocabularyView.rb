require 'Context/Gtk/Widget'
require 'jldrill/views/VocabularyView'
require 'jldrill/oldUI/GtkVocabView.rb'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyView < JLDrill::VocabularyView
	
	    class VocabularyWindow < Gtk::Window
	        attr_reader :addButton
	    
	        def initialize(view)
	            @view = view
	            @closed = false
	            super("Add")
	            @vbox = Gtk::VBox.new
	            self.add(@vbox)
	            @vocabView = GtkVocabView.new(@view.vocabulary)
	            @vbox.add(@vocabView)
	            @addButton = Gtk::Button.new("Add")
	            @vbox.add(@addButton)
	            connectSignals
	        end
	        
	        def connectSignals
			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
				    if !@closed
    					@view.close
    			    end
				end
				
				addButton.signal_connect('clicked') do
				    @view.addVocabulary
				end
			end
			
			def explicitDestroy
			    @closed = true
			    self.destroy
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
            
            def update(vocab)
                @vocabView.setVocab(vocab)
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

        def destroy
            @vocabularyWindow.explicitDestroy
        end
		
		def emitDestroyEvent
			@vocabularyWindow.signal_emit("destroy")
		end

        def emitAddButtonClickedEvent
            @vocabularyWindow.addButton.clicked
        end
        
        # Returns true if the vocabulary has been added
        def addVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            if super
                @vocab = Vocabulary.new
                @vocabularyWindow.update(@vocab)
                true
            else
                false
            end
        end

    end
    
end

