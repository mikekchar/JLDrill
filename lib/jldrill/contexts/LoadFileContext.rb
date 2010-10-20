require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

    # Loads a file displaying a progress bar as it is loading.
	class LoadFileContext < FileProgressContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @file = nil
            @filename = nil
		end

        # File is any file of type DataFile
        # Filename is the filename you want to open
        def enter(parent, file, filename)
            @file = file
            @filename = filename
            super(parent)
        end

        # Returns the filename of the dictionary including the path
        def getFilename
            return @filename
        end

        def getFile
            return @file
        end
    end
end
