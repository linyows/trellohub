require 'trellohub/board'

module Trellohub
  module Lists
    def all
      @all || self.all!
    end

    def all!
      @all = Trell.lists(Trellohub::Board.id)
    end

    def find_by(name: nil)
      self.all.find { |list| list.name == name }
    end
  end
end
