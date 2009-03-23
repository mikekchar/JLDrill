require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/VocabularyView'

module JLDrill

	class AddNewVocabularyContext < Context::Context
				
		def initialize(viewBridge)
			super(viewBridge)
		end
		
		def createViews
    		@mainView = @viewBridge.VocabularyView.new(self, "Add") do
    		    @mainView.addVocabulary
    		end
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
            if !@parent.nil? && !@parent.reference.nil?
                @parent.reference.publisher.subscribe(self, "edictLoad")
            end
		end
		
		def exit
            if !@parent.nil? && !@parent.reference.nil?
                @parent.reference.publisher.unsubscribe(self, "edictLoad")
            end
		    super
		end
		
		def addVocabulary(vocab)
		    if !@parent.nil? && !@parent.quiz.nil?
    		    item = @parent.quiz.appendVocab(vocab)
                @parent.displayItem(item)
    		    @parent.updateQuizStatus
    		end
		end
		
        def dictionaryLoaded?
            !@parent.nil? && !@parent.reference.nil? &&
                @parent.reference.loaded?
        end

        def loadDictionary
            @parent.loadReference unless @parent.nil?
        end

		def search(reading)
		    if dictionaryLoaded? && !reading.nil? && !reading.empty?
		        @parent.reference.search(reading).sort! do |x,y|
		            x.to_o.reading <=> y.to_o.reading
		        end
		    else
		        []
		    end
		end
		
		def setVocabulary(vocab)
		    # Do nothing in this context
		end

        def edictLoadUpdated(reference)
            @mainView.updateSearch unless @mainView.nil?
        end

        def preview(item)
            @parent.displayItem(item)
        end
        
    end
end
