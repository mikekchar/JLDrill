
module JLDrill
    module Config
        def Config::getDataDir
            if !Gem.datadir("jldrill").nil?
                # Use the data directory in the Gem if it is available
                Gem.datadir("jldrill")
            else
                # Otherwise hope there is a data dir in current directory
                'data/jldrill'
            end
        end
    
        DATA_DIR = getDataDir
    end
end
