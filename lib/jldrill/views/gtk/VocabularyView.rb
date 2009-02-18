require 'jldrill/views/gtk/widgets/VocabularyWindow'
require 'jldrill/views/VocabularyView'
require 'gtk2'

module JLDrill::Gtk

	class VocabularyView < JLDrill::VocabularyView
	
        attr_reader :vocabularyWindow
        	
		def initialize(context, label, &block)
			super(context, label, &block)
			@vocabularyWindow = VocabularyWindow.new(self, label)
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
            super(vocabulary)
            @vocabularyWindow.update(vocabulary)
        end

        def updateSearch
            @vocabularyWindow.updateSearchTable
        end
        
        # Returns true if the vocabulary has been added
        def addVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            if super
                @vocab = JLDrill::Vocabulary.new
                @vocabularyWindow.update(@vocab)
                @vocabularyWindow.updateSearchTable
                @vocabularyWindow.setFocus
                true
            else
                false
            end
        end
        
        def setVocabulary
            @vocabulary = @vocabularyWindow.getVocab
            super
        end

    end
    
end

