#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005  Mike Charlton
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


require 'gtk2'

class GtkEnterFilename < Gtk::FileChooserDialog

	attr_reader :resp

	def initialize(directory,mainWindow)
		current_folder = directory
		super("Save File",
				mainWindow,
				Gtk::FileChooser::ACTION_SAVE,
				nil,
				[Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
				[Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])
		@resp = Gtk::Dialog::RESPONSE_CANCEL
	end
	
	def run
		@resp = super()
		if @resp == Gtk::Dialog::RESPONSE_ACCEPT
			return filename
		else
			return ""
		end
	end

end
