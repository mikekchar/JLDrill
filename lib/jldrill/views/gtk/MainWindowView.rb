require 'Context/Gtk/Key'
require 'Context/Gtk/Widget'
require 'jldrill/views/MainWindowView'
require 'gtk2'

require 'jldrill/model/Edict/Edict'
require 'jldrill/model/HashedEdict'
require 'jldrill/model/Vocabulary'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/model/Kanji'
require 'jldrill/model/Config'
require 'jldrill/oldUI/GtkDisplayView'
require 'jldrill/oldUI/GtkXRefView'
require 'jldrill/oldUI/GtkVocabTable'
require 'jldrill/oldUI/GtkEnterFilename'
require 'jldrill/Version'

module JLDrill::Gtk

	class MainWindowView < JLDrill::MainWindowView
	
	    class ReviewModeButton < Gtk::ToggleButton
	        def initialize(view)
	            super('Review Mode')
	            @view = view
	            connectSignals unless @view.nil?
	            set_active(false)
	        end
	        
	        def connectSignals
				signal_connect('toggled') do
					changeMode
				end
	        end
	        
	        def changeMode
	            @view.setReviewMode(active?)
	        end
	        
	        def update
	            set_active(@view.quiz.options.reviewMode)
	        end
	    end
	
		class MainWindow < Gtk::Window
		
		    attr_reader :accelGroup, :mainTable
		
			def initialize(view)
				super('JLDrill')
				@closed = false
				@view = view

                @resultDisplayed = false
    
                @currentDir = File.join(JLDrill::Config::DATA_DIR, "quiz") 
                @icon = Gdk::Pixbuf.new(File.join(JLDrill::Config::DATA_DIR, "icon.png"))
    
                set_icon(@icon)

                                         
                @reviewModeButton = ReviewModeButton.new(@view)

                ## Layout everything in a vertical table
                @mainTable = Gtk::Table.new(1, 2, false)
                add(@mainTable, true)

                menu = createMenu
                @mainTable.attach(menu.get_widget('<main>'),
                             # X direction            # Y direction
                             0, 1,                    0, 1,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)

                toolbar = createToolbar
                @mainTable.attach(toolbar,
                             # X direction            # Y direction
                             0, 1,                    1, 2,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)

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
            
            def createMenu
                ## Create the menubar
                @accelGroup = Gtk::AccelGroup.new
                add_accel_group(@accelGroup)
                
                menu = Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR,
                                                    '<main>', @accelGroup)
                
                # create menu items
                menu_items = [
                    ["/_File"],
                    ["/File/_Save",
                    "<StockItem>", "<control>S", Gtk::Stock::SAVE, Proc.new{save}],
                    ["/File/Save _As...",
                    "<StockItem>", "<control>A", Gtk::Stock::SAVE, Proc.new{saveAs}],
                    ["/File/_Export...",
                    "<Item>", "<control>E", nil, Proc.new{export}],
                    ["/File/_Open...",
                    "<StockItem>", "<control>O", Gtk::Stock::OPEN, Proc.new{open}],
					["/File/A_ppend...",
					"<Item>", "<control>P", nil,
					    Proc.new {
						    appendFile
						}],
                    ["/File/Load Reference _Dictionary...",
                    "<Item>", "<control>D", nil, 
                        Proc.new{
                            loadReference
                        }],
                    ["/File/_Quit",
                    "<StockItem>", "<control>Q", Gtk::Stock::QUIT, Proc.new{quit}],

                    ["/_Drill"],
                    ["/Drill/_Info...",
                        "<Item>", "<control>I", nil, Proc.new{info}],
                    ["/Drill/_Statistics...",
                        "<Item>", "<alt>S", nil, Proc.new{statistics}],
                    ["/Drill/_Check",
                    "<Item>", "Z", nil, Proc.new{check}],
                    ["/Drill/_Incorrect",
                    "<Item>", "X", nil, Proc.new{incorrect}],
                    ["/Drill/_Correct",
                    "<Item>", "C", nil, Proc.new{correct}],
                    ["/Drill/Show _All...",
                    "<Item>", "<control>T", nil, Proc.new{vocabTable}],
                    ["/Drill/_Preferences",
                    "<StockItem>", "<control>P", Gtk::Stock::PREFERENCES, Proc.new{options}],
                    ["/Drill/_Reset",
                    "<Item>", "<control>R", nil, Proc.new{resetQuiz}],

                    ["/_Vocab"],
                    ["/Vocab/_Display...",
                    "<Item>", "D", nil, Proc.new{displayVocab}],
                    ["/Vocab/_XReference...",
                    "<Item>", "<control>X", nil, Proc.new{xReference}],
                    
                    ["/_Edit"],
                    ["/Edit/_Add...",
                    "<Item>", "+", nil, Proc.new{addNewVocabulary}],

                    ["/_Help"],
                    ["/Help/Ac_knowledgements...",
                    "<Item>", "<control>K", nil, Proc.new{ack}],
                    ["/Help/_About...", 
                    "<Item>", "?", nil, Proc.new{about}],
                ]
                menu.create_items(menu_items)

                return menu
            end

            def createToolbar
                ## Create the toolbar
                toolbar = Gtk::Toolbar.new

                checkImage = Gtk::Image.new(Gtk::Stock::SPELL_CHECK,
                                       Gtk::IconSize::SMALL_TOOLBAR)
                incorrectImage = Gtk::Image.new(Gtk::Stock::NO, 
                                           Gtk::IconSize::SMALL_TOOLBAR)
                correctImage = Gtk::Image.new(Gtk::Stock::YES, 
                                         Gtk::IconSize::SMALL_TOOLBAR)

                # toolbar.set_toolbar_style(Gtk::Toolbar::BOTH)
                toolbar.append(Gtk::Stock::SAVE,
                               "Save a Drill file"
                               ) do save end
                toolbar.append(Gtk::Stock::OPEN,
                               "Open a Edict file"
                               ) do open end
                toolbar.append(Gtk::Stock::QUIT,
                               "Quit GTK LDrill"
                               ) do quit end
                toolbar.append_space
                toolbar.append("Check (Z)", "Check",
                               "Check the result", checkImage
                               ) do check end
                toolbar.append("Incorrect (X)", "Incorrect",
                               "Answer was incorrect", incorrectImage
                               ) do incorrect end
                toolbar.append("Correct (C)", "Correct",
                               "Answer was correct", correctImage
                               ) do correct end
                toolbar.append_space                               
                toolbar.append(@reviewModeButton)

                return toolbar
            end

            def info()
                if @view.quiz
                    dialog = Gtk::Dialog.new("Quiz Info",
                                            self,
                                            Gtk::Dialog::DESTROY_WITH_PARENT,
                                            [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

                    sw = Gtk::ScrolledWindow.new
                    sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
                    sw.shadow_type = Gtk::SHADOW_IN
                    dialog.vbox.add(sw)
                    
                    contents = Gtk::TextView.new
                    contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                    contents.editable = false
                    contents.cursor_visible = false
                    sw.add(contents)
                    dialog.set_default_size(640, 360)

                    contents.buffer.text = "Created from dictionary: " + @view.quiz.name + "\n\n"
                    contents.buffer.text += @view.quiz.info

                    dialog.show_all

                    dialog.run { |response|
                        case response
                        when Gtk::Dialog::RESPONSE_ACCEPT then # Do nothing
                        end
                        dialog.destroy
                    }
                end
            end
            
            def statistics
                @view.showStatistics
            end

            def open()
                if promptSave
                    @view.openFile
                end
            end

            def appendFile
                @view.appendFile
            end

            def loadReference()
                @view.loadReference
            end

            def export()
                if @view.quiz
                    dialog = GtkEnterFilename.new(@currentDir, self)
                
                    savename = dialog.run 
                    dialog.destroy
                    if savename != ""
                    @view.quiz.export(savename)
                    end
                end
            end
  
            def saveAs()
            	if @view.quiz
            	    dialog = GtkEnterFilename.new(@currentDir, self)
            	    savename = dialog.run
            	    if dialog.resp == Gtk::Dialog::RESPONSE_ACCEPT
            	        @currentDir = dialog.current_folder
                    end
                    dialog.destroy
                    if savename != ""
                        @view.quiz.savename = savename
                        @view.quiz.save
                    end
                end
            end

            def save(newFile=false)
                if @view.quiz
                    if @view.quiz.savename == ""
                    	saveAs()
                    else
                    @view.quiz.save
                    end
                end
            end

            def options()
                @view.setOptions
            end

            def ack()
                acks = %Q[Acknowledgements

    This program could not have been written if it were not for the
    contribution that others have made.  Normally JLDrill will be distributed
    with data files that are used for creating the drills.  These data
    files required an enormous amount of work to compile and their authors
    deserve to be given some credit.  

    In particular I want to thank The Electronic Dictionary Research
    and Development Group at Monash University.  JLDrill uses the
    EDICT files for it's reference dictionary.  Without this
    monumental work, very little could be done in the world of free
    software with respect to Japanese language training.  I am deeply
    in their debt.

    I would also like to thank Thierry Bézecourt for the use of the
    files which form the basis of the JLPT drills.  Thierry has very
    kindly granted permission to use these files in this application
    under the GPL license, thus saving me weeks of work.

    Notes: 

      The EDICT files are the property of the Electronic
      Dictionary Research and Development Group at Monash University,
      and are used in conformance with the Group's licence.

      Links: 

        EDICT:   http://www.csse.monash.edu.au/~jwb/edict.html
        Electronic Dictionary Research and Development Group: 
                 http://www.csse.monash.edu.au/groups/edrdg/
        License: http://www.csse.monash.edu.au/groups/edrdg/licence.html


      The JLPT files are Copyright (C) 2001 Thierry Bézecourt 
      His website is http://www.thbz.org and he can be reached
      at kanjimots@thbz.org

      More licence information can be found in the
      data/jldrill/COPYING directory in the main distribution of this
      application. 
]

                dialog = Gtk::Dialog.new("Acknowledgements", self,
                    Gtk::Dialog::DESTROY_WITH_PARENT,
                    [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

                sw = Gtk::ScrolledWindow.new
                sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
                sw.shadow_type = Gtk::SHADOW_IN
                dialog.vbox.add(sw)
                
                contents = Gtk::TextView.new
                contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                contents.editable = false
                contents.cursor_visible = false
                sw.add(contents)
                dialog.set_default_size(640, 360)

                contents.buffer.text = acks

                dialog.show_all

                dialog.run { |response|
                    case response
                        when Gtk::Dialog::RESPONSE_ACCEPT then # Do nothing
                    end
                    dialog.destroy
                }

            end

            def about()
                unless Gtk.check_version?(2, 6, 0)
                    puts "This application requires GTK+ 2.6.0 or later"
                    return
                end

                authors = ["Mike Charlton"]
                license = %Q[JLDrill - Drill Program for Learning Japanese
Copyright (C) 2005-2007  Mike Charlton

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
]

                Gtk::AboutDialog.show(self,
        			    :name => "GTK LDrill",
        			    :version => JLDrill::VERSION,
        			    :copyright => "(C) 2005 Mike Charlton",
        			    :license => license,
        			    :comments => "Super Drill Program for Learning Japanese.",
                        :website => "http://jldrill.rubyforge.org",
                        :logo => self.icon,
        			    :authors => authors)
            end

            # Returns false if cancel was chosen
            def promptSave()
                retVal = true

                if @view.quiz && @view.quiz.needsSave
                    dialog = Gtk::Dialog.new("Unsaved Changes", self,
                        Gtk::Dialog::DESTROY_WITH_PARENT,
                        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                        [Gtk::Stock::NO, Gtk::Dialog::RESPONSE_NO],
                        [Gtk::Stock::YES, Gtk::Dialog::RESPONSE_YES])

                    dialog.vbox.add(Gtk::Label.new("You have unsaved changes."));
                    dialog.vbox.add(Gtk::Label.new("Do you want to save first?"));
                    dialog.show_all

                    dialog.run { |response|
                        case response
                            when Gtk::Dialog::RESPONSE_YES
                                save
                            when Gtk::Dialog::RESPONSE_NO 
                                # Do nothing
                        else 
                            retVal = false
                        end
                        dialog.destroy
                    }
                    
                end

                return retVal
            end

            def quit()
                closeView
            end

            def vocabTable
                if @view.quiz
                    dialog = Gtk::Dialog.new("All Vocabulary", self,
                        Gtk::Dialog::DESTROY_WITH_PARENT,
                        [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

                    candView = GtkVocabTable.new(@view.quiz.allVocab) { |vocab|
                    }
                    dialog.vbox.add(candView);
                    dialog.set_default_size(450, 300)

                    dialog.show_all

                    dialog.run { |response|
                        case response
                            when Gtk::Dialog::RESPONSE_ACCEPT
                                # Do nothing
                        end
                        dialog.destroy
                    }
                end
            end

            def displayVocab
                if @view.quiz && @view.quiz.vocab
                    dialog = GtkDisplayView.new(@view.quiz.vocab, self)
                    dialog.show_all

                    dialog.run { |response|
                        if response == Gtk::Dialog::RESPONSE_ACCEPT 
                            newVocab = dialog.getVocab 
                            if newVocab != nil
                                @view.quiz.currentProblem.vocab = newVocab
                            end
                        end
                        dialog.destroy
                    }
                    @view.updateCurrentProblemStatus
                end
            end

            def xReference
                if @view.edict.loaded? && @view.quiz && @view.quiz.vocab
                    dialog = GtkXRefView.new(@view.quiz.vocab, self,
                                            @view.edict.search(@view.quiz.vocab.reading))
                    dialog.show_all

                    dialog.run { |response|
                        if response == Gtk::Dialog::RESPONSE_ACCEPT 
                            newVocab = dialog.getVocab 
                            if newVocab != nil
                                @view.quiz.currentProblem.vocab = newVocab
                            end
                        end
                        dialog.destroy
                    }
                    @view.updateCurrentProblemStatus
                end
            end

            def addNewVocabulary
                @view.addNewVocabulary
            end

            def resetQuiz
                if @view.quiz
                    @view.quiz.reset
                end
            end

            def check()
                if(@view.quiz)
                    @view.showAnswer
                end
            end

            def correct()
                if(@view.quiz)
                    @view.quiz.correct
                    @view.quiz.drill
                end
            end

            def incorrect()
                if(@view.quiz)
                    @view.quiz.incorrect
                    @view.quiz.drill
                end
            end
			
			def connectSignals
#	            @qcontents.add_events(Gdk::Event::POINTER_MOTION_MASK)
#	            @qcontents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
#	            @acontents.add_events(Gdk::Event::POINTER_MOTION_MASK)
#	            @acontents.add_events(Gdk::Event::LEAVE_NOTIFY_MASK)
			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
				    if !@closed
    					closeView
    			    end
				end
				
#        		@qcontents.signal_connect('motion_notify_event') do |widget, motion|
#				    characterPopup(widget, motion.window, motion.x, motion.y)
#				end

#        		@acontents.signal_connect('motion_notify_event') do |widget, motion|
#				    characterPopup(widget, motion.window, motion.x, motion.y)
#				end

#        		@qcontents.signal_connect('leave_notify_event') do |widget, event|
#				    closePopup
#				end

#        		@acontents.signal_connect('leave_notify_event') do |widget, event|
#				    closePopup
#				end

			end
			
			def explicitDestroy
			    @closed = true
			    self.destroy
			end
			
			def closeView
			    if(promptSave())
				    @view.close
				end
			end
			
			def updateQuiz
			    @reviewModeButton.update
			end
			
			def closePopup
			    if !@popup.nil?
			        @popup.destroy
			        @popup = nil
			        @popupChar = nil
			    end
			end
			
			# Translates the x,y coordinates of the widget in this
			# window to absolute screen coordinates
			def toAbsPos(widget, x, y)
		        origin = self.window.position
		        pos = [x + origin[0], y + origin[1]]
                widget.translate_coordinates(self, pos[0], pos[1])
			end
			
			def getCharAt(widget, type, x, y)
			    coords = widget.window_to_buffer_coords(type, x, y)
			    iter, tr = widget.get_iter_at_position(coords[0], coords[1])
			    char = iter.char
		        pos = widget.get_iter_location(iter)
		        if (coords[0] > pos.x) && (coords[0] < pos.x + pos.width) &&
			      char != ""
			        rect = widget.buffer_to_window_coords(type, pos.x, pos.y)
			        [char, [rect[0], rect[1], pos.width, pos.height]]
			    else
			        nil
			    end
			end
			
			def createPopup(char)
		        popup = Gtk::Window.new(Gtk::Window::POPUP)
		        popup.set_transient_for(self)
		        popup.set_destroy_with_parent(true)
		        popup.set_window_position(Gtk::Window::POS_NONE)
		        label = Gtk::Label.new(char)
		        popup.add(label)
		        popup
			end
			
			def belowRect(rect)
			    x = rect[0] + (rect[2] / 2)
			    y = rect[1] + (rect[3])
			    [x, y]
			end
			
			def characterPopup(widget, window, x, y)
			    if @view.kanjiDic.nil?
			        return
			    end
                closePopup
                type = widget.get_window_type(window)
                char, charRect = getCharAt(widget, type, x, y)
			    if !char.nil? && !(char =~ /[a-zA-Z0-9 \s]/)
			        kanjiString = @view.kanjiDic.find do |entry|
			            entry.character == char
			        end.to_s
			        @popup = createPopup(kanjiString)
			        charPos = belowRect(charRect)
			        screenPos = toAbsPos(widget, charPos[0], charPos[1])
			        @popup.move(screenPos[0], screenPos[1] )
			        @popup.show_all
			    end
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
#			kanjiFile = JLDrill::Config::getDataDir + "/dict/kanjidic.utf"
#			radicalFile = JLDrill::Config::getDataDir + "/dict/radkfile.utf"
#			@kanjiDic = JLDrill::KanjidicFile.open(kanjiFile, JLDrill::RadKFile.open(radicalFile))
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
				
		def updateQuiz
		    @mainWindow.updateQuiz
		end
				
	end
end
