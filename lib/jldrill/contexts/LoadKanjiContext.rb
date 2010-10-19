require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

	class LoadKanjiContext < FileProgressContext

        attr_reader :kanjiFile, :radicalsFile, :kanaFile
        attr_writer :kanjiFile, :radicalsFile, :kanaFile
		
		def initialize(viewBridge)
			super(viewBridge)
		    @kanjiFile = Config::getDataDir + "/dict/rikaichan/kanji.dat"
            @radicalsFile = Config::getDataDir + "/dict/rikaichan/radicals.dat"
            @kanaFile = Config::getDataDir + "/dict/Kana/kana.dat"
            @pass = 0
		end

        # Gives each filename one after another
        def getFilename
            if @pass == 0
                return @radicalsFile
            elsif @pass == 1
                return @kanjiFile
            elsif @pass == 2
                return @kanaFile
            else
                return nil
            end
        end

        def getFile
            if @pass == 0
                return @parent.radicals
            elsif @pass == 1
                return @parent.kanji
            elsif @pass == 2
                return @parent.kana
            else
                return nil
            end
        end

        def finishParsing
            # Recursively load the files until they are all finished
            @pass += 1
            if getFilename != nil
                self.enter(@parent)
            end
        end

    end		
end
