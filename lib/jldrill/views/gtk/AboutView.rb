# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/contexts/ShowAboutContext'
require 'jldrill/model/Config'
require 'gtk2'

module JLDrill::Gtk

	class AboutView < JLDrill::ShowAboutContext::AboutView
        	
		def initialize(context, about)
			super(context, about)
			@widget = nil
		end
		
		def getWidget
			@widget
		end

        def run
            # GTK+ on windows doesn't have SVG, so if this fails read the PNG
            begin
                icon = Gdk::Pixbuf.new(Config::resolveDataFile(Config::SVG_ICON_FILE))
            rescue
                icon = Gdk::Pixbuf.new(Config::resolveDataFile(Config::PNG_ICON_FILE))
            end
            Gtk::AboutDialog.show(nil,
    			    :name => @about.name,
    			    :version => @about.version,
    			    :copyright => @about.copyright,
    			    :license => @about.license,
    			    :comments => @about.comments,
                    :website => @about.website,
                    :logo => icon,
    			    :authors => @about.authors)
        end
    end
end

