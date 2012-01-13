# encoding: utf-8
require 'gtk2'
require 'jldrill/model/Config'
require 'gtk2'

module JLDrill::Gtk
    class Icon
        attr_reader :icon
            
        def initialize()
            @icon = nil
            # GTK+ on windows doesn't have SVG, so if this fails read the PNG
            begin
                @icon = Gdk::Pixbuf.new(JLDrill::Config::resolveDataFile(JLDrill::Config::PNG_ICON_FILE))
            rescue
                @icon = Gdk::Pixbuf.new(JLDrill::Config::resolveDataFile(JLDrill::Config::PNG_ICON_FILE))
            end
        end
    end
end

