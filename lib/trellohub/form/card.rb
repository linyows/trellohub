module Trellohub
  class Form
    module Card
      class << self
        def valid_attributes
          %i(
            id
            closed
            desc
            idBoard
            idList
            idShort
            name
            pos
            shortLink
            due
            idChecklists
            idMembers
            labels
            shortUrl
          )
        end

        def attributes
          self.valid_attributes.map do |key|
            :"card_#{key}"
          end
        end

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Card.attributes)
          end
        end
      end

      def import_card(card)
        @origin_card = card.dup

        card.attrs.keys.each do |key|
          instance_variable_set(:"@card_#{key}", card.send(key))
        end

        build_issue_attributes_by_card
      end

      def build_issue_attributes_by_card
        if @origin_card.desc =~ /issue:\s(([\w\-\/]+)#(\d+))\s/
          @issue_repository = $1
          @issue_number = $3
        end
        @issue_title = @origin_card.name.gsub(/^[\w\-]+#\d+\s/, '')
        unless @origin_card.idMembers.empty?
          @issue_assignee = Trellohub::Member.find_by(id: @origin_card.idMembers.first)
        end
        @issue_labels = Trellohub::List.find_by(id: @origin_card.idList)
        #@issue_milestone =
      end

      def save_as_card
      end

      def to_card
        Hash[Trellohub::Form::Card.valid_attributes.map { |key|
          [key, instance_variable_get(:"@card_#{key}")]
        }]
      end
    end
  end
end
