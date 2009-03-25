require 'Context/View'
require 'jldrill/model/items/Vocabulary'

module JLDrill
	class VocabularyView < Context::View
	    attr_reader :vocabulary, :label, :block
        attr_writer :vocabulary
	
		def initialize(context, label, &block)
			super(context)
			@vocabulary = Vocabulary.new
			@label = label
			@block = block
		end

		def run
		    # Only for the concrete class
		end
		
		def close
		    @context.exit
		end
		
		def destroy
		    # Only for the concrete class
		end

        def update(vocabulary)
            oldVocab = @vocabulary
            @vocabulary = vocabulary
            # Update re-do the search if the reading has changed.
            if !@vocabulary.reading.eql?(oldVocab.reading)
                updateSearch
            end
        end

        def updateSearch
            # Only for the concrete class
        end

        # Returns true if the vocabulary has been added
        def addVocabulary
            if @vocabulary.valid?
                @context.addVocabulary(@vocabulary)
                true
            else
                false
            end
        end
        
        def search(reading)
            @context.search(reading)
        end

        # Returns true if the vocabulary was set
        def setVocabulary
            return @context.setVocabulary(@vocabulary)
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
