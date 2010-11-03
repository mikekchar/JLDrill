require 'jldrill/views/gtk/widgets/ItemTable'

module JLDrill::Gtk
    class SearchTable < JLDrill::Gtk::ItemTable

        attr_reader :kanji, :reading

        def initialize(container, kanji, reading)
            @container = container
            @reading = reading
            @kanji = kanji
            candidates = @container.search(kanji, reading)
            super(candidates) do |item|
                @container.searchActivated(item)
            end
        end

        def selectClosestMatch(vocab)
            super(vocab)
            if hasSelection?
                focusTable
            end
        end

    end
end
