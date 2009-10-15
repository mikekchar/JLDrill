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
        DICTIONARY_PATH = File.expand_path('/usr/share/edict/edict')
    end
end
