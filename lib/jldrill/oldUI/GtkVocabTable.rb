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

class GtkVocabTable < Gtk::ScrolledWindow

  def initialize(vocabList, &selectAction)
    super()
    self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
    self.shadow_type = Gtk::SHADOW_IN

    listStore = Gtk::ListStore.new(Vocabulary, String, String, String)

    if vocabList
      vocabList.each { |vocab|
        parent = listStore.append
        # column 0 isn't rendered.  It's just there for selection
        parent[0] = vocab
        parent[1] = vocab.kanji
        parent[2] = vocab.reading
        parent[3] = vocab.definitions
      }
    end

    table = Gtk::TreeView.new(listStore)
    table.selection.mode = Gtk::SELECTION_SINGLE

    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new("Kanji", renderer, :text => 1)
    table.append_column(col)
    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new("Reading", renderer, :text => 2)
    table.append_column(col)
    renderer = Gtk::CellRendererText.new
    col = Gtk::TreeViewColumn.new("Meanings", renderer, :text => 3)
    table.append_column(col)
    
    self.add(table)

    select = table.selection
    select.set_select_function do |selection, model, path, currently_selected|
      if iter = model.get_iter(path)
        if ! currently_selected
          selectAction.call(iter[0])
        end
      end

      # allow selection state to change
      true
    end
  end

end
