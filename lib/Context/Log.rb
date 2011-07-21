# encoding: utf-8
module Context

    # Implements some rudimentary logging for context.
    # This is basically just to output warnings.
    class Log
         def Log::warning(system, message)
             $stderr.print("WARNING #{system}: #{message}\n")
         end
    end
end
