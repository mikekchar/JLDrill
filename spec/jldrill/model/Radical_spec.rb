require 'jldrill/model/moji/Radical'
require 'jldrill/model/Config'

module JLDrill

	describe Radical do

		it "should be able to parse an entry from the radkfile" do
			entryText = "一		いち	one	亜唖姶\n"
		
			entry = Radical.parse(entryText)
			entry.should_not be_nil
			entry.radical.should eql("一")
			entry.reading.should eql("いち")
			entry.altGlyphs.size.should be(0)
			entry.meaning.should eql("one")
			entry.contents.size.should be(3)
			entry.contents[0].should eql("亜")
			entry.contents[1].should eql("唖")
			entry.contents[2].should eql("姶")
			entry.to_s.should eql("一   いち - one")
		end
		
		it "should be able to parse an entry with an alternate glyph" do
			entryText = "乙	乚	おつ	fish hook	曳洩奄掩\n"
			entry = Radical.parse(entryText)
			entry.should_not be_nil
			entry.radical.should eql("乙")
			entry.reading.should eql("おつ")
			entry.altGlyphs.size.should be(1)
			entry.altGlyphs[0].should eql("乚")
			entry.meaning.should eql("fish hook")
			entry.contents.size.should be(4)
			entry.contents[0].should eql("曳")
			entry.contents[1].should eql("洩")
			entry.contents[2].should eql("奄")
			entry.contents[3].should eql("掩")
			entry.to_s.should eql("乙(乚)   おつ - fish hook")
		end
		
		it "should be able to parse an entry with multiple alternate glyphs" do
		    entryText = "己	已巳	おのれ	snake	改鞄"
			entry = Radical.parse(entryText)
			entry.should_not be_nil
			entry.radical.should eql("己")
			entry.reading.should eql("おのれ")
			entry.altGlyphs.size.should be(2)
			entry.altGlyphs[0].should eql("已")
			entry.altGlyphs[1].should eql("巳")
			entry.meaning.should eql("snake")
			entry.contents.size.should be(2)
			entry.contents[0].should eql("改")
			entry.contents[1].should eql("鞄")
			entry.to_s.should eql("己(已,巳)   おのれ - snake")
		end
	end
	
	describe RadicalList do
		it "should be able to parse a file in a string" do
			fileString = 
%Q[一		いち	one	亜唖姶悪或夷椅畏異遺井郁芋右窺丑云雲盈益榎延汚央岡下可夏寡河珂苛荷華嘩画開碍垣劃隔岳橿且樺釜栢萱瓦寒干桓漢環看緩還基奇寄希棄稀貴騎儀宜犠義蟻誼議丘朽求虚供彊興尭業極桐倶具勲君薫群郡恵慧兼券喧圏拳捲遣乎五互伍吾悟梧碁語乞光后宏巧恒晃更梗構洪溝硬紘綱肱講購号合佐左査再最塞妻才犀在材財肴崎埼碕柵冊三参惨珊蚕伺使司嗣屍師施死至詞
｜		ぼう	stick	亜唖逢悪以伊井稲印引鵜丑渦焔艶押横沖下果華嘩柿角樺鴨患諌陥貴糾旧供叫業曲巾串屈掘窟勲薫慧継兼嫌研謙遣碁候洪甲耕購坤詐坐座挫再妻済犀斎剤在榊崎埼碕作咋搾昨柵窄策錯冊撒散珊刺嗣師獅児爾璽軸雫湿篠朱殊珠種腫収州修洲繍酬重粛出衝鍾乗剰伸申神紳酢垂帥睡錘菅世瀬整斉惜昔籍拙撰選岨措狙疎祖租粗組阻喪奏捜挿曹槽漕糟遭束速袖存唾帯戴泰
丶		てん	dot	以浦永泳詠往欧殴鴎蒲釜鎌寒丸機気稀偽及救求球兇凶恐挟狭胸玉禽区躯駆犬国叉肴殺桟残似雫執勺尺杓灼酌釈主就州洲蹴酬住塾熟術述丈刃尽靭勢斥浅賎践銭訴双太汰駄丹築筑昼柱注註駐掴釣的兎菟冬忍認葱熱之博薄縛帆汎泌秘柊氷豹不敷舗鋪圃捕甫補輔簿宝乏凡密蜜尤籾匁約訳猷卵吏梁歪鷲亙丕丼仞仭偬傅兔冤劔劒剱匆匍厖咏哺囈坏埔妁孰孵寃尨巉怱怺愡愽戍
]
			list = RadicalList.fromString(fileString)
			list.size.should be(3)
			list[0].radical.should eql("一")
			list[0].contents.size.should be(161)
			list[1].radical.should eql("｜")
			list[1].contents.size.should be(159)
			list[2].radical.should eql("丶")
			list[1].contents.size.should be(159)
			list.radicals("一").size.should be(1)
		end

		it "should be able to parse a file on disk" do
			list = RadicalList.fromFile(JLDrill::Config::getDataDir + 
			                                "/dict/rikaichan/radicals.dat")
			list.should_not be(nil)
			list.size.should be(256)
			radicals = list.radicals("一")
			radicals.size.should be(1)
			radicals.includesChar?("一").should be(true)
			radicals = list.radicals("酒")
			radicals.size.should be(2)
			radicals.includesChar?("氵").should be(true)
			radicals.includesChar?("酉").should be(true)
			radicals.to_s.should eql("酉   ひよみのとり - sake\n氵   さんずい - water\n")
		end

	end	
end
