# encoding: utf-8
require 'jldrill/contexts/ShowAllVocabularyContext'

module JLDrill::Test
	class VocabularyTableView < JLDrill::ShowAllVocabularyContext::VocabularyTableView
	    attr_reader :destroyed, :updated, :selectedItem, :updatedItem,
                    :addedItem, :removedItem, :closed
        attr_writer :destroyed, :updated, :selectedItem, :updatedItem,
                    :addedItem, :removedItem, :closed
	
		def initialize(context)
			super(context)
            @destroyed = false
            @updated = false
            @selectedItem = nil
            @updatedItem = nil
            @addedItem = nil
            @removedItem = nil
            @closed = nil
		end
		
		def destroy
            @destroyed = true
		end
		
		def update(items)
            super(items)
            @updated = true
		end

        def select(item)
            super(item)
            @selectedItem = item
        end

        def updateItem(item)
            super(item)
            @updatedItem = item
        end

        def addItem(item)
            super(item)
            @addedItem = item
        end

        def removeItem(item)
            super(item)
            @removedItem = item
        end

        def close
            @closed = true
            super(item)
        end
	end
end
