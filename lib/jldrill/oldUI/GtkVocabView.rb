#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005  Mike Charlton
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


require 'gtk2'
require 'jldrill/model/Vocabulary'

class GtkVocabView < Gtk::VBox

    def initialize(vocab)
        super()
        @kanjiField = createField("Kanji: ", vocab.kanji)
        @hintField = createField("Hint: ", vocab.hint)
        @readingField = createField("Reading: ", vocab.reading)
        @definitionsBox = createBox("Definitions: ", vocab.definitions)
        @markersBox = createBox("Markers: ", vocab.markers)
        
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

    def definitionsWidget
        @definitionsBox.children[1].children[0].children[0]
    end

    def markersWidget
        @markersBox.children[1].children[0].children[0]
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
        definitionsWidget.buffer.text
    end

    def definitions=(string)
        if string.nil? then string = "" end
        definitionsWidget.buffer.set_text(string)
    end

    def markers
        markersWidget.buffer.text
    end

    def markers=(string)
        if string.nil? then string = "" end
        markersWidget.buffer.set_text(string)
    end

    def getVocab
        vocab = Vocabulary.new
        vocab.kanji = kanji
        vocab.hint = hint
        vocab.reading = reading
        vocab.definitions = definitions
        vocab.markers = markers
        return vocab
    end

    def setVocab(vocab)
        if vocab
            self.kanji = vocab.kanji
            self.hint = vocab.hint
            self.reading = vocab.reading
            self.definitions = vocab.definitions
            self.markers = vocab.markers
        end
    end

    def createField(label, value)
        if !label then label = "" end
        if !value then value = "" end

        hbox = Gtk::HBox.new()
        hbox.pack_start(Gtk::Label.new(label), false, false, 0)
        entry = Gtk::Entry.new
        entry.editable = true
        entry.text = value
        hbox.pack_start(entry, true, true, 0)
        return hbox
    end

    def createBox(label, value)
        if !label then label = "" end
        if !value then value = "" end

        hbox = Gtk::HBox.new()
        alignment1 = Gtk::Alignment.new(0,0,0,0.5)
        alignment1.add(Gtk::Label.new(label))
        hbox.pack_start(alignment1, false, false, 0)

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

        hbox.pack_start(alignment2, true, true, 0)
        return hbox
    end

end
