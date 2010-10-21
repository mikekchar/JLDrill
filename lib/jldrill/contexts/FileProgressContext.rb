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

        def exitFileProgressContext
            self.exit
        end

        def readFile
            eof = false
            filename = getFilename()
            if !filename.nil? && !getFile.nil?
                getFile.load(filename)
                @mainView.idle_add do
                    eof = getFile.parseChunk(getFile.stepSize)
                    @mainView.update(getFile.fraction)
                    fraction = getFile.fraction
                    if eof
                        exitFileProgressContext
                    end
                    eof
                end
            end
        end
       
        def isValid?(parent)
            retVal = false
            if !parent.nil?
                if (!getFilename.nil?) && 
                    (!getFile.loaded? || (getFile.file != getFilename))
                    retVal = true
                end
            end
            return retVal
        end

		def enter(parent)
            if isValid?(parent)
                super(parent)
                readFile
                # The view will exit the context when the file
                # has finished loading.  This is because we
                # can't exit the context until the idle process
                # is removed, and this can only be done by the view.
            end
        end

		def exit
		    super
		end
    end   
end
