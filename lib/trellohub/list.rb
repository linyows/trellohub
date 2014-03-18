require 'ostruct'
require 'trellohub/board'
require 'trellohub/lists'

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
      include Lists
    end
  end
end
