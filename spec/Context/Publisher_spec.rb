# encoding: utf-8
require 'Context/Publisher'

module Context

    describe Publisher do
        
        it "should have a source" do
            source = double("Source")
            publisher = Publisher.new(source)
            publisher.source.should be(source)
        end
        
        it "should be able to subscribe to a publisher" do
            source = double("Source")
            target = double("Target")
            publisher = Publisher.new(source)
            publisher.subscribe(target, "status")
            target.should_receive(:statusUpdated).with(source)
            publisher.update("status")
        end
        
        it "should be able to update streams that aren't subscribed to" do
            source = double("Source")
            target = double("Target")
            publisher = Publisher.new(source)
            publisher.subscribe(target, "newProblem")
            target.should_not_receive(:statusUpdated).with(source)
            publisher.update("status")
        end
        
        it "should be able to subscribe multiple targets to a publisher" do
            source = double("Source")
            target1 = double("Target")
            target2 = double("Target")
            publisher = Publisher.new(source)
            publisher.subscribe(target1, "status")
            publisher.subscribe(target2, "status")
            target1.should_receive(:statusUpdated).with(source)
            target2.should_receive(:statusUpdated).with(source)
            publisher.update("status")
        end

        it "should be able to change the source" do
            source = double("Source")
            source2 = double("Source")
            target = double("Target")
            publisher = Publisher.new(source)
            publisher.subscribe(target, "status")
            target.should_receive(:statusUpdated).with(source2)
            publisher.update("status", source2)
        end
    end
end
