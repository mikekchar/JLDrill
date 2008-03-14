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
    pack_start(createField("Kanji: ", vocab.kanji), true, false, 5)
    pack_start(createField("Hint: ", vocab.hint), true, false, 5)
    pack_start(createField("Reading: ", vocab.reading), true, false, 5)
    pack_start(createBox("Meanings: ", vocab.definitions), true, true, 5)
    pack_start(createBox("Markers: ", vocab.markers), true, true, 5)
  end

  def getVocab
    vocab = Vocabulary.new
    vocab.kanji = getField(0)
    vocab.hint = getField(1)
    vocab.reading = getField(2)
    vocab.definitions = getBox(3)
    vocab.markers = getBox(4)
    return vocab
  end

  def setVocab(vocab)
    if vocab
      setField(0, vocab.kanji)
      setField(1, vocab.hint)
      setField(2, vocab.reading)
      setBox(3, vocab.definitions)
      setBox(4, vocab.markers)
    end
  end

  def setField(index, string)
    if string == nil
      string = ""
    end
    if(children[index])
      children[index].children[1].text = string
    end
  end

  def getField(index)
    retVal = ""
    if(children[index])
      retVal = children[index].children[1].text
    end
    return retVal
  end

  def setBox(index, string)
    if string == nil
      string = ""
    end
    if(children[index])
      children[index].children[1].children[0].children[0].buffer.text = string
    end
  end

  def getBox(index)
    retVal = ""
    if(children[index])
      retVal = children[index].children[1].children[0].children[0].buffer.text
    end
    return retVal
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
