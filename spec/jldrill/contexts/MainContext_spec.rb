require 'jldrill/contexts/MainContext'
require 'Context/Bridge'
require 'jldrill/spec/Fakes'

module JLDrill

	describe MainContext do

		before(:each) do
			@context = MainContext.new(Context::Bridge.new(JLDrill))
		end

        def test_openMainView
		    @parent = JLDrill::Fakes::App.new(nil)
		    @context.enter(@parent) 
		    @context.mainView.should_not be_nil       
        end
		
		it "should open the main view when it is entered" do
            test_openMainView
		end

		it "should exit the App when it is exited" do
            test_openMainView
		    @parent.should_receive(:exit)
		    @context.exit
		end

		it "should enter the loadReferenceContext when loading the reference" do
		    @context.loadReferenceContext.should_receive(:enter).with(@context)
		    @context.loadReference
		end

		it "should enter the setOptionsContext when setting the options" do
		    @context.setOptionsContext.should_receive(:enter).with(@context)
		    @context.setOptions
		end
		
		it "should enter the showStatisticsContext when showing statistics" do
		    @context.showStatisticsContext.should_receive(:enter).with(@context)
		    @context.showStatistics
		end
		
		it "should not try to open files if it doesn't get a filename" do
		    test_openMainView
		    @context.getFilenameContext.should_receive(:enter).with(@context).and_return(nil)
		    @context.quiz.should_not_receive(:load)
		    @context.quiz.should_not_receive(:loadFromDict)
		    @context.mainView.should_not_receive(:displayQuestion)
		    @context.openFile
		end
		
		it "should load drill files as drill files" do
		    test_openMainView
		    filename = "data/jldrill/quiz/katakana.jldrill"
		    @context.getFilenameContext.should_receive(:enter).with(@context).and_return(filename)
		    @context.quiz.should_receive(:load).with(filename)
		    # Because the quiz hasn't actually been loaded, we need to fake the
		    # drill here.
		    @context.quiz.should_receive(:drill).and_return("Fake")
		    @context.mainView.should_receive(:displayQuestion).with("Fake")
		    @context.openFile
		end
		
		it "should try to load any other file as an edict file" do
		    test_openMainView
		    filename = "data/jldrill/dict/Kana/katakana.utf"
		    @context.getFilenameContext.should_receive(:enter).with(@context).and_return(filename)
		    @context.quiz.should_receive(:loadFromDict)
		    # Because the dict hasn't actually been loaded, we need to fake the
		    # drill here.
		    @context.quiz.should_receive(:drill).and_return("Fake")
		    @context.mainView.should_receive(:displayQuestion).with("Fake")
		    @context.openFile
		end

	end
end
