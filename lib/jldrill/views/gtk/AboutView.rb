require 'Context/Gtk/Widget'
require 'jldrill/views/AboutView'
require 'jldrill/model/Config'
require 'gtk2'

module JLDrill::Gtk

	class AboutView < JLDrill::AboutView
        	
		def initialize(context, about)
			super(context, about)
			@widget = nil
		end
		
		def getWidget
			@widget
		end

        def run
            iconFile = File.join(JLDrill::Config::DATA_DIR, "icon.png")
            icon = Gdk::Pixbuf.new(iconFile)
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

