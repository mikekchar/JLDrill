require 'gtk2'
require 'jldrill/model/Vocabulary'

module JLDrill::Gtk
    class GtkIndicatorBox < Gtk::HBox

        def initialize
            super
            @uk = Gtk::Label.new
            @humble = Gtk::Label.new
            @honourific = Gtk::Label.new
            @pol = Gtk::Label.new
            @vs = Gtk::Label.new
            @vi = Gtk::Label.new
            @differs = Gtk::Label.new
            pack_start(@uk, true, true, 0)
            pack_start(@humble, true, true, 0)
            pack_start(@honourific, true, true, 0)
            pack_start(@pol, true, true, 0)
            pack_start(@vs, true, true, 0)
            pack_start(@vi, true, true, 0)
            pack_start(@differs, true, true, 0)
            clear
        end
        
        def clear
            self.uk = false
            self.humble = false
            self.honourific = false
            self.pol = false
            self.vs = false
            self.vi = false
            self.differs = false
        end
        
        def set(vocab, differs=false)
            self.uk = vocab.markers.include?("uk")
            self.humble = vocab.markers.include?("hum")
            self.honourific = vocab.markers.include?("hon")
            self.pol = vocab.markers.include?("pol")
            self.vs = vocab.markers.include?("vs")
            self.vi = vocab.markers.include?("vi")
            self.differs = differs
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
        
        def differs=(state)
            @differs.set_markup(getMarkup(" Differs ", state))
        end	
    end
end
