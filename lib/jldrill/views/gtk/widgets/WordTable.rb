# encoding: utf-8
require 'gtk2'

module JLDrill::Gtk
    class WordTable < Gtk::ScrolledWindow

        def initialize(itemList, itemType, &selectAction)
            super()
            @headings = itemType.const_get(:Headings)
            @selectAction = selectAction
            self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
            self.shadow_type = Gtk::SHADOW_IN
            set_size_request(450, 200)

            @listStore = createListStore(itemList)

            @table = Gtk::TreeView.new(@listStore)
            @table.selection.mode = Gtk::SELECTION_SINGLE
            @table.set_rules_hint(true)
            @table.fixed_height_mode = true
            # Initially don't allow searching
            stopSearching
            @table.set_search_equal_func do |model, column, key, iter|
                searchEqual(model, column, key, iter)
            end

            if !itemList.empty?
                attachColumns
            end

            self.add(@table)
            setupSelection
            @mark = nil
        end

        # Returns true if the item should be selected when searching
        # Please redefine in the concrete class
        def searchEqual(model, column, key, iter)
            return false
        end

        # Returns the contents of the item
        # Please redefine in the concrete class
        def getContents(item)
            return nil
        end

        # Transforms the item to a Vocabulary
        # Please redefine in the concrete class
        def getContentsAsVocab(item)
            return nil
        end

        def setItem(iter, item)
            # column 0 isn't rendered.  It's just there for selection
            iter[0] = item
            content = getContents(item) 
            i = 1
            @headings.each do |heading|
                iter[i] = eval("content.#{heading[0]}")
                i += 1
            end
        end

        # Create the ListStore for the table based on the headings in
        # the item type of the first item.
        def createListStore(itemList)
            columnData = [JLDrill::Item]

            if !itemList.empty?
                0.upto(@headings.size) do
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

        def attachColumns
            i = 1
            @headings.each do |heading|
                renderer = Gtk::CellRendererText.new
                col = Gtk::TreeViewColumn.new(heading[1], renderer, :text => i)
                col.resizable = true
                col.sizing = Gtk::TreeViewColumn::FIXED
                col.fixed_width = heading[2]
                @table.append_column(col)
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
                rank = vocab.rank(getContentsAsVocab(iter[0]))
                while iter.next!
                    newRank = vocab.rank(getContentsAsVocab(iter[0]))
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
            if !item.nil? && (item.state.position != -1)
                path = Gtk::TreePath.new(item.state.position.to_s)
                selectPath(path)
            end
        end

        # Updates the item in the tree and selects the row
        def updateItem(item)
            if !item.nil? && (item.state.position != -1)
                path = Gtk::TreePath.new(item.state.position.to_s)
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

        def removeItem(item)
            if !item.nil? && (item.state.position != -1)
                path = Gtk::TreePath.new(item.state.position.to_s)
                iter = @listStore.get_iter(path)
                if !iter.nil?
                    @listStore.remove(iter)
                end
            end
        end

        # Returns true if an item in the table is selected
        def hasSelection?
            !@table.selection.selected.nil?
        end

        def getSelectedItem
            retVal = nil
            if hasSelection?
                retVal = @table.selection.selected[0]
            end
            return retVal
        end

        # Gets the iter to the row before the selected one.
        def getPreviousIter
            retVal = nil
            iter = @table.selection.selected
            if !iter.nil?
                prevPath = iter.path
                if prevPath.prev!
                    retVal = @listStore.get_iter(prevPath)
                end
            end
            return retVal
        end

        def getNextIter
            retVal = nil
            iter = @table.selection.selected
            if !iter.nil?
                prevPath = iter.path
                if prevPath.next!
                    retVal = @listStore.get_iter(prevPath)
                end
            end
            return retVal            
        end

        def moveUp
            if hasSelection?
                iter = @table.selection.selected
                prevIter = getPreviousIter
                if !iter.nil? && !prevIter.nil? &&
                        !iter[0].nil? && !prevIter[0].nil?
                    iter[0].quiz.contents.swapWith(iter[0], prevIter[0])
                    @listStore.move_before(iter, prevIter)
                    selectPath(iter.path)
                end
            end
        end

        def moveDown
            if hasSelection?
                iter = @table.selection.selected
                nextIter = getNextIter
                if !iter.nil? && !nextIter.nil? &&
                        !iter[0].nil? && !nextIter[0].nil?
                    iter[0].quiz.contents.swapWith(iter[0], nextIter[0])
                    @listStore.move_after(iter, nextIter)
                    selectPath(iter.path)
                end
            end
        end

        # Put focus on the table 
        def focusTable
            @table.grab_focus
        end

        def searching?
            @table.enable_search?
        end

        def search
            @table.set_enable_search(true)
        end

        def stopSearching
            @table.set_enable_search(false)
        end

        def toggleSearch
            if !@vocabTable.nil?
                if !searching
                    @vocabTable.search
                else
                    @vocabTable.stopSearching
                end
            end
        end

        def markCut
            if @mark == @table.selection.selected
                # Allow the user to clear the mark by cutting on the
                # same item.  Non-standard, but it's the best I can think
                # of right now
                markClear
            else
                @mark = @table.selection.selected
            end
        end

        def markClear
            @mark = nil
        end

        def pasteBefore
            target = @table.selection.selected
            if !@mark.nil? && !target.nil?
                @mark[0].quiz.contents.insertBefore(@mark[0],target[0])
                @listStore.move_before(@mark, target)
                selectPath(@mark.path)
            end
            markClear
        end

    end
end
