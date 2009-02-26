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

        def updateTable(items)
            if !@vocabTable.nil?
                @vbox.remove(@vocabTable)
            end
            if !items.empty?
                @vocabTable = ItemTable.new(items)
                @vbox.pack_start(@vocabTable, true, true)
            end
            @vbox.show_all
        end

        def explicitDestroy
            @closed = true
            self.destroy
        end
    end
end
