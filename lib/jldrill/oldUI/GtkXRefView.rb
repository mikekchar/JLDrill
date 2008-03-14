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

class GtkXRefView < Gtk::Dialog
  def initialize(vocab, parentWindow, candidates)
    super("Vocabulary Cross Reference",
          parentWindow,
          Gtk::Dialog::DESTROY_WITH_PARENT,
          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
          [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

    @refV = nil
    @quizV = GtkVocabView.new(vocab)

    refVocab = Vocabulary.new
    if (candidates) then col = 2 else col = 1 end
    table = Gtk::Table.new(2, col)
    table.attach(Gtk::Label.new("Quiz Vocab"), 0, 1, 0, 1,
                 0, 0, 10, 10)
    table.attach(@quizV, 0, 1, 1, 2,
                 Gtk::FILL | Gtk::EXPAND, Gtk::FILL, 10, 10)
    if(candidates)
      @refV = GtkVocabView.new(Vocabulary.new)
      table.attach(Gtk::Label.new("Reference Vocab"), 1, 2, 0, 1,
                   0, 0, 10, 10)
      table.attach(@refV, 1, 2, 1, 2,
                   Gtk::FILL | Gtk::EXPAND, Gtk::FILL, 10, 10)
    end
    self.vbox.add(table)
    if(candidates)
      candidates.sort! {|x,y| x.reading <=> y.reading}
      candView = GtkVocabTable.new(candidates) { |vocab|
        updateRefVocab(vocab)
      }
      self.vbox.add(candView)
      self.set_default_size(550, 600)
    end
  end

  def getVocab
    return @quizV.getVocab()
  end

  def updateRefVocab(vocab)
    if @refV
      @refV.setVocab(vocab)
    end
  end

end
