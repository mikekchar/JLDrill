# encoding: utf-8
require 'Context/Context'
require 'Context/Bridge'
require 'jldrill/model/Config'
require 'jldrill/contexts/FileProgressContext'

module JLDrill

    # Shows progress while merging two quiz files
	class MergeQuizContext < FileProgressContext
		
		def initialize(viewBridge)
			super(viewBridge)
            @quiz1 = nil
            @quiz2 = nil
		end

        def getFilename
            return "Merging #{@quiz1.name} with #{@quiz2.name} data"
        end

        def readFile
            size = @quiz2.length
            pos = 0
            sortedItems = @quiz1.contents.getSortedItems
            appendedItems = @quiz2.contents.allItems
            @mainView.idle_add do
                limit = pos + @quiz1.stepSize
                if limit > size then limit = size end
                while (pos < limit)
                    item = appendedItems[pos]
                    if !sortedItems.binarySearch(item)
                        item.position = -1
                        @quiz1.contents.addItem(item, item.bin)
                    end
                    pos += 1
                    @mainView.update(pos.to_f / size.to_f)
                end
                pos >= size
            end
        end

        def isValid?(parent)
            return !parent.nil? && !@quiz1.nil? && !@quiz2.nil?
        end

        def enter(parent, quiz1, quiz2)
            @quiz1 = quiz1
            @quiz2 = quiz2
            super(parent)
        end

        def exit
            @quiz1.updateLoad
            super
        end
    end
end
