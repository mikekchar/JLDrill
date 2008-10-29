require 'gtk2'
require 'jldrill/model/Vocabulary'

module JLDrill::Gtk
    class GtkVocabTable < Gtk::ScrolledWindow

        def initialize(vocabList, &selectAction)
            super()
            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            set_size_request(450, 200)

            listStore = Gtk::ListStore.new(JLDrill::Vocabulary, String, String, String)

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
            table.set_rules_hint(true)
            table.fixed_height_mode = true

            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Kanji", renderer, :text => 1)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 90
            table.append_column(col)
            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Reading", renderer, :text => 2)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 130
            table.append_column(col)
            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Meanings", renderer, :text => 3)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 230
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
end
