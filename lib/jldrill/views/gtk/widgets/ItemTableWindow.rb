require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/widgets/ItemTable'
require 'gtk2'

module JLDrill::Gtk
    class ItemTableWindow < Gtk::Window
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
            @context = @view.context
            @closed = false
            super("All Vocabulary")
            self.set_default_size(450, 300)
            @vbox = Gtk::VBox.new
            self.add(@vbox)
            @frame = Gtk::HBox.new
            @vbox.pack_start(@frame, true, true, 5)
            @sideButtons = Gtk::VBox.new
            @frame.pack_end(@sideButtons, true, true, 5)
            @previewButton = Gtk::Button.new("Preview (P)")
            @sideButtons.pack_start(@previewButton, false, false, 5)
            @editButton = Gtk::Button.new("Edit (E)")
            @sideButtons.pack_start(@editButton, false, false, 5)
            @deleteButton = Gtk::Button.new("Delete (D)")
            @sideButtons.pack_start(@deleteButton, false, false, 5)
            @upButton = Gtk::Button.new("Move Up (Shift-Up)")
            @sideButtons.pack_start(@upButton, false, false, 5)
            @downButton = Gtk::Button.new("Move Down (Shift-Down)")
            @sideButtons.pack_start(@downButton, false, false, 5)
            @vocabTable = nil
            @buttons = Gtk::HBox.new
            @exitButton = Gtk::Button.new("Exit")
            @buttons.pack_end(@exitButton, true, true, 5)
            @vbox.pack_end(@buttons, false, false)
            connectSignals
        end

        def connectSignals
            @accel = Gtk::AccelGroup.new
            @accel.connect(Gdk::Keyval::GDK_Escape, 0,
                           Gtk::ACCEL_VISIBLE) do
                self.close
            end
            @accel.connect(Gdk::Keyval::GDK_E, 0,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.editCurrentItem
                end
            end
            @accel.connect(Gdk::Keyval::GDK_D, 0,
                           Gtk::ACCEL_VISIBLE) do
                self.deleteCurrentItem
            end
            @accel.connect(Gdk::Keyval::GDK_P, 0,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.preview
                end
            end
            @accel.connect(Gdk::Keyval::GDK_Up, Gdk::Window::SHIFT_MASK,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.moveCurrentItemUp
                end
            end
            @accel.connect(Gdk::Keyval::GDK_Down, Gdk::Window::SHIFT_MASK,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.moveCurrentItemDown
                end
            end

            @accel.connect(Gdk::Keyval::GDK_X, Gdk::Window::CONTROL_MASK,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.markCut
                end
            end

            @accel.connect(Gdk::Keyval::GDK_V, Gdk::Window::CONTROL_MASK,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.markPaste
                end
            end

            add_accel_group(@accel)

            signal_connect('delete_event') do
                # Request that the destroy signal be sent
                false
            end
            
            signal_connect('destroy') do
                self.close
            end
            
            @exitButton.signal_connect('clicked') do
                self.close
            end

            @previewButton.signal_connect('clicked') do
                self.preview
            end

            @editButton.signal_connect('clicked') do
                self.editCurrentItem
            end

            @deleteButton.signal_connect('clicked') do
                self.deleteCurrentItem
            end


            @upButton.signal_connect('clicked') do
                self.moveCurrentItemUp
            end

            @downButton.signal_connect('clicked') do
                self.moveCurrentItemDown
            end
        end

        def searching?
            return !@vocabTable.nil? && @vocabTable.searching?
        end

        def close
            if !@closed
                @view.close
            end
        end

        # Select the item in the table if it exists
        def select(item)
            if !item.nil? && !@vocabTable.nil?
                @vocabTable.selectItem(item)
            end
        end

        def updateItem(item)
            if !item.nil? && !@vocabTable.nil?
                @vocabTable.updateItem(item)
            end
        end

        def addItem(item)
            if !item.nil?
                if @vocabTable.nil?
                    updateTable([item])
                else
                    @vocabTable.addItem(item)
                end
            end
        end

        def removeItem(item)
            if !item.nil?
                if @vocabTable.nil?
                    updateTable([item])
                else
                    @vocabTable.removeItem(item)
                end
            end
        end

        def editCurrentItem
            if !@vocabTable.nil?
                item = @vocabTable.getSelectedItem
                if !item.nil?
                    @vocabTable.stopSearching
                    @context.edit(item)
                end
            end
        end

        def deleteCurrentItem
            if !@vocabTable.nil?
                item = @vocabTable.getSelectedItem
                if !item.nil?
                    @vocabTable.stopSearching
                    @context.delete(item)
                end
            end
        end

        def updateTable(items)
            if !@vocabTable.nil?
                @frame.remove(@vocabTable)
            end
            if !items.empty?
                @vocabTable = ItemTable.new(items) do |item|
                    @vocabTable.stopSearching
                    @context.edit(item)
                end
                @frame.pack_start(@vocabTable, true, true)
                @vocabTable.focusTable
            end
            @vbox.show_all
        end

        def preview
            item = @vocabTable.getSelectedItem
            if !item.nil?
                @context.preview(item)
            end
        end

        def explicitDestroy
            @closed = true
            self.destroy
        end

        def moveCurrentItemUp
            @vocabTable.moveUp
        end

        def moveCurrentItemDown
            @vocabTable.moveDown
        end

        def markCut
            @vocabTable.markCut
        end

        def markPaste
            @vocabTable.pasteBefore
        end

    end
end
