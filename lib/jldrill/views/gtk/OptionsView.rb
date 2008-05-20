require 'Context/Gtk/Widget'
require 'jldrill/views/OptionsView'
require 'gtk2'

module JLDrill::Gtk

	class OptionsView < JLDrill::OptionsView
	
		class OptionsWindow < Gtk::Dialog
		
		    def initialize(view)
		        @view = view
		        super("Drill Options", nil,
                        Gtk::Dialog::DESTROY_WITH_PARENT,
                        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                        [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
                @randomOrder = Gtk::CheckButton.new("Introduce new items in random order")
                @promoteThresh = Gtk::HScale.new(1,10,1)
                @introThresh = Gtk::HScale.new(1,100,1)

                self.vbox.add(@randomOrder)
                self.vbox.add(Gtk::Label.new("Promote item after x correct"))
                self.vbox.add(@promoteThresh)
                self.vbox.add(Gtk::Label.new("Max actively learning items"))
                self.vbox.add(@introThresh)  
		    end
		    
		    def randomOrder=(value)
		        @randomOrder.active = value
		    end
		    
		    def randomOrder
		        @randomOrder.active?
		    end

		    def promoteThresh=(value)
		        @promoteThresh.value = value
		    end

		    def promoteThresh
		        @promoteThresh.value.to_i
		    end

		    def introThresh=(value)
		        @introThresh.value = value
		    end

		    def introThresh
		        @introThresh.value.to_i
		    end

		    def updateFromViewData
                randomOrder = @view.options.randomOrder
                promoteThresh = @view.options.promoteThresh
                introThresh = @view.options.introThresh
            end
            
            def setViewData
                @view.optionsSet = true
                @view.options.randomOrder = randomOrder
                @view.options.promoteThresh = promoteThresh
                @view.options.introThresh = introThresh
            end

		    def execute
                if run == Gtk::Dialog::RESPONSE_ACCEPT
                    setViewData
                end
                @view.exit
            end
        end
    
        attr_reader :optionsWindow
        	
		def initialize(context)
			super(context)
			@optionsWindow = OptionsWindow.new(self)
			@widget = Context::Gtk::Widget.new(@optionsWindow)
		end
		
		def run
		    @optionsWindow.execute
		end
		
		def update(options)
		    super(options)
		    @optionsWindow.updateFromViewData
		end
		
		def getWidget
			@widget
		end
    end
    
end

