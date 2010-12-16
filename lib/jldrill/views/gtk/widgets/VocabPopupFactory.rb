require 'jldrill/views/gtk/widgets/PopupFactory'
require 'jldrill/views/gtk/widgets/VocabPopup'
require 'gtk2'

module JLDrill::Gtk
    class VocabPopupFactory < PopupFactory
        def initialize(view)
            super(view)
        end
        
        def dictionaryLoaded?
            @context.dictionaryLoaded?
        end

        def sameString?(string, x, y)
            !@currentPopup.nil? && # @currentPopup.character == string &&
                @currentPopup.x == x && @currentPopup.y == y
        end

        def getCandidates(string)
            return @context.search(string)
        end
        
        def getStringAt(widget, window, x, y)
            type = widget.get_window_type(window)
            coords = widget.window_to_buffer_coords(type, x, y)
            iter, tr = widget.get_iter_at_position(coords[0], coords[1])
            sentenceEnd = iter.buffer.get_iter_at_offset(iter.offset)
            sentenceEnd.forward_sentence_end
            string = iter.get_visible_text(sentenceEnd)
            pos = widget.get_iter_location(iter)
            if (coords[0] > pos.x) && (coords[0] < pos.x + pos.width) &&
                    string != ""
                rect = widget.buffer_to_window_coords(type, pos.x, pos.y)
                charPos = belowRect([rect[0], rect[1], pos.width, pos.height])
                screenPos = toAbsPos(widget, charPos[0], charPos[1])
                [string, screenPos]
            else
                [nil, nil]
            end
        end

        def createPopup(searchString, x, y)
            closePopup
            candidates = getCandidates(searchString)
            if !candidates.nil? && !candidates.empty?
                if !candidates[0].kanji.nil?
                    string = candidates[0].kanji
                else
                    string = candidates[0].reading
                end
                @currentPopup = VocabPopup.new(string,
                                          candidates.collect do |word|
                                              word.to_s
                                          end.join("\n"),
                                          @view.mainWindow, x, y)
            end
        end

        def notify(widget, window, x, y)
            if @blocked || !dictionaryLoaded?
                return
            end
            string, screenPos = getStringAt(widget, window, x, y)
            if string.nil? || screenPos.nil?
                closePopup
                return
            elsif sameString?(string, screenPos[0], screenPos[1])
                return
            end
            createPopup(string, screenPos[0], screenPos[1])
        end
    end
end
