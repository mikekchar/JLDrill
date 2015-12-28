# encoding: utf-8

module JLDrill

  # Resolves files based on a load path
  class LoadPath
    def initialize()
      @loadPath = []
    end

    # Returns true if the load path contains no entries
    def empty?()
      return @loadPath.empty?
    end

    # Find a file in the load path.
    # Returns nil if no such file exists, or the path the the file
    # highest up on the load path.
    def find(filename)
      return filename if File.exists?(filename)

      retVal = @loadPath.find do |path|
        File.exists?(File.join(path, filename))
      end
      if !retVal.nil?
        retVal = File.join(retVal, filename)
      end
      return retVal
    end

    # Add a path to the load path.
    # This path will be added to the end of the load path.
    # A path equalling nil will not be added
    def add(path)
      if !path.nil?
        @loadPath.push(path)
      end
    end

    # Return a string representation of the load path.
    # This is essentially the paths separated by colons.
    def to_s
      return @loadPath.join(":")
    end
  end
end

