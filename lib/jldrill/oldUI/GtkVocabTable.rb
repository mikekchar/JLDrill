require 'gtk2'
require 'jldrill/model/Vocabulary'

module JLDrill::Gtk
    class GtkVocabTable < Gtk::ScrolledWindow

        def initialize(vocabList, &selectAction)
            super()
            @selectAction = selectAction
            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            set_size_request(450, 200)

            @listStore = Gtk::ListStore.new(JLDrill::Vocabulary, String, String, String)

            if vocabList
                vocabList.each { |vocab|
                    parent = @listStore.append
                    # column 0 isn't rendered.  It's just there for selection
                    parent[0] = vocab
                    parent[1] = vocab.kanji
                    parent[2] = vocab.reading
                    parent[3] = vocab.definitions
                }
            end

            @table = Gtk::TreeView.new(@listStore)
            @table.selection.mode = Gtk::SELECTION_SINGLE
            @table.set_rules_hint(true)
            @table.fixed_height_mode = true

            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Kanji", renderer, :text => 1)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 90
            @table.append_column(col)
            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Reading", renderer, :text => 2)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 130
            @table.append_column(col)
            renderer = Gtk::CellRendererText.new
            col = Gtk::TreeViewColumn.new("Meanings", renderer, :text => 3)
            col.resizable = true
            col.sizing = Gtk::TreeViewColumn::FIXED
            col.fixed_width = 230
            @table.append_column(col)
            
            self.add(@table)
            setupSelection
        end

        # Highlight the row when it is selected (by clicking on it or
        # by moving the cursor with the arrow keys)
        def highlightOnSelection
            select = @table.selection
            select.set_select_function do |selection, model, path, 
                                           currently_selected|
                # allow selection state to change
                true
            end
        end

        # Call the selectAction block when the row is activated
        def callActionOnActivation
            @table.signal_connect('row-activated') do |widget, path, column|
                if iter = @listStore.get_iter(path)
                    widget.set_cursor(path,nil,false)
                    @selectAction.call(iter[0])
                end
            end
        end

        # This method sets up the manor in which items are selected
        # in the table.
        def setupSelection
            highlightOnSelection
            callActionOnActivation
        end

        # Selects the closest match to the given vocabulary
        def selectClosestMatch(vocab)
            iter = @listStore.iter_first
            if !iter.nil?
                pos = iter.path
                rank = vocab.rank(iter[0])
                while iter.next!
                    newRank = vocab.rank(iter[0])
                    if newRank > rank
                        rank = newRank
                        pos = iter.path
                    end
                end
                @table.selection.select_path(pos)
                @table.scroll_to_cell(pos, nil, false, 0.0, 0.0)
            end
        end
        
        def hasSelection?
            !@table.selection.selected.nil?
        end

        # Put focus on the table 
        def focusTable
            @table.grab_focus
        end

    end
end
