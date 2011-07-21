# encoding: utf-8
require 'jldrill/views/gtk/widgets/VocabularyWindow'
require 'jldrill/contexts/ModifyVocabularyContext'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyView < JLDrill::ModifyVocabularyContext::VocabularyView
	
        attr_reader :vocabularyWindow
        	
		def initialize(context, name)
			super(context, name)
			@vocabularyWindow = VocabularyWindow.new(self, name)
            @vocabularyWindow.setFocus
		end
		
		def getWidget
			@vocabularyWindow
		end

        def destroy
            @vocabularyWindow.explicitDestroy
        end
		
		def emitDestroyEvent
			@vocabularyWindow.signal_emit("destroy")
		end

        def emitAddButtonClickedEvent
            @vocabularyWindow.addButton.clicked
        end
        
        def update(vocabulary)
            @vocabularyWindow.update(vocabulary)
            super(vocabulary)
        end

        def updateSearch
            @vocabularyWindow.updateSearchTable
        end
       
        def getVocabulary
            @vocabulary = @vocabularyWindow.getVocab
        end

        # Returns true if the vocabulary has been added
        def clearVocabulary
            super
            @vocabularyWindow.update(@vocabulary)
            @vocabularyWindow.updateSearchTable
            @vocabularyWindow.setFocus
        end

        def close
            @context.exit
        end

        def search(kanji, reading)
            @context.search(kanji, reading)
        end

        def preview(item)
            @context.preview(item)
        end

        def dictionaryLoaded?
            @context.dictionaryLoaded?
        end

        def loadDictionary
            @context.loadDictionary
        end
	
    end
    
end

