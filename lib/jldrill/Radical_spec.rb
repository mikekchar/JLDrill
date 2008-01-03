require 'Radical'

module JLDrill

	describe RadKEntry do

		it "should be able to parse an entry from the radkfile" do
			entryText = "$ 一 1\n"
			followingText = "亜唖姶悪\n"
			entryText += followingText
		
			entry = RadKEntry.parse(entryText)
			entry.should_not be_nil
			entry.radical.should be_eql("一")
			entry.strokes.should be(1)
			entry.altGlyph.should be_nil
			contents = entry.parseContents(followingText)
			contents.size.should be(4)
			entry.contents.size.should be(0)
			entry.add(contents)
			entry.contents.size.should be(4)
			entry.add(contents)
			entry.contents.size.should be(4)
		end
		
		it "should be able to parse an entry with a alternate glyph" do
			entryText = "$ 忙 3 3D38\n"
			followingText = "惟悦憶快怪\n"
			entryText += followingText
		
			entry = RadKEntry.parse(entryText)
			entry.should_not be_nil
			entry.radical.should be_eql("忙")
			entry.strokes.should be(3)
			entry.altGlyph.should be_eql(0x3d38)
			contents = entry.parseContents(followingText)
			contents.size.should be(5)
			entry.contents.size.should be(0)
			entry.add(contents)
			entry.contents.size.should be(5)
			entry.add(contents)
			entry.contents.size.should be(5)
		end
	end

	describe RadKComment do		
		it "should be able to parse a comment" do
			commentText = "# This is the data file that drives the multi-radical lookup method in XJDIC,\n"
			
			comment = RadKComment.parse(commentText)
			comment.should_not be_nil
			comment.contents.should be_eql(" This is the data file that drives the multi-radical lookup method in XJDIC,")
		end
	end
		
	describe RadKFile do
		it "should be able to parse a file in a string" do
			fileString = %Q[#
# This is a test file
# I hope that it works
$ 一 1
亜唖姶悪或夷椅畏異遺井郁一芋右窺丑云雲盈益榎延汚央岡下可夏寡河珂苛荷華嘩
画開碍垣劃隔岳橿且樺釜栢萱瓦寒干桓漢環看緩還基奇寄希棄稀貴騎儀宜犠義蟻誼
$ ｜ 1
亜唖逢悪以伊井稲印引鵜丑渦焔艶押横沖下果華嘩柿角樺鴨患諌陥貴糾旧供叫業曲
巾串屈掘窟勲薫慧継兼嫌研謙遣碁候洪甲耕購坤詐坐座挫再妻済犀斎剤在榊崎埼碕
作咋搾昨柵窄策錯冊撒散珊刺嗣師獅児爾璽軸雫湿篠朱殊珠種腫収州修洲繍酬重粛
]
			file = RadKFile.fromString(fileString)
			file.contents.size.should be(2)
			file.contents[0].radical.should be_eql("一")
			file.contents[0].strokes.should be(1)
			file.contents[0].contents.size.should be(72)
			file.contents[1].radical.should be_eql("｜")
			file.contents[1].strokes.should be(1)
			file.contents[1].contents.size.should be(108)
		end

		it "should be able to parse a file on disk" do
			file = RadKFile.open("data/jldrill/dict/radkfile.utf")
			file.should_not be(nil)
			file.contents.size.should be(248)
		end

	end	
end
