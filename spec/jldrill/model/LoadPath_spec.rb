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
            firstDir = File.join(Config::DATA_DIR, "tests/first")
            lp.add(firstDir)
            lp.empty?().should eql(false)
            lp.to_s.should eql(firstDir)
            lp.find("file").should eql(File.join(firstDir, "file"))
        end

        it "should not find files that don't exist" do
            lp = LoadPath.new
            firstDir = File.join(Config::DATA_DIR, "tests/first")
            lp.add(firstDir)
            lp.find("bogus").should eql(nil)
        end

        it "should prioritize directories added first" do
            lp = LoadPath.new
            firstDir = File.join(Config::DATA_DIR, "tests/first")
            secondDir = File.join(Config::DATA_DIR, "tests/second")
            neverDir = File.join(Config::DATA_DIR, "tests/Never")
            lp.add(firstDir)
            lp.add(secondDir)
            lp.add(neverDir)
            lp.to_s.should eql("#{firstDir}:#{secondDir}:#{neverDir}")
            lp.find("bogus").should eql(nil)
            lp.find("file").should eql(File.join(firstDir, "file"))
            lp.find("file2").should eql(File.join(secondDir, "file2"))
        end
    end
end
	

