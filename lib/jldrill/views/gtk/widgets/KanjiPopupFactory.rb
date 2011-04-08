require 'jldrill/views/gtk/widgets/PopupFactory'
require 'gtk2'

module JLDrill::Gtk
    class KanjiPopupFactory < PopupFactory
        def initialize(view)
            super(view)
        end
        
        def dictionaryLoaded?
            @context.kanjiLoaded?
        end
        
        def sameCharacter?(character, x, y)
            !@currentPopup.nil? && @currentPopup.character == character &&
                @currentPopup.x == x && @currentPopup.y == y
        end
        
        def getPopupString(char)
            return @context.kanjiInfo(char)
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
        
        def notify(event)
            if @blocked || !dictionaryLoaded?
                return
            end
            char, screenPos = getCharAt(event.widget, event.motion.window, 
                                        event.motion.x, event.motion.y)
            if !legalChar?(char) || screenPos.nil?
                closePopup
                return
            elsif sameCharacter?(char, screenPos[0], screenPos[1])
                return
            end
            createPopup(char, screenPos[0], screenPos[1])
        end
    end
end
