module JLDrill
    # Configuration data for JLDrill.  This is how JLDrill knows where
    # to find it's data. This file is for Debian packages.  Replace the
    # standard lib/jldrill/model/Config.rb with this file when packaging.
    module Config
        def Config::getDataDir
            # Debian keeps it's data files in /usr/share
            File.expand_path('/usr/share/jldrill')
        end
    
        DATA_DIR = getDataDir
        # Debian keeps Edict in usr/share/edict
        DICTIONARY_DIR = File.expand_path('/usr/share/edict')
        DICTIONARY_NAME = "edict"
        TANAKA_DIR = File.expand_path('/usr/share/jldrill/Tanaka')
        TANAKA_NAME = "examples.utf"
    end
end
