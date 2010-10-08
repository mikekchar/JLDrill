require 'jldrill/views/gtk/widgets/Popup'
require 'gtk2'

module JLDrill::Gtk
    class PopupFactory
        def initialize(view)
            @view = view
            @context = @view.context
            @currentPopup = nil
        end
        
        def kanjiDictionaryLoaded?
            @context.kanjiLoaded?
        end
        
        def sameCharacter?(character, x, y)
            !@currentPopup.nil? && @currentPopup.character == character &&
                @currentPopup.x == x && @currentPopup.y == y
        end
        
        def closePopup
            if !@currentPopup.nil?
                @currentPopup.close
                @currentPopup = nil
            end
        end
        
        def createPopup(char, x, y)
            closePopup
            kanjiString = @context.kanjiInfo(char)
            @currentPopup = Popup.new(char, kanjiString, @view.mainWindow, x, y)
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
        
        def getCharAt(widget, window, x, y)
            type = widget.get_window_type(window)
            coords = widget.window_to_buffer_coords(type, x, y)
            iter, tr = widget.get_iter_at_position(coords[0], coords[1])
            char = iter.char
            pos = widget.get_iter_location(iter)
            if (coords[0] > pos.x) && (coords[0] < pos.x + pos.width) &&
                    char != ""
                rect = widget.buffer_to_window_coords(type, pos.x, pos.y)
                charPos = belowRect([rect[0], rect[1], pos.width, pos.height])
                screenPos = toAbsPos(widget, charPos[0], charPos[1])
                [char, screenPos]
            else
                [nil, nil]
            end
        end
        
        def legalChar?(char)
            !char.nil? && !(char =~ /[a-zA-Z0-9 \s]/)
        end
        
        def notify(widget, window, x, y)
            if !kanjiDictionaryLoaded?
                return
            end
            char, screenPos = getCharAt(widget, window, x, y)
            if !legalChar?(char)
                closePopup
                return
            elsif sameCharacter?(char, screenPos[0], screenPos[1])
                return
            end
            createPopup(char, screenPos[0], screenPos[1])
        end
    end
end
