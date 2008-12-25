require 'jldrill/views/MainWindowView'
require 'Context/Gtk/Widget'
require 'gtk2'

module JLDrill::Gtk

	class MainWindowView < JLDrill::MainWindowView
	
	    class MainWidget < Context::Gtk::Widget
	        def initialize(delegate, mainWindow)
	            super(mainWindow)
	            @contents = delegate
	            @mainWindow = mainWindow
	        end
	        
	        def add(widget)
       		    if !widget.delegate.class.ancestors.include?(Gtk::Window)
        		    widget.mainWindow = @mainWindow
        			@contents.pack_start(widget.delegate, widget.expandHeight, widget.expandHeight)
        			if !Context::Gtk::Widget.inTests
                		@delegate.show_all
                    end
        	    else
        	        widget.isAMainWindow
        	        widget.delegate.set_transient_for(@mainWindow)
        	        if !Context::Gtk::Widget.inTests
            		    widget.delegate.show_all
            		end
        	    end
			end
			
			def remove(widget)
                widget.mainWindow = nil
       		    if !widget.delegate.class.ancestors.include?(Gtk::Window)   
                    @contents.remove(widget.delegate)
                    if !Context::Gtk::Widget.inTests
                        @delegate.show_all
                    end
                end
                @delegate.grab_focus
            end
	    end
	    
		class MainWindow < Gtk::Window
		
		    attr_reader :contents
		
			def initialize(view)
				super('JLDrill')
				@view = view
				@closed = false

                @icon = Gdk::Pixbuf.new(File.join(JLDrill::Config::DATA_DIR, "icon.png"))
    
                set_icon(@icon)

                @contents = Gtk::VBox.new
                add(@contents)
				connectSignals unless @view.nil?
			end

			def connectSignals
				signal_connect('destroy') do
				    if !@closed
    					closeView
    			    end
				end
				signal_connect('delete-event') do
				    if !@closed
    					closeView
    			    end
                    true
				end
			end
			
			def explicitDestroy
			    @closed = true
			    self.destroy
			end
			
			def closeView
			    @view.close
			end
			
        end
		
		attr_reader :mainWindow, :kanjiDic
	
		def initialize(context)
			super(context)
			@mainWindow = MainWindow.new(self)
			@mainWindow.set_default_size(600, 400)
			@widget = MainWidget.new(@mainWindow.contents, @mainWindow)
		end
		
		def getWidget
			@widget
		end
		
		def destroy
		    @mainWindow.explicitDestroy
		end

		def emitDestroyEvent
			@mainWindow.signal_emit("destroy")
		end
				
	end
end
