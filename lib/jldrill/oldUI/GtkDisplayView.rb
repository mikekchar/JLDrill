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
require 'jldrill/oldUI/GtkVocabView'

class GtkDisplayView < Gtk::Dialog

  def initialize(vocab, parentWindow)
    super("Vocabulary Display",
          parentWindow,
          Gtk::Dialog::DESTROY_WITH_PARENT,
          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
          [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

    @quizV = GtkVocabView.new(vocab)

    refVocab = Vocabulary.new
    table = Gtk::Table.new(2, 1)
    table.attach(Gtk::Label.new("Quiz Vocab"), 0, 1, 0, 1,
                 0, 0, 10, 10)
    table.attach(@quizV, 0, 1, 1, 2,
                 Gtk::FILL | Gtk::EXPAND, Gtk::FILL, 10, 10)
    self.vbox.add(table)
  end

  def getVocab
    vocab = @quizV.getVocab()
    return vocab
  end

end

