require 'Context/View'
require 'Context/Context'

module JLDrill
    class FileProgressContext < Context::Context

        class FileProgress < Context::View
            def initialize(context)
                super(context)
            end

            # Update the progress display to the fraction
            def update(fraction)
                # Define in the concrete class
            end

            # File loading is done during the idle times in the UI.
            # This method must add a block to the idle loop in the UI.
            # The block will return true when the file is finished loading.
            # At that time the concrete class should call exit on the
            # context.
            def idle_add(&block)
                # Define in the concrete class
            end
        end

        def initialize(viewBridge)
            super(viewBridge)
        end

   		def createViews
			@mainView = @viewBridge.FileProgress.new(self)
        end
        
        def destroyViews
            @mainView = nil
        end
        
        def readFile
            if !getFile.nil?
                getFile.load(getFilename)
                @mainView.idle_add do
                    eof = getFile.parseChunk(100)
                    @mainView.update(getFile.fraction)
                    eof
                end
            end
        end
        
		def enter(parent)
            if !parent.nil?
                @parent = parent

                if(!getFile.loaded? || 
                   (getFile.file != getFilename))
                    super(parent)
                    readFile
                    # The view will exit the context when the file
                    # has finished loading.  This is because we
                    # can't exit the context until the idle process
                    # is removed, and this can only be done by the view.
                end
            end
		end

		def exit
		    super
		end
    end   
end
