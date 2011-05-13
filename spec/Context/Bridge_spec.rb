require 'Context/Spec'
require 'Context/Bridge'

module Context::Spec::BridgeStory

    module Other
        module Special
            class Fun
            end
            
            class In
            end
        end
    end

    module Special
        class Fun
        end
    end

    class Fun
    end
    
    module Excluded
        class Sun
        end    
    end

	describe Context::Bridge do

		it "should reference classes in the namespace provided" do
			bridge = Context::Bridge.new([Special, Other::Special])
			
			bridge.Fun.should be(Special::Fun)
			bridge.In.should be(Other::Special::In)
			bridge.Sun.should_not be(Excluded::Sun)
		end
	end
end
