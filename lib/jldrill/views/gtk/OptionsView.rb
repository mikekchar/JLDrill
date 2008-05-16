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
                @random = Gtk::CheckButton.new("Introduce new items in random order")
                @promote = Gtk::HScale.new(1,10,1)
                @intro = Gtk::HScale.new(1,100,1)

                self.vbox.add(@random)
                self.vbox.add(Gtk::Label.new("Promote item after x correct"))
                self.vbox.add(@promote)
                self.vbox.add(Gtk::Label.new("Max actively learning items"))
                self.vbox.add(@intro)  
		    end
		    
		    def update(options)
                @random.active = options.randomOrder
                @promote.value = options.promoteThresh
                @intro.value = options.introThresh
            end

		    def execute
                if run == Gtk::Dialog::RESPONSE_ACCEPT
                    @view.optionsSet = true
                    @view.options.randomOrder = @random.active?
                    @view.options.promoteThresh = @promote.value
                    @view.options.introThresh = @intro.value
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
		    @optionsWindow.update(options)
		end
		
		def getWidget
			@widget
		end
    end
    
end

