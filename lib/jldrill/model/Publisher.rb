module JLDrill

    class Publisher
        attr_reader :source
        def initialize(source)
            @source = source
            @streamSubscribers = {}
        end
        
        def subscribe(target, stream)
            if @streamSubscribers.has_key?(stream)
                targets = @streamSubscribers[stream]
                if !targets.find do |x|
                        x == target
                    end
                    targets.push(target)
                end
            else
                @streamSubscribers[stream] = [target]
            end
        end
        
        def update(stream)
            if @streamSubscribers.has_key?(stream)
                @streamSubscribers[stream].each do |subscriber|
                    eval("subscriber." + stream + "Updated(@source)")
                end
            end
        end
    end

end
