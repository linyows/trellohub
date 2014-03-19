require 'trellohub/board'

module Trellohub
  module Card
    class << self
      def all
        @all || self.all!
      end

      def all!
        @all = Trell.cards(Trellohub::Board.id)
      end

      def all_clear
        self.all.each { |card| Trell.delete_card(card.id) }
      end
    end
  end
end
