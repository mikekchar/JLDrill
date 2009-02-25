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

        def update(items, item)
            @itemTableWindow.updateTable(items, item)
        end
    end
end

