# encoding: utf-8
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
			
			expect(bridge.Fun).to be(Special::Fun)
			expect(bridge.In).to be(Other::Special::In)
			expect(bridge.Sun).to_not be(Excluded::Sun)
		end
	end
end
