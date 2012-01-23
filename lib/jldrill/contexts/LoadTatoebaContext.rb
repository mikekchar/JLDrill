# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'
require 'jldrill/model/Tatoeba'

module JLDrill

    # Load the kanji, radicals and kana files one after another.
	class LoadTatoebaContext < Context::Context

        attr_reader :sentencesFile, :japaneseFile
        attr_writer :sentencesFile, :japaneseFile
		
		def initialize(viewBridge)
			super(viewBridge)
		    @sentencesFile = Config::resolveDataFile(Config::TATOEBA_SENTENCE_FILE)
            @japaneseFile = Config::resolveDataFile(Config::TATOEBA_JAPANESE_FILE)
            @loadFileContext = LoadFileContext.new(@viewBridge)
		end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def loadSentences(language)
            @loadFileContext.onExit do
                loadLanguage(language)
            end
            @loadFileContext.enter(self, @db.sentences, @sentencesFile)
        end

        def loadLanguage(language)
            if language.eql?("Chinese")
                loadChinese
            else
                loadJapanese
            end
        end

        def loadJapanese
            @loadFileContext.onExit do
                exitLoadTatoebaContext
            end
            @loadFileContext.enter(self, @db.japaneseIndeces, @japaneseFile)
        end

        def loadChinese
            @loadFileContext.onExit do
                exitLoadTatoebaContext
            end
            @loadFileContext.enter(self, @db.chineseIndeces, "Chinese Indeces")
        end

        def exitLoadTatoebaContext
            self.exit
        end

        def startLongEvent()
            @parent.startLongEvent()
        end

        def stopLongEvent()
            @parent.stopLongEvent()
        end

        def enter(parent, tatoebaDatabase, options)
            super(parent)
            @db = tatoebaDatabase
            if !@db.sentences.loaded?
                loadSentences(options.language)
            else
                loadLanguage(options.language)
            end
        end
    end		
end

