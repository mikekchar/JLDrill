require 'Context/Spec'
require 'Context/require_all'
require 'Context/Context'

module Context::Spec::Require_AllStory
    describe Kernel do

        it "should have a unit test for require_all" do
            require_all 'Context/Gtk/*'
            Context::Gtk::App.new(Context, Context::Context).should_not be_nil
            class FakeWidget
                include Context::Gtk::Widget
            end
            # Really, we're just making sure it it exists
            FakeWidget.new.isInTests?.should_not be(nil)
        end
    end
end

