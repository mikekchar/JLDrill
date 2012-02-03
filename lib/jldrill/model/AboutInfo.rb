# encoding: utf-8
require 'jldrill/Version'

module JLDrill

    # Information about JLDrill. 
    class AboutInfo
        attr_reader :name, :version, :copyright, :license,
                    :comments, :website, :authors
                    
        def initialize
            @authors = ["Mike Charlton"]
		    @name = "JLDrill"
		    @version = JLDrill::VERSION
		    @copyright = "(C) 2005-2011 Mike Charlton"
		    @comments = "Drill Program for Learning Japanese."
            @website = "http://jldrill.rubyforge.org"
            @license = %Q[JLDrill - Drill Program for Learning Japanese
Copyright (C) 2005-2011  Mike Charlton

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any version specified by Mike Charlton.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Note: This license only covers the JLDrill software.  It doesn't
    cover the information in the data directory.  For more information
    on licenses for these files, please refer to the COPYING director
    in the data directory.
]
        end
    end
end
