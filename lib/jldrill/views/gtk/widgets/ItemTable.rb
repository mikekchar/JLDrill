# encoding: utf-8
require 'gtk2'
require 'jldrill/views/gtk/widgets/WordTable.rb'
require 'jldrill/model/Item'
require 'jldrill/model/items/Vocabulary'


module JLDrill::Gtk
    class ItemTable < WordTable

        def initialize(itemList, &selectAction)
            super(itemList, JLDrill::Vocabulary, &selectAction)
        end

        def searchEqual(model, column, key, iter)
            retVal = true
            vocab = iter[0].to_o
            if !vocab.nil?
                retVal = !vocab.startsWith?(key)
            end
            return retVal
        end

        def getContents(item)
            return item.to_o
        end

        def getContentsAsVocab(item)
            return item.to_o
        end

    end
end
