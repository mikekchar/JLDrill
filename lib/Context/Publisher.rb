module Context

    # Publisher implements an observer pattern.
    # An object creates a Publisher, using itself as the source.
    # It can then publish to several different streams.  Observers can
    # subscribe to a stream.  When the stream for an observer
    # is updated, a method on each observer, named <stream>Updated(),
    # is called. The source is passed to this method.
    # In Context, Publishers are usually used to notify Contexts
    # when model objects have been updated (and hence the view
    # needs to change).
    class Publisher
        attr_reader :source

        # Create a Publisher with the source as the source object.
        def initialize(source)
            @source = source
            @streamSubscribers = {}
            @blocked = false
        end
        
        # Subscribe an observer to a stream.  The stream must be
        # a string.  It is allowable to observe to streams that
        # don't exist.  The observer *must* implement
        # <stream>Updated(source).  For example if in a method
        # of class A I write: 
        #      publisher.subscribe(self, "hello")
        # then A *must* implement the method helloUpdated(source)
        # otherwise the program will crash when the stream
        # is publish.
        def subscribe(observer, stream)
            if @streamSubscribers.has_key?(stream)
                observers = @streamSubscribers[stream]
                if !observers.find do |x|
                        x == observer
                    end
                    observers.push(observer)
                end
            else
                @streamSubscribers[stream] = [observer]
            end
        end
        
        # Unsubscribe an observer from the stream.
        # Remove the observer from the list of objects
        # that are subscribed to the stream.
        # Very Important Note: If you don't unsubscribe
        # from a publisher at the end of the lifetime
        # of your object, the publisher will retain
        # a reference to the object.  This means it will
        # continue to exist until the publisher is destroyed.
        # This could potentially cause problems in your code.
        # *Always* unsubscribe from a Publisher when you are
        # finished with the object.
        def unsubscribe(observer, stream)
            if @streamSubscribers.has_key?(stream)
                observers = @streamSubscribers[stream]
                observers.delete(observer)
            end
        end
        
        # Publish to the observers that the stream has been updated.
        # This is usually called by the source object, but it
        # doesn't have to be.  The source object can also be changed
        # (it defaults to the source in the Publisher).  This is
        # useful if a source is publishing on behalf of another object
        # (essentially acting as a mediator).
        def update(stream, source=@source)
            if blocked?
                return
            end
            if @streamSubscribers.has_key?(stream)
                @streamSubscribers[stream].each do |subscriber|
                    eval("subscriber." + stream + "Updated(source)")
                end
            end
        end

        # Returns true if the publisher is blocked.
        # A blocked publisher will not publish, even if
        # update() is called.
        def blocked?
            @blocked
        end
        
        # Block a publisher from publishing.  A blocked publisher
        # will not publish to observers, even if update() is
        # called.  This is useful for when you know that the
        # source is being updated a lot and you only want to
        # signal it at the end (for instance when you are loading
        # a file).
        # Important Note: block() and unblock() are not counted.
        # No matter how many times you call block(), the first
        # unblock() will unblock it.
        def block
            @blocked = true
        end
        
        # Unblock a publisher so that it may continue to publish.
        # Important Note: block() and unblock() are not counted.
        # No matter how many times you call block(), the first
        # unblock() will unblock it.
        def unblock
            @blocked = false
        end
    end

end
