require 'Context/Gtk/Key'
require 'Context/Gtk/Widget'
require 'jldrill/views/MainWindowView'
require 'gtk2'

require 'jldrill/model/Edict'
require 'jldrill/model/HashedEdict'
require 'jldrill/model/Vocabulary'
require 'jldrill/model/Quiz/Quiz'
require 'jldrill/oldUI/GtkDisplayView'
require 'jldrill/oldUI/GtkXRefView'
require 'jldrill/oldUI/GtkVocabTable'
require 'jldrill/oldUI/GtkIndicatorBox'
require 'jldrill/oldUI/GtkEnterFilename'
require 'jldrill/Version'

module JLDrill::Gtk

    module Config
        if !Gem.datadir("jldrill").nil?
            # Use the data directory in the Gem if it is available
            DATA_DIR = Gem.datadir("jldrill")
        else
            # Otherwise hope there is a data dir in current directory
            DATA_DIR = 'data/jldrill'
        end
    end


	class MainWindowView < JLDrill::MainWindowView
	
		class MainWindow < Gtk::Window
		
		    attr_reader :accelGroup
		
			def initialize(view)
				super('JLDrill')
				@view = view
				connectSignals unless @view.nil?

                @resultDisplayed = false
    
                @currentDir = File.join(JLDrill::Gtk::Config::DATA_DIR, "quiz") 
                @icon = Gdk::Pixbuf.new(File.join(JLDrill::Gtk::Config::DATA_DIR, "icon.png"))
    
                set_icon(@icon)

                ## Layout everything in a vertical table
                table = Gtk::Table.new(1, 5, false)
                add(table)

                menu = createMenu
                table.attach(menu.get_widget('<main>'),
                             # X direction            # Y direction
                             0, 1,                    0, 1,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)

                toolbar = createToolbar
                table.attach(toolbar,
                             # X direction            # Y direction
                             0, 1,                    1, 2,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)

	            ## Create indicators
	            @indicatorBox = GtkIndicatorBox.new
	            table.attach(@indicatorBox,
                             # X direction            # Y direction
                             0, 1,                    2, 3,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)
	            @indicatorBox.show_all

                vpaned = Gtk::VPaned.new
                vpaned.set_border_width(5)
                table.attach(vpaned,
                             # X direction            # Y direction
                             0, 1,                    3, 4,
                             Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL,
                             0,                       0)


                ## Create document
                sw = Gtk::ScrolledWindow.new
                sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
                sw.shadow_type = Gtk::SHADOW_IN
                vpaned.add1(sw)

                contents = Gtk::TextView.new
                contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                contents.editable = false
                contents.cursor_visible = false
                sw.add(contents)
                @qbuffer = contents.buffer
                @qbuffer.create_tag("kanji", 
                                   "size" => 20 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_CENTER,
                                   "foreground" => "blue");

                ## Create document
                sw = Gtk::ScrolledWindow.new
                sw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
                sw.shadow_type = Gtk::SHADOW_IN
                vpaned.add2(sw)

                contents = Gtk::TextView.new
                contents.wrap_mode = Gtk::TextTag::WRAP_WORD
                contents.editable = false
                contents.cursor_visible = false
                sw.add(contents)
                @abuffer = contents.buffer
                @abuffer.create_tag("kanji", 
                                   "size" => 20 * Pango::SCALE,
                                   "justification" => Gtk::JUSTIFY_CENTER,
                                   "foreground" => "blue");
                vpaned.show_all


                ## Create statusbar
                @statusbar = Gtk::Statusbar.new
                table.attach(@statusbar,
                             # X direction            # Y direction
                             0, 1,                    4, 5,
                             Gtk::EXPAND | Gtk::FILL, 0,
                             0,                       0)
                updateStatus
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

            def updateStatus()
                @statusbar.pop(0)
                if(!@view.quiz)
                    @statusbar.push(0, "No Quiz Loaded -- Select Open")
                else
                    status = @view.quiz.status
                    if((@view.edict.loaded?) && (!@view.quiz.vocab.nil?)) 
                        # If the exact entry exists in the dictionary
                        if(@view.edict.include?(@view.quiz.vocab))
                            status += " -- OK"
                        else
                            status += " -- XX"
                        end
                    end
                    @statusbar.push(0, status)
                end
            end

            def printQuestion(text)
                if @qbuffer
                    @qbuffer.text = ""
                    @abuffer.text = ""
                    @qbuffer.insert(@qbuffer.start_iter, text, "kanji")
                    if !@view.quiz.vocab.nil?
                        @indicatorBox.set(@view.quiz.vocab)
                    end
                    updateStatus
                end
            end

            def printAnswer(text)
                if @abuffer
                    @abuffer.text = ""
                    @abuffer.insert(@abuffer.start_iter, text, "kanji")
                    updateStatus
                end
            end      

            def open()
                if(promptSave())
                    dialog = Gtk::FileChooserDialog.new("Open File",  self,
                        Gtk::FileChooser::ACTION_OPEN, nil,
                        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                        [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])

                    dialog.current_folder = @currentDir
                    
                    if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
                        @currentDir = dialog.current_folder
                        @view.quiz = JLDrill::Quiz.new()
                        if JLDrill::Quiz.drillFile?(dialog.filename)
                            @view.quiz.load(dialog.filename)
                        else
                            dict = Edict.new(dialog.filename)
                            dict.read
                            @view.quiz.loadFromDict(dict)
                        end
                        printQuestion(@view.quiz.drill)
                    end
                    dialog.destroy
                    updateStatus
                end
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
                        updateStatus
                    end
                end
            end

            def save(newFile=false)
                if @view.quiz
                    if @view.quiz.savename == ""
                    	saveAs()
                    else
                    @view.quiz.save
                    updateStatus
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

                if @view.quiz && @view.quiz.updated
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
                                redraw
                            end
                        end
                        dialog.destroy
                    }
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
                                redraw
                            end
                        end
                        dialog.destroy
                    }
                end
            end

            def redraw
                if @view.quiz
                    printQuestion(@view.quiz.currentDrill)
                    printAnswer(@view.quiz.currentAnswer)
                end
            end

            def resetQuiz
                if @view.quiz
                    @view.quiz.reset
                    updateStatus
                end
            end

            def check()
                if(@view.quiz)
                    printAnswer(@view.quiz.answer)
                end
            end

            def correct()
                if(@view.quiz)
                    @view.quiz.correct
                    printQuestion(@view.quiz.drill)
                end
            end

            def incorrect()
                if(@view.quiz)
                    @view.quiz.incorrect
                    printQuestion(@view.quiz.drill)
                end
            end
			
			def connectSignals
			    signal_connect('delete_event') do
                    # Request that the destroy signal be sent
                    false
                end

				signal_connect('destroy') do
					closeView
				end
			end
			
			def closeView
			    if(promptSave())
				    @view.close
				end
			end
        end
		
		attr_reader :mainWindow
	
		def initialize(context)
			super(context)
			@mainWindow = MainWindow.new(self)
			@mainWindow.set_default_size(600, 400)
			@widget = Context::Gtk::Widget.new(@mainWindow)
			@widget.isAMainWindow
		end
		
		def open
			@mainWindow.show_all
		end
				
		def getWidget
			@widget
		end
		
		def emitDestroyEvent
			@mainWindow.signal_emit("destroy")
		end
		
		def accelEntry(key)
		    @mainWindow.accelGroup.query(key.getGtkKeyval, key.getGtkState)
		end
		
		def accelDefined?(key)
		    return !accelEntry(key).nil?
		end
		
		# Runs the proc associated with the key in the AccelGroup.
		# Returns true if it could find it, false if it couldn't
		def runAccel(key)
		    success = false
		    entry = accelEntry(key)
		    if !entry.nil?  && (entry.size > 0)
		        if !entry[0].closure.nil?
#		            print entry[0].closure.class.instance_methods.join("\n")
		            success = true
		        end 
		    end
		    success
		end    
		
	end
end
