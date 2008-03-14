#    JLDrill - A program to drill various aspects of the Japanese Language
#    Copyright (C) 2005-2007  Mike Charlton
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
require 'jldrill/model/Vocabulary'

class GtkIndicatorBox < Gtk::HBox

	def initialize
		super
		@uk = Gtk::Label.new
		@humble = Gtk::Label.new
		@honourific = Gtk::Label.new
		@pol = Gtk::Label.new
		@vs = Gtk::Label.new
		@vi = Gtk::Label.new
		pack_start(@uk, true, true, 0)
		pack_start(@humble, true, true, 0)
		pack_start(@honourific, true, true, 0)
		pack_start(@pol, true, true, 0)
		pack_start(@vs, true, true, 0)
		pack_start(@vi, true, true, 0)
		clear
	end
	
	def clear
		self.uk = false
		self.humble = false
		self.honourific = false
		self.pol = false
		self.vs = false
		self.vi = false
	end
	
	def set(vocab)
		self.uk = vocab.markers.include?("uk")
		self.humble = vocab.markers.include?("hum")
		self.honourific = vocab.markers.include?("hon")
		self.pol = vocab.markers.include?("pol")
		self.vs = vocab.markers.include?("vs")
		self.vi = vocab.markers.include?("vi")
	end
	
	def getSpan(label, state)
		if state
			span = %Q[<span foreground = "white" background="red" weight="bold">]
		else
			span = "<span>"
		end
		span = span + label + "</span>"
		
		return span
	end
	
	def getMarkup(label, state)
		"<markup>" + getSpan(label, state) + "</markup>"
	end
	
	def uk=(state)
		@uk.set_markup(getMarkup(" Usually Kana ", state))
	end
	
	def humble=(state)
		@humble.set_markup(getMarkup(" Humble ", state))
	end
	
	def honourific=(state)
		@honourific.set_markup(getMarkup(" Honourific ", state))
	end

	def pol=(state)
		@pol.set_markup(getMarkup(" Polite ", state))
	end

	def vs=(state)
		@vs.set_markup(getMarkup(" Suru Noun ", state))
	end
	
	def vi=(state)
		@vi.set_markup(getMarkup(" Intransitive ", state))
	end	
end
