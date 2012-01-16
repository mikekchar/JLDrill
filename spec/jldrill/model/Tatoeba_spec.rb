# encoding: utf-8
require 'jldrill/model/Tatoeba'
require 'jldrill/model/Config'

module JLDrill::Tatoeba
    describe SentenceFile do
        it "should be able to parse multiple entries" do
            file = %Q[1	cmn	我們試試看！
2	cmn	我该去睡觉了。
3	cmn	你在干什麼啊？
4	cmn	這是什麼啊？
5	cmn	今天是６月１８号，也是Muiriel的生日！
6	cmn	生日快乐Muiriel!
7	cmn	Muiriel现在20岁了。
8	cmn	密码是"Muiriel"。
9	cmn	我很快就會回來了。
10	cmn	我不知道。
11	cmn	我不知道應該說什麼才好。
12	cmn	這個永遠完不了了。
13	cmn	我只是不知道應該說什麼而已……
14	cmn	那是一隻有惡意的兔子。
15	cmn	我以前在山里。
120141	fra	Il y a quelques objets exposés intéressants au musée.
18	cmn	剛才我的麥克風沒起作用，不知道為什麼。
19	cmn	到了最後，大家一定要靠自己學習。
120138	fra	Il y avait un petit nombre d'étrangers parmi les visiteurs du musée.
21	cmn	选择什么是“对”或“错”是一项艰难的任务，我们却必须要完成它。
22	cmn	這樣做的話什麼都不會改變的。
23	cmn	這個要三十歐元。
24	cmn	我一天賺一百歐元。
25	cmn	也许我会马上放弃然后去睡一觉。
26	cmn	那是不會發生的。
27	cmn	我会尽量不打扰你复习。
28	cmn	不要擔心。
29	cmn	我很想你。
30	cmn	我明天回來的時候會跟他們聯絡。
31	cmn	我一直都比較喜歡神秘一點的人物。
32	cmn	你應該去睡覺了吧。
33	cmn	我要走了。
35	cmn	我不能活那種命。 ]
            tatoeba = SentenceFile.new
            tatoeba.dataSize.should be(0)
			tatoeba.lines = file.split("\n")
            tatoeba.loaded?.should be_false
            tatoeba.parse

			# It should not dispose of the lines after parsing because it needs them for searching
			tatoeba.lines.should_not eql([])
            tatoeba.loaded?.should be_true

            tatoeba.dataSize.should be(120142)
            tatoeba.sentenceAt(1).should eql("我們試試看！")
            tatoeba.sentenceAt(120138).should eql("Il y avait un petit nombre d'étrangers parmi les visiteurs du musée.")
            tatoeba.sentenceAt(300).should eql("")
        end
        
        it "should be able to read the file from disk" do
            tatoeba = SentenceFile.new
			tatoeba.load(File.join(JLDrill::Config::DATA_DIR, 
                                  "tests/sentences.csv"))
            tatoeba.parse

			tatoeba.lines.should_not eql([])

			tatoeba.dataSize.should be(1265634)
		end
    end
end


