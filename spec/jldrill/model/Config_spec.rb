# encoding: utf-8
require 'jldrill/model/Config'

module JLDrill

	describe Config do
	
	    it "should have a DATA_DIR" do
	        Config::DATA_DIR.should_not be_nil
	    end

        it "should not be using the Gem DATA_DIR in the tests" do
            Config::DATA_DIR.should eql(File.expand_path("data/jldrill"))
        end

        it "should use the Gem::datadir if set" do
            def Gem.datadir(string)
                "blah"
            end
	        Config::getDataDir.should eql(File.expand_path("blah"))
            # Reset this so the other tests don't fail
            def Gem.datadir(string)
                nil
            end
            Config::DATA_DIR.should eql(File.expand_path("data/jldrill"))
        end

        it "should load files according to the load path" do
        end
    end
end
