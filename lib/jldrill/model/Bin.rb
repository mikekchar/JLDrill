# encoding: utf-8
module JLDrill
  # Holds a group of items that are at the same level.
  class Bin < Array
    attr_reader :name, :number

    # Create a new bin and call it name
    def initialize(name, number)
      super(0)
      @name = name
      @number = number
      @nameRegExps = []
      addAlias(@name)
    end

    # Add a name that this bin might be called when parsing a file
    def addAlias(name)
      @nameRegExps.push(Regexp.new("^#{name}$", nil))
    end

    # add an array of aliases
    def addAliases(aliasList)
      aliasList.each do |name|
        addAlias(name)
      end
    end

    # Returns true if the bin is named or has an alias for
    # the string passed
    def isCalled?(name)
      return @nameRegExps.any? do |re|
        re.match(name)
      end
    end

    # Pushes a item to the end of the bin
    # Also sets the bin number of the item
    def push(item)
      item.state.moveTo(@number)
      super
    end

    # Insert an item before the index indicated
    def insert(index, item)
      if index >= size
        push(item)
      else
        item.state.moveTo(@number)
        super
      end
    end

    def moveBeforeItem(moveItem, beforeItem)
      index = find_index(beforeItem)
      if !index.nil?
        delete(moveItem)
        insert(index, moveItem)
      end
    end

    # Inserts an item before the one where
    # the block evaluates true.  If the block
    # never evaluates true, put the item at
    # the end
    def insertBefore(item, &block)
      i = 0
      while(!self[i].nil? && !block.call(i))
        i += 1
      end
      insert(i, item)
    end

    # Set the contents array to the value specified.  Also set the bin
    # number correctly
    def replace(array)
      super
      self.each do |item|
        item.state.moveTo(@number)
      end
      self
    end

    def copy_contents
      Array.new(self)
    end

    # Returns true if the Item exists in the bin
    def exists?(item)
      !find do |x|
        item.eql?(x)
      end.nil?
    end

    # Returns true if there is an Item in the bin that contains the object
    def contain?(object)
      !find do |x|
        x.contain?(object)
      end.nil?
    end

    # Returns a string containing all the item strings in the bin     
    def to_s
      @name + "\n" + self.join
    end
  end
end
