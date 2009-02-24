require 'gtk2'
require 'jldrill/model/items/Item'
require 'jldrill/model/items/Vocabulary'

module JLDrill::Gtk
    class ItemTable < Gtk::ScrolledWindow

        def initialize(itemList, &selectAction)
            super()
            @selectAction = selectAction
            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            set_size_request(450, 200)

            @listStore = createListStore(itemList)

            @table = Gtk::TreeView.new(@listStore)
            @table.selection.mode = Gtk::SELECTION_SINGLE
            @table.set_rules_hint(true)
            @table.fixed_height_mode = true

            if !itemList.empty?
                attachColumns(@table, itemList[0].itemType.headings)
            end

            self.add(@table)
            setupSelection
        end

        # Create the ListStore for the table based on the headings in
        # the item type of the first item.
        def createListStore(itemList)
            columnData = [JLDrill::Item]

            if !itemList.empty?
                headings = itemList[0].itemType.headings
                0.upto(headings.size) do
                    columnData.push(String)
                end
            end

            listStore = eval "Gtk::ListStore.new(#{columnData.join(", ")})"

            if !itemList.empty?
                itemList.each do |item|
                    entry = listStore.append
                    # column 0 isn't rendered.  It's just there for selection
                    entry[0] = item
                    content = item.to_o
                    i = 1
                    headings.each do |heading|
                        entry[i] = eval("content.#{heading[0]}")
                        i += 1
                    end
                end
            end

            return listStore
        end

        def attachColumns(table, headings)
            i = 1
            headings.each do |heading|
                renderer = Gtk::CellRendererText.new
                col = Gtk::TreeViewColumn.new(heading[1], renderer, :text => i)
                col.resizable = true
                col.sizing = Gtk::TreeViewColumn::FIXED
                col.fixed_width = heading[2]
                table.append_column(col)
                i += 1
            end
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

        def hasSelection?
            !@table.selection.selected.nil?
        end

        # Put focus on the table 
        def focusTable
            @table.grab_focus
        end

    end
end
