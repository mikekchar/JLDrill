require 'gtk2'
require 'jldrill/model/items/Vocabulary'

module JLDrill::Gtk
    class GtkVocabView < Gtk::VBox

        def initialize(vocab)
            super()
            @acceptReadingBlock = nil
            @acceptKanjiBlock = nil
            @kanjiField = createField("Kanji: ", vocab.kanji) do
                @acceptKanjiBlock.call
            end
            @hintField = createField("Hint: ", vocab.hint)
            @readingField = createField("Reading: ", vocab.reading) do
                @acceptReadingBlock.call
            end
            @definitionsBox = createBox("Definitions: ", 
                                        vocab.definitionsRaw)
            @markersBox = createField("Markers: ", vocab.markers)
            
            pack_start(@kanjiField, true, false, 5)
            pack_start(@hintField, true, false, 5)
            pack_start(@readingField, true, false, 5)
            pack_start(@definitionsBox, true, true, 5)
            pack_start(@markersBox, true, true, 5)
        end
        
        def kanjiWidget
            @kanjiField.children[1]
        end

        def hintWidget
            @hintField.children[1]
        end

        def readingWidget
            @readingField.children[1]
        end

        # For some reason I am losing the entry in my boxes
        # I think it's a GTK bug, but I'm not sure.
        def definitionsWidget
            retVal = nil
            a2 = @definitionsBox.children[1]
            if !a2.nil?
                entry = a2.children[0]
                if !entry.nil?
                    retVal = entry.children[0]
                else
                    print "Error: definitionsWidget Entry is nil!!!\n"
                end
            else
                print "Error: definitionsWidget Alignment is nil!!!\n"
            end
            return retVal
        end

        def markersWidget
            @markersBox.children[1]
        end

        def kanji
            kanjiWidget.text
        end

        def kanji=(string)
            if string.nil? then string = "" end
            kanjiWidget.set_text(string)
        end

        def hint
            hintWidget.text
        end

        def hint=(string)
            if string.nil? then string = "" end
            hintWidget.set_text(string)
        end

        def reading
            readingWidget.text
        end

        def reading=(string)
            if string.nil? then string = "" end
            readingWidget.set_text(string)
        end

        def definitions
            widget = definitionsWidget
            if !widget.nil?
                return widget.buffer.text
            else
                return ""
            end
        end

        def definitions=(string)
            if string.nil? then string = "" end
            widget = definitionsWidget
            if !widget.nil?
                widget.buffer.set_text(string)
            end
        end

        def markers
            markersWidget.text
        end

        def markers=(string)
            if string.nil? then string = "" end
            markersWidget.set_text(string)
        end

        def getVocab
            vocab = JLDrill::Vocabulary.new
            vocab.kanji = kanji
            vocab.hint = hint
            vocab.reading = reading
            vocab.definitions = definitions
            vocab.markers = markers
            return vocab
        end

        def setVocab(vocab)
            if vocab
                self.kanji = vocab.kanjiRaw
                self.hint = vocab.hintRaw
                self.reading = vocab.readingRaw
                self.definitions = vocab.definitionsRaw
                self.markers = vocab.markersRaw
            end
        end

        # Sets the fields to the vocabulary listed, but doesn't
        # set the hint.  This is used to populate the views from
        # a dictionary entry (which doesn't have hints) rather than
        # the user's enter.
        def setDictionaryVocab(vocab)
            if vocab
                self.kanji = vocab.kanjiRaw
                self.reading = vocab.readingRaw
                self.definitions = vocab.definitionsRaw
                self.markers = vocab.markersRaw
            end
        end

        def createField(label, value, &block)
            if !label then label = "" end
            if !value then value = "" end

            hbox = Gtk::HBox.new()
            hbox.pack_start(Gtk::Label.new(label), false, false, 5)
            entry = Gtk::Entry.new
            entry.editable = true
            entry.text = value
            hbox.pack_start(entry, true, true, 5)
            if !block.nil?
                entry.signal_connect('activate') do |widget|
                    block.call
                end
            end
            return hbox
        end

        def createBox(label, value, &block)
            if !label then label = "" end
            if !value then value = "" end

            hbox = Gtk::HBox.new()
            alignment1 = Gtk::Alignment.new(0,0,0,0.5)
            alignment1.add(Gtk::Label.new(label))
            hbox.pack_start(alignment1, false, false, 5)

            entry = Gtk::ScrolledWindow.new
            entry.shadow_type = Gtk::SHADOW_IN
            entry.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            contents = Gtk::TextView.new
            contents.wrap_mode = Gtk::TextTag::WRAP_WORD
            contents.editable = true
            contents.cursor_visible = true
            entry.add(contents)
            contents.buffer.text = value

            alignment2 = Gtk::Alignment.new(0,0.5,1,1)
            alignment2.add(entry)

            hbox.pack_start(alignment2, true, true, 5)
            return hbox
        end

        def setAcceptReading(&block)
            @acceptReadingBlock = block
        end

        def setAcceptKanji(&block)
            @acceptKanjiBlock = block
        end
        def focusReading
            readingWidget.grab_focus
        end
    end
end
