module JLDrill

    class Publisher
        attr_reader :source
        def initialize(source)
            @source = source
            @streamSubscribers = {}
            @blocked = false
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
        
        def unsubscribe(target, stream)
            if @streamSubscribers.has_key?(stream)
                targets = @streamSubscribers[stream]
                targets.delete(target)
            end
        end
        
        def update(stream)
            if blocked?
                return
            end
            if @streamSubscribers.has_key?(stream)
                @streamSubscribers[stream].each do |subscriber|
                    eval("subscriber." + stream + "Updated(@source)")
                end
            end
        end
        
        def blocked?
            @blocked
        end
        
        def block
            @blocked = true
        end
        
        def unblock
            @blocked = false
        end
    end

end
