require 'ostruct'
require 'trellohub/board'

module Trellohub
  class List < OpenStruct
    def id
      @id ||= find_id
    end

    def find_id
      current_list = self.class.find_by(name: name)

      list = case
        when current_list && current_list.closed
          Trell.update_list(current_list.id, closed: false)
        when current_list.nil?
          Trell.create_list(name: name, idBoard: board_id)
        else
          current_list
        end

      list.id
    end

    def board_id
      Trellohub::Board.id
    end

    class << self
      def setup!
        Trellohub.lists.each do |list|
          list.id
        end
      end

      def all
        @all || self.all!
      end

      def all!
        @all = Trell.lists(Trellohub::Board.id)
      end

      def find_by(id: nil, name: nil)
        case
        when !id.nil?
          self.all.find { |list| list.id == id }
        when !name.nil?
          self.all.find { |list| list.name == name }
        else
          nil
        end
      end
    end
  end
end
