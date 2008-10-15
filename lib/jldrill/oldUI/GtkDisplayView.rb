require 'gtk2'
require 'jldrill/model/Vocabulary'
require 'jldrill/oldUI/GtkVocabView'

module JLDrill::Gtk
    class GtkDisplayView < Gtk::Dialog

        def initialize(vocab, parentWindow)
            super("Vocabulary Display",
                  parentWindow,
                  Gtk::Dialog::DESTROY_WITH_PARENT,
                  [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                  [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])

            @quizV = GtkVocabView.new(vocab)

            refVocab = Vocabulary.new
            table = Gtk::Table.new(2, 1)
            table.attach(Gtk::Label.new("Quiz Vocab"), 0, 1, 0, 1,
                         0, 0, 10, 10)
            table.attach(@quizV, 0, 1, 1, 2,
                         Gtk::FILL | Gtk::EXPAND, Gtk::FILL, 10, 10)
            self.vbox.add(table)
        end

        def getVocab
            vocab = @quizV.getVocab()
            return vocab
        end

    end
end
