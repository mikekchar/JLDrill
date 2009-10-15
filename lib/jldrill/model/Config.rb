require 'rubygems'

module JLDrill
    # Configuration data for JLDrill.  This is how JLDrill knows where
    # to find it's data.
    module Config
        def Config::getDataDir
            if !Gem::datadir("jldrill").nil?
                # Use the data directory in the Gem if it is available
                File.expand_path(Gem::datadir("jldrill"))
            else
                # Otherwise hope there is a data dir in current directory
                File.expand_path('data/jldrill')
            end
        end
    
        DATA_DIR = getDataDir
        DICTIONARY_PATH = File.join(File.join(DATA_DIR, "dict"), "edict")
    end
end
