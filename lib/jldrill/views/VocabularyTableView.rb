require 'Context/View'

module JLDrill
	class VocabularyTableView < Context::View
	    attr_reader :quiz, :items
	
		def initialize(context)
			super(context)
			@quiz = nil
            @items = nil
		end
		
		def destroy
		    # Only in the concrete class
		end
		
		def update(items)
            @items = items
		end

        def select(item)
            # Only in concrete class
        end

        def updateItem(item)
            # Only in concrete class
        end

        def addItem(item)
            # Only in concrete class
        end

        def close
            @context.exit
        end

        def edit(item)
            @context.edit(item)
        end
        
        def delete(item)
            @context.delete(item)
        end

        def preview(item)
            @context.preview(item)
        end

        def differs?(item)
            @context.differs?(item)
        end
	end
end
