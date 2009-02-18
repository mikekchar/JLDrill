require 'jldrill/views/gtk/widgets/SelectorWindow'
require 'jldrill/views/FilenameSelectorView'
require 'gtk2'
require 'jldrill/model/Config'

module JLDrill::Gtk

	class FilenameSelectorView < JLDrill::FilenameSelectorView
        attr_reader :selectorWindow
        	
		def initialize(context)
			super(context)
			@selectorWindow = SelectorWindow.new()
		end
		
		def getWidget
			@selectorWindow
		end

        def destroy
            @selectorWindow.destroy
        end

        def run
            @selectorWindow.current_folder = @directory unless @directory.nil?
            retVal = @selectorWindow.execute
            @filename = @selectorWindow.chosenFilename
            @directory = @selectorWindow.chosenDirectory
            retVal
        end
    end
end

