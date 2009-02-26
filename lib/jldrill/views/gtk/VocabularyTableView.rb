require 'jldrill/views/gtk/widgets/ItemTableWindow'
require 'jldrill/views/VocabularyTableView'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyTableView < JLDrill::VocabularyTableView

        attr_reader :vocabularyTableWindow
        	
		def initialize(context)
			super(context)
			@itemTableWindow = JLDrill::Gtk::ItemTableWindow.new(self)
		end
		
		def getWidget
			@itemTableWindow
		end

        def destroy
            @itemTableWindow.explicitDestroy
        end

        def update(items)
            @itemTableWindow.updateTable(items)
        end

        def select(item)
            @itemTableWindow.select(item)
        end

        def updateItem(item)
            @itemTableWindow.updateItem(item)
        end

        def addItem(item)
            @itemTableWindow.addItem(item)
        end
    end
end

