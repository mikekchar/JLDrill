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
	            super(label)
	            @vbox = Gtk::VBox.new
	            self.add(@vbox)
	            @vocabView = GtkVocabView.new(@view.vocabulary)
	            @vbox.add(@vocabView)
	            @searchTable = nil
	            @buttons = Gtk::HBox.new
	            @searchButton = Gtk::Button.new("Search")
	            @addButton = Gtk::Button.new(label)
	            @buttons.pack_start(@searchButton, true, true, 5)
	            @buttons.pack_end(@addButton, true, true, 5)
	            @vbox.pack_end(@buttons, false, false)
	            connectSignals
	        end
	        
	        def connectSignals
                @accel = Gtk::AccelGroup.new
                @accel.connect(Gdk::Keyval::GDK_Escape, 0,
                               Gtk::ACCEL_VISIBLE) do
                    self.close
                end
                @accel.connect(Gdk::Keyval::GDK_D, Gdk::Window::CONTROL_MASK,
                               Gtk::ACCEL_VISIBLE) do
                    @view.loadDictionary
                end
                @accel.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK,
                               Gtk::ACCEL_VISIBLE) do
                    updateSearchTable
                end
                add_accel_group(@accel)

			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
                   self.close
				end
				
				@addButton.signal_connect('clicked') do
				    @view.block.call
				end
				
				@searchButton.signal_connect('clicked') do
                    updateSearchTable
				end

                @vocabView.setAcceptReading do
                    updateSearchTable
                end
			end

            def close
                if !@closed
                    @view.close
                end
            end

            def updateSearchTable
                if !@searchTable.nil?
                    @vbox.remove(@searchTable)
                    @searchTable = nil
                end
                if @view.dictionaryLoaded?
                    candidates = @view.search(self.reading)
                    @searchTable = GtkVocabTable.new(candidates) do |vocab|
                        update(vocab)
                        @addButton.grab_focus
                    end
                    @vbox.add(@searchTable)
                    @vbox.show_all
                    @searchTable.selectClosestMatch(getVocab)
                    @searchTable.focusTable
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

        def updateSearch
            @vocabularyWindow.updateSearchTable
        end
        
        # Returns true if the vocabulary has been added
        def addVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            if super
                @vocab = JLDrill::Vocabulary.new
                @vocabularyWindow.update(@vocab)
                @vocabularyWindow.updateSearchTable
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

