# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/oldUI/GtkVocabView'
require 'jldrill/views/gtk/widgets/SearchTable'
require 'jldrill/model/Item.rb'
require 'gtk2'


module JLDrill::Gtk
    class VocabularyWindow < Gtk::Window
        include Context::Gtk::Widget

        attr_reader :addButton
	    
        def initialize(view, label)
            @view = view
            @closed = false
            super(label)
            set_default_size(400, 500)
            @vbox = Gtk::VBox.new
            self.add(@vbox)
            @vocabView = GtkVocabView.new(@view.vocabulary)
            @vbox.add(@vocabView)
            @searchTable = nil
            @buttons = Gtk::HBox.new
            @searchButton = Gtk::Button.new("Search")
            @previewButton = Gtk::Button.new("Preview")
            @addButton = Gtk::Button.new(label)
            @buttons.pack_start(@searchButton, true, true, 5)
            @buttons.pack_start(@previewButton, true, true, 5)
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
                @view.action
            end

            @previewButton.signal_connect('clicked') do
                preview
            end
            
            @searchButton.signal_connect('clicked') do
                updateSearchTable
            end

            @vocabView.setAcceptReading do
                updateSearchTable
            end

            @vocabView.setAcceptKanji do
                updateSearchTable
            end
        end

        def close
            if !@closed
                @view.close
            end
        end

        def removeSearchTable
            if !@searchTable.nil?
                @vbox.remove(@searchTable)
                @searchTable = nil
            end
        end

        # Callback from the Search table
        def search(kanji, reading)
            @view.search(self.kanji, self.reading)
        end

        # Callback from the Search table
        def searchActivated(item)
            @vocabView.setDictionaryVocab(item.toVocab)
            @addButton.grab_focus
        end

        def createSearchTable
            if @view.dictionaryLoaded?
                @searchTable = SearchTable.new(self, self.kanji, self.reading)
                @vbox.add(@searchTable)
                @vbox.show_all
            end
        end

        def selectClosestMatch
            if !@searchTable.nil?
                @searchTable.selectClosestMatch(getVocab)
            end
        end

        def updateSearchTable
            # if we don't have a seach table or the reading has changed
            # create a new search table
            if @searchTable.nil? || 
                (self.reading != @searchTable.reading) ||
                (self.kanji != @searchTable.kanji)
                removeSearchTable
                createSearchTable
            end
            selectClosestMatch
        end

        def preview
            @view.preview(JLDrill::Item.create(getVocab.to_s))
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

        def setFocus
            if !@searchTable.nil? && @searchTable.hasSelection?
                @searchTable.focusTable
            else
                @vocabView.focusReading
            end
        end
        
        def showBusy(bool)
            @vocabView.showBusy(bool)
            if bool
                self.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::WATCH))
            else
                self.window.set_cursor(nil)
            end
            Gdk::flush()
        end
    end
end
