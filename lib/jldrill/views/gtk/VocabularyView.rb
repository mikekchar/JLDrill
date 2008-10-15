require 'Context/Gtk/Widget'
require 'jldrill/views/VocabularyView'
require 'jldrill/oldUI/GtkVocabView.rb'
require 'jldrill/oldUI/GtkVocabTable.rb'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyView < JLDrill::VocabularyView
	
	    class VocabularyWindow < Gtk::Window
	        attr_reader :addButton
	    
	        def initialize(view, label)
	            @view = view
	            @closed = false
	            super("Add")
	            @vbox = Gtk::VBox.new
	            self.add(@vbox)
	            @vocabView = GtkVocabView.new(@view.vocabulary)
	            @vbox.add(@vocabView)
	            @searchTable = nil
	            @buttons = Gtk::HBox.new
	            @searchButton = Gtk::Button.new("Search")
	            @addButton = Gtk::Button.new(label)
	            @buttons.add(@searchButton)
	            @buttons.add(@addButton)
	            @vbox.add(@buttons)
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
				
				@addButton.signal_connect('clicked') do
				    @view.block.call
				end
				
				@searchButton.signal_connect('clicked') do
				    if !@searchTable.nil?
				        @vbox.remove(@searchTable)
				    end
				    candidates = @view.search(reading)
				    @searchTable = GtkVocabTable.new(candidates) do |vocab|
				        update(vocab)
				    end
				    @vbox.add(@searchTable)
				    @vbox.show_all
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
        	
		def initialize(context, label, &block)
			super(context, label, &block)
			@vocabularyWindow = VocabularyWindow.new(self, label)
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
        
        def update(vocabulary)
            super(vocabulary)
            @vocabularyWindow.update(vocabulary)
        end
        
        # Returns true if the vocabulary has been added
        def addVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            if super
                @vocab = JLDrill::Vocabulary.new
                @vocabularyWindow.update(@vocab)
                true
            else
                false
            end
        end
        
        def setVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            super
        end

    end
    
end

