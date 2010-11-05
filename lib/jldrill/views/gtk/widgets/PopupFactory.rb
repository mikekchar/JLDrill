require 'jldrill/views/gtk/widgets/Popup'
require 'gtk2'

module JLDrill::Gtk
    class PopupFactory
        def initialize(view)
            @view = view
            @context = @view.context
            @currentPopup = nil
            @blocked = false
        end

        def block
            @blocked = true
        end

        def unblock
            @blocked = false
        end

        def closePopup
            if !@currentPopup.nil?
                @currentPopup.close
                @currentPopup = nil
            end
        end

        # Finds the string that should be displayed in the Popup
        # Please override this in the concrete class
        def getPopupString(searchString)
            return ""
        end
        
        def createPopup(searchString, x, y)
            closePopup
            @currentPopup = Popup.new(searchString, 
                                      getPopupString(searchString), 
                                      @view.mainWindow, x, y)
        end
        
        def belowRect(rect)
            x = rect[0] - 150
            y = rect[1] + (rect[3])
            [x, y]
        end
        
        # Translates the x,y coordinates of the widget in this
        # window to absolute screen coordinates
        def toAbsPos(widget, x, y)
            origin = @view.mainWindow.window.position
            pos = [x + origin[0], y + origin[1]]
            widget.translate_coordinates(@view.mainWindow, pos[0], pos[1])
        end

    end
end
