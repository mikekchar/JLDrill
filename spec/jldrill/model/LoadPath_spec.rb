# encoding: utf-8
require 'jldrill/model/LoadPath'
require 'jldrill/model/Config'

module JLDrill

	describe LoadPath do
        it "should not find files if empty" do
            lp = LoadPath.new
            lp.empty?().should eql(true)
            lp.find("file").should eql(nil)
        end

        it "should be able to add a directory to the load path" do
            lp = LoadPath.new
            lp.add(Config::DATA_DIR)
            lp.empty?().should eql(false)
            lp.to_s.should eql(Config::DATA_DIR)
        end

    end
end
	

