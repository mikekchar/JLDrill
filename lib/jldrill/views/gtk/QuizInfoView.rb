require 'Context/Gtk/Widget'
require 'jldrill/views/QuizInfoView'
require 'gtk2'

module JLDrill::Gtk

	class QuizInfoView < JLDrill::QuizInfoView

        class QuizInfoWindow < Gtk::Dialog

	        def initialize(view)
	            @view = view
                super("Quiz Info", nil,
                        Gtk::Dialog::DESTROY_WITH_PARENT,
                        [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

                sw = Gtk::ScrolledWindow.new
                sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
                sw.shadow_type = Gtk::SHADOW_IN
                self.vbox.add(sw)
                
                @contents = Gtk::TextView.new
                @contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                @contents.editable = false
                @contents.cursor_visible = false
                sw.add(@contents)
                self.set_default_size(600, 360)
	        end

	        def execute
                if !@view.quiz.nil?
                    @contents.buffer.text = "Created from dictionary: " + @view.quiz.name + "\n\n"
                    @contents.buffer.text += @view.quiz.info
                end
	            run
	        end

        end	    
        attr_reader :selectorWindow
        	
		def initialize(context)
			super(context)
			@quizInfoWindow = QuizInfoWindow.new(self)
			@widget = Context::Gtk::Widget.new(@quizInfoWindow)
		end
		
		def getWidget
			@widget
		end

        def destroy
            @quizInfoWindow.destroy
        end

        def run(quiz)
            super(quiz)
            @quizInfoWindow.execute
        end
    end
end

