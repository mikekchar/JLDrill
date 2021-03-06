# encoding: utf-8
require 'Context/Gtk/Widget'
require 'jldrill/contexts/ShowAboutContext'
require 'jldrill/model/Config'
require 'jldrill/views/gtk/widgets/Icon'
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
            icon = Icon.new
            Gtk::AboutDialog.show(nil,
    			    :name => @about.name,
    			    :version => @about.version,
    			    :copyright => @about.copyright,
    			    :license => @about.license,
    			    :comments => @about.comments,
                    :website => @about.website,
                    :logo => icon.icon,
    			    :authors => @about.authors)
        end
    end
end

