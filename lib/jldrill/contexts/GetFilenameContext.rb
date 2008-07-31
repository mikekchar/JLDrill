require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/views/FilenameSelectorView'

module JLDrill

	class GetFilenameContext < Context::Context
		
	    attr_reader :filename, :directory
	    attr_writer :directory
		
		def initialize(viewBridge)
			super(viewBridge)
			@filename = nil
			@directory = nil
		end
		
		def createViews
    		@mainView = @viewBridge.FilenameSelectorView.new(self)
        end

        def destroyViews
            @mainView.destroy if !@mainView.nil?
            @mainView = nil
        end		    
		
		def enter(parent)
		    super(parent)
		    @mainView.directory = @directory
    		@mainView.run
    		@filename = @mainView.filename
    		@directory = @mainView.directory
    		self.exit
    		@filename
		end
    end
end
