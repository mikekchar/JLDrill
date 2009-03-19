require 'gtk2'
require 'jldrill/model/Item'
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
            @table.set_enable_search(true)
            @table.set_search_equal_func do |model, column, key, iter|
                retVal = true
                vocab = iter[0].to_o
                if !vocab.nil?
                    retVal = !vocab.startsWith?(key)
                end
                retVal
            end

            if !itemList.empty?
                attachColumns(@table, itemList[0].itemType.headings)
            end

            self.add(@table)
            setupSelection
        end

        def setItem(iter, item)
            # column 0 isn't rendered.  It's just there for selection
            iter[0] = item
            content = item.to_o
            i = 1
            headings = item.itemType.headings
            headings.each do |heading|
                iter[i] = eval("content.#{heading[0]}")
                i += 1
            end
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
                    iter = listStore.append
                    setItem(iter, item)
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
                    if !@selectAction.nil?
                        @selectAction.call(iter[0])
                    end
                end
            end
        end

        # This method sets up the manor in which items are selected
        # in the table.
        def setupSelection
            highlightOnSelection
            callActionOnActivation
        end

        # Select the item in the TreePath and scroll to the cell
        def selectPath(path)
            @table.set_cursor(path, nil, false)
        end

        # Selects the closest match to the given vocabulary
        def selectClosestMatch(vocab)
            iter = @listStore.iter_first
            if !iter.nil?
                pos = iter.path
                rank = vocab.rank(iter[0].to_o)
                while iter.next!
                    newRank = vocab.rank(iter[0].to_o)
                    if newRank > rank
                        rank = newRank
                        pos = iter.path
                    end
                end
                selectPath(pos)
            end
        end

        # Selects the row with the given item if it exists
        def selectItem(item)
            if !item.nil?
                path = Gtk::TreePath.new(item.position.to_s)
                selectPath(path)
            end
        end

        # Updates the item in the tree and selects the row
        def updateItem(item)
            if !item.nil?
                path = Gtk::TreePath.new(item.position.to_s)
                iter = @listStore.get_iter(path)
                setItem(iter, item)
                selectPath(path)
            end
        end

        def addItem(item)
            # For now we are just going to append the item to the table
            if !item.nil?
                iter = @listStore.append
                setItem(iter, item)
                selectPath(iter.path)
            end
        end

        # Returns true if an item in the table is selected
        def hasSelection?
            !@table.selection.selected.nil?
        end

        # Put focus on the table 
        def focusTable
            @table.grab_focus
        end

    end
end
