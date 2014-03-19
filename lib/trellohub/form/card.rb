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

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Card.valid_attributes)
          end
        end
      end

      def import_card(card)
        card.attrs.keys.each do |attr|
          instance_variable_set(:"@#{attr == :id ? :card_id : attr}", card.send(attr))
        end
      end

      def save_as_card
      end

      def to_card
        Hash[Trellohub::Form::Card.valid_attributes.map { |key|
          [key, instance_variable_get(:"@#{key == :id ? :card_id : key}")]
        }]
      end
    end
  end
end
