# -*- coding: utf-8 -*-
require 'jldrill/model/moji/Kana'
require 'jldrill/model/Config'

module JLDrill

	describe KanaFile do
	
		it "should be able to read the file in chunks" do
			kf = KanaFile.new
			kf.lines.size.should be(0)
			kf.file = (File.join(Config::DATA_DIR, "tests/kana.dat"))
			kf.readLines
			kf.lines.size.should be(100)
			# Not EOF yet
			kf.parseChunk(10).should eql(false)
			kf.fraction.should eql(0.10)
			kf.parseChunk(10).should eql(false)
			kf.fraction.should eql(0.20)
			# Read to the EOF
			kf.parseChunk(1000).should eql(true)

			# It should dispose of the unparsed lines after parsing
			kf.fraction.should eql(0.0)
			kf.lines.should eql([])

			kf.kanaList.size.should eql(100)
		end
    end
end
