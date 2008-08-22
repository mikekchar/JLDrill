require 'jldrill/views/MainWindowView'
require 'gtk2'

module JLDrill::Gtk

	class MainWindowView < JLDrill::MainWindowView
	
		class MainWindow < Gtk::Window
		
		    attr_reader :mainTable
		
			def initialize(view)
				super('JLDrill')
				@view = view
				@closed = false

                @icon = Gdk::Pixbuf.new(File.join(JLDrill::Config::DATA_DIR, "icon.png"))
    
                set_icon(@icon)

                ## Layout everything in a vertical table
                @mainTable = Gtk::Table.new(1, 0, false)
                add(@mainTable, true)
				connectSignals unless @view.nil?
			end

            def add(widget, orig=false)
                if orig
                    # Hack to be able to use the super's add method
                    super(widget)
                else
                    size = @mainTable.n_rows
                    @mainTable.resize(1, size + 1)
                    if widget.expandWidth
                        xOptions = Gtk::EXPAND | Gtk::FILL
                    else
                        xOptions = 0
                    end
                    if widget.expandHeight
                        yOptions = Gtk::EXPAND | Gtk::FILL
                    else
                        yOptions = 0
                    end
                    @mainTable.attach(widget.delegate,
                                 # X direction   # Y direction
                                 0, 1,           size, size + 1,
                                 xOptions,       yOptions,
                                 0,              0)
                end
            end
            
            def remove(widget)
                # Don't do it because tables can't remove things
            end
            

			def connectSignals
			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
				    if !@closed
    					closeView
    			    end
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
			@widget = Context::Gtk::Widget.new(@mainWindow)
			@widget.isAMainWindow
			def @widget.add(widget)
       		    if !widget.delegate.class.ancestors.include?(Gtk::Window)
        		    widget.mainWindow = @mainWindow
        			@delegate.add(widget)
        			if !Context::Gtk::Widget.inTests
                		@delegate.show_all
                    end
        	    else
        	        super
        	    end
			end
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
