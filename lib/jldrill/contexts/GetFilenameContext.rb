# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'Context/View'

module JLDrill

	class GetFilenameContext < Context::Context

        OPEN = 0
        SAVE = 1
		
	    attr_reader :filename, :directory
	    attr_writer :directory
		
		def initialize(viewBridge)
			super(viewBridge)
			@filename = nil
			@directory = nil
		end
		
        class FilenameSelectorView < Context::View
            attr_reader  :filename, :directory
            attr_writer  :filename, :directory
            
            def initialize(context)
                super(context)
                @filename = nil
                @directory = nil
            end
        
            # Destroy the modal dialog
            def destroy
                # Please define in the concrete class
            end
            
            # Open the model dialog
            def run
                # Please define in the concrete class
            end
        end

		def createViews
    		@mainView = @viewBridge.FilenameSelectorView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent, type)
		    super(parent)
		    @mainView.directory = @directory
    		@mainView.run(type)
    		filename = @mainView.filename
            if !filename.nil?
                @filename = filename
                @directory = @mainView.directory
            end
    		self.exit
    		@filename
		end
    end
end
