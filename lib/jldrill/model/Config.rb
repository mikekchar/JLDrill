
module JLDrill
    module Config
        if !Gem.datadir("jldrill").nil?
            # Use the data directory in the Gem if it is available
            DATA_DIR = Gem.datadir("jldrill")
        else
            # Otherwise hope there is a data dir in current directory
            DATA_DIR = 'data/jldrill'
        end
    end
end
