require 'jldrill/views/gtk/widgets/ItemTable'

module JLDrill::Gtk
    class SearchTable < JLDrill::Gtk::ItemTable

        attr_reader :reading

        def initialize(container, reading)
            @container = container
            @reading = reading
            candidates = @container.search(reading)
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
