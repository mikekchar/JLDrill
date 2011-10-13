# encoding: utf-8

module JLDrill

    # A container to hold the status of each kind of drill for the item.
    class ItemStatus
        
        attr_reader :statuses, :item

        def initialize(item)
            @item = item
            @statuses = {}
        end

        def add(status)
            @statuses[status.name] = status
        end

        def assign(itemStatus)
            itemStatus.statuses.each_value do |status|
                newStatus = status.clone
                newStatus.item = @item
                add(status.clone)
            end
        end

        def select(name)
            return @statuses[name]
        end

        def parse(part)
            parsed = false
            statuses = @statuses.values
            i = 0
            while (i < statuses.size) && (!parsed)
                parsed = statuses[i].parse(part)
                i += 1
            end
            return parsed
        end

        def to_s
            retVal = ""
            statuses.keys().sort.each do |key|
                retVal += statuses[key].to_s
            end
            return retVal
        end
    end
end
