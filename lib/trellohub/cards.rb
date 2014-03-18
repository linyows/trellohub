require 'trellohub/board'

module Trellohub
  module Cards
    def valid_attributes
      %i(
        id
        checkItemStates
        closed
        dateLastActivity
        desc
        descData
        idBoard
        idList
        idMembersVoted
        idShort
        idAttachmentCover
        name
        pos
        shortLink
        badges
        due
        idChecklists
        idMembers
        labels
        shortUrl
        subscribed
      )
    end

    def other_attributes
      %i(
        key
        repository
        list_name
        members
        milestore
        issue
      )
    end

    def all_attributes
      self.valid_attributes + self.other_attributes
    end

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
