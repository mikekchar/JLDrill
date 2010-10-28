require 'Context/Publisher'

module JLDrill
    # This class represents a data file in JLDrill.   This
    # is an abstract class meant to define the interface
    # for having a file which can be read in the background
    # in JLDrill.
    class DataFile
        attr_reader :file, :lines, :parsed, :publisher, :stepSize
        attr_writer :lines, :stepSize

        def initialize
            @publisher = Context::Publisher.new(self)
            # Default to reporting every 100 lines
            @stepSize = 100
            self.reset
        end

        # Returns the number of items you have created
        def dataSize
            # Please implement this in the concrete class
        end

        # Returns a reference to the object that can parse a line
        def parser
            # Please implement this in the concrete class unless
            # you modify the parseEntry() method to directly access
            # the parser.
        end

        # Resets the file
        def reset
            @file = ""
            @lines = []
            @parsed = 0
            setLoaded(false)
            # Please define the rest of the method and call super()
            # at the end.
        end

        # Sets the filename of the file and resets the data.
        def file=(filename)
            if @file != filename
                @file = filename
            end
        end

        # Indicate to the outside world that the file is loaded
        def setLoaded(bool)
            if bool
                @publisher.update("loaded")
            end
        end

        # Returns true if there is no more data to parse
		def eof?
			return @parsed >= @lines.size
		end

        # Returns true if the we have completed parsing a file
		def loaded?
			return eof? && (dataSize > 0)
		end

        # Returns a float showing the percentage of the file that
        # has been parsed so far.
		def fraction
			retVal = 0.0
			if @lines.size != 0
				retVal = @parsed.to_f / @lines.size.to_f
			end
			return retVal
		end

        # Read the file into memory.  This is done before parsing
        def readLines
            begin
                @lines = IO.readlines(@file)
            rescue
                Context::Log::warning("JLDrill::DataFile",
                                      "Could not load #{@file}.")
                @lines = []
            end
            @parsed = 0
        end

        # Load in the file data, but don't parse it yet
		def load(file)
            reset
			@file = file
			readLines
		end

        # Parse the entire file all at once
		def parse
			parseChunk(@lines.size)
		end

        # Parses one entry from the lines.
        # The default parses a single line from the lines.
        # You can override this for files whose entries span more than one line.
        def parseEntry
            parser.parse(@lines[@parsed])
            @parsed += 1
        end

        # Parse a chunk of the file.  Size shows how many entries
        # to parse
		def parseChunk(size)
            # We don't want to get updated when we parse a large block of data
            @publisher.block

			last = @parsed + size
			if last > @lines.size
				last = @lines.size
			end
			while @parsed < last do
                parseEntry
			end
            @publisher.unblock

			# If the parsing is finished dispose of the unparsed lines
			finished = self.eof?
			if finished
                finishParsing
			end

			return finished
		end

        # Usually we want to delete the original source lines when
        # we are finished parsing.  But some files are only
        # partially parsed on reading (like Edict). 
        # Please redefine this if you want to keep the source
        # lines around for some reason.
        def finishParsing
            @lines = []
            @parsed = 0
            setLoaded(true)
        end

        # Returns the filename without the path
        def shortFilename
            if @file.nil? || @file.empty?
                return "No name"
            end
            return File.basename(file)
        end

    end
end
