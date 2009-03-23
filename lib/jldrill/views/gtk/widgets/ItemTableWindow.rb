require 'Context/Gtk/Widget'
require 'jldrill/views/gtk/widgets/ItemTable'
require 'gtk2'

module JLDrill::Gtk
    class ItemTableWindow < Gtk::Window
        include Context::Gtk::Widget

        def initialize(view)
            @view = view
            @closed = false
            super("All Vocabulary")
            self.set_default_size(450, 300)
            @vbox = Gtk::VBox.new
            self.add(@vbox)
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
                if !searching?
                    self.editDifferredItem
                end
            end
            @accel.connect(Gdk::Keyval::GDK_P, 0,
                           Gtk::ACCEL_VISIBLE) do
                if !searching?
                    self.preview
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

        def editCurrentItem
            if !@vocabTable.nil?
                item = @vocabTable.getSelectedItem
                if !item.nil?
                    @vocabTable.stopSearching
                    @view.edit(item)
                end
            end
        end

        def editDifferredItem
            if !@vocabTable.nil?
                item = @vocabTable.getSelectedItem
                if !item.nil? && @view.differs?(item)
                    @vocabTable.stopSearching
                    @view.edit(item)
                end
            end
        end

        def updateTable(items)
            if !@vocabTable.nil?
                @vbox.remove(@vocabTable)
            end
            if !items.empty?
                @vocabTable = ItemTable.new(items) do |item|
                    @vocabTable.stopSearching
                    @view.edit(item)
                end
                @vbox.pack_start(@vocabTable, true, true)
                @vocabTable.focusTable
            end
            @vbox.show_all
        end

        def preview
            item = @vocabTable.getSelectedItem
            if !item.nil?
                @view.preview(item)
            end
        end

        def explicitDestroy
            @closed = true
            self.destroy
        end
    end
end
