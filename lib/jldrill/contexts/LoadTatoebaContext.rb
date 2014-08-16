# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/LoadFileContext'
require 'jldrill/model/exampleDB/Tatoeba'

module JLDrill

    # Load the kanji, radicals and kana files one after another.
    class LoadTatoebaContext < Context::Context

        attr_reader :sentencesFile, :japaneseFile
        attr_writer :sentencesFile, :japaneseFile

        def initialize(viewBridge)
            super(viewBridge)
            @sentencesFile = Config::resolveDataFile(Config::TATOEBA_SENTENCE_FILE)
            @japaneseFile = Config::resolveDataFile(Config::TATOEBA_JAPANESE_FILE)
            @tagalogFile = Config::resolveDataFile(Config::TATOEBA_TAGALOG_FILE)
            @linksFile = Config::resolveDataFile(Config::TATOEBA_LINKS_FILE)
            @loadFileContext = LoadFileContext.new(@viewBridge)
        end

        def createViews
            @mainView =  @viewBridge.VBoxView.new(self)
        end

        def destroyViews
            @mainView = nil
        end

        def loadSentences()
            @loadFileContext.onExit do
                loadLanguage()
            end
            @loadFileContext.enter(self, @db.sentences, @sentencesFile)
        end

        def loadLanguage()
            language = @parent.quiz.options.language
            case language
            when "Chinese"
                loadChinese
            when "Tagalog"
                loadTagalog
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
            @loadFileContext.enter(self, @db.chineseIndeces, @linksFile)
        end

        def loadTagalog
            @loadFileContext.onExit do
                exitLoadTatoebaContext
            end
            @loadFileContext.enter(self, @db.tagalogIndeces, @tagalogFile)
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

        def enter(parent, tatoebaDatabase)
            super(parent)
            @db = tatoebaDatabase
            if !@db.sentences.loaded?
                loadSentences()
            else
                loadLanguage()
            end
        end
    end
end
