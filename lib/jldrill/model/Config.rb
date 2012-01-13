# encoding: utf-8
require 'rubygems'
require 'jldrill/model/LoadPath'

module JLDrill
    # Configuration data for JLDrill.  This is how JLDrill knows where
    # to find it's data.
    module Config
        def Config::configSrcDir
            File.expand_path(File.dirname(__FILE__))
        end

        # In a source repository, this gives the top level directory
        # If the source has been installed by a package, then who knows
        # where this is...
        def Config::repositoryDir
            File.expand_path(File.join(Config::configSrcDir, 
                                       File.join("..","..","..")))
        end

        def Config::getDataDir
            if !Gem::datadir("jldrill").nil?
                # Use the data directory in the Gem if it is available
                File.expand_path(Gem::datadir("jldrill"))
            else
                # Otherwise hope we are in a source repository and
                # can find the data dir in the usual spot
                File.join(repositoryDir, "data","jldrill")
            end
        end

        PERSONAL_DATA_DIR = File.expand_path(File.join("~",".jldrill")) 
        REPO_DATA_DIR = File.join(Config::repositoryDir, "data","jldrill")
        if !Gem::datadir("jldrill").nil?
            GEM_DATA_DIR = File.expand_path(Gem::datadir("jldrill"))
        else
            GEM_DATA_DIR = nil
        end
        DEBIAN_DATA_DIR = File.join("/","usr","share","jldrill")
        DEBIAN_EDICT_DIR = File.join("/","usr","share","edict")

        def Config::resolveDataFile(filename)
            retVal = nil
            loadPath = LoadPath.new
            loadPath.add(PERSONAL_DATA_DIR)
            loadPath.add(REPO_DATA_DIR)
            loadPath.add(GEM_DATA_DIR)
            loadPath.add(DEBIAN_DATA_DIR)
            loadPath.add(DEBIAN_EDICT_DIR)
            return loadPath.find(filename)
        end

        DATA_DIR = getDataDir
        QUIZ_DIR = "quiz"
        SVG_ICON_FILE = "jldrill-icon.svg"
        PNG_ICON_FILE = "jldrill-icon.png"
        DICTIONARY_DIR = "dict"
        DICTIONARY_FILE = "edict"
        KANJI_FILE = File.join("dict","rikaichan","kanji.dat")
        RADICAL_FILE = File.join("dict","rikaichan","radicals.dat")
        KANA_FILE = File.join("dict","Kana","kana.dat")
		TANAKA_FILE = File.join("Tanaka","examples.utf")
		DEINFLECTION_FILE = File.join("dict","rikaichan","deinflect.dat")
    end
end
