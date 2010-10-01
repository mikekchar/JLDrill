require 'rubygems'

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
            File.expand_path(File.join(Config::configSrcDir, "../../.."))
        end

        def Config::getDataDir
            if !Gem::datadir("jldrill").nil?
                # Use the data directory in the Gem if it is available
                File.expand_path(Gem::datadir("jldrill"))
            else
                # Otherwise hope we are in a source repository and
                # can find the data dir in the usual spot
                File.join(repositoryDir, "data/jldrill")
            end
        end
    
        DATA_DIR = getDataDir
        DICTIONARY_DIR = File.join(DATA_DIR, "dict")
        DICTIONARY_NAME = "edict"
		TANAKA_DIR = File.join(DATA_DIR, "Tanaka")
		TANAKA_NAME = "examples.utf"
    end
end
