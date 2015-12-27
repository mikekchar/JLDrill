# encoding: utf-8
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

    def createSelectorWindow(type)
      if @selectorWindow.nil?
        # The tests create the selector window in advance.
        # So if the window is non-nil, don't create it.
        # Once the window has run once, it should be reset to nil.
        @selectorWindow = SelectorWindow.new(type)
      end
    end

    def run(type)
      createSelectorWindow(type)
      @selectorWindow.current_folder = @directory unless @directory.nil?
      retVal = @selectorWindow.execute
      @filename = @selectorWindow.chosenFilename
      @directory = @selectorWindow.chosenDirectory
      retVal
    end
  end
end
