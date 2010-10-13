require 'jldrill/model/Config'
require 'jldrill/views/gtk/widgets/SelectorWindow'
require 'jldrill/contexts/GetFilenameContext'
require 'gtk2'

module JLDrill::Gtk

	class FilenameSelectorView < JLDrill::GetFilenameContext::FilenameSelectorView
        attr_reader :selectorWindow
        	
		def initialize(context)
			super(context)
			@selectorWindow = nil
		end
		
		def getWidget
			@selectorWindow
		end

        def destroy
            @selectorWindow.destroy
            @selectorWindow = nil
        end

        def run(type)
            if @selectorWindow.nil?
                # It's an error for it to be non-nil, but if it is
                # it's because the previous window didn't close for
                # some reason.  So we'll reuse it I guess...
                @selectorWindow = SelectorWindow.new(type)
            end
            @selectorWindow.current_folder = @directory unless @directory.nil?
            retVal = @selectorWindow.execute
            @filename = @selectorWindow.chosenFilename
            @directory = @selectorWindow.chosenDirectory
            retVal
        end
    end
end

