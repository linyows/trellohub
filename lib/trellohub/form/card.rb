module Trellohub
  class Form
    module Card
      class << self
        def valid_attributes
          %i(
            closed
            desc
            idBoard
            idList
            name
            idMembers
          )
        end

        def accessible_attributes
          (self.valid_attributes + %i(
            list_name
          )).map { |key| :"card_#{key}" }
        end

        def readable_attributes
          %i(
            id
            labels
          ).map { |key| :"card_#{key}" }
        end

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Card.accessible_attributes)
            attr_reader(*Trellohub::Form::Card.readable_attributes)
          end
        end
      end

      def import_card(card)
        @origin_card = card.dup
        @imported_from = :card

        card.attrs.keys.each do |key|
          next if key == :badges
          instance_variable_set(:"@card_#{key}", card.send(key))
        end

        build_card_attributes_by_card
        build_issue_attributes_by_card
      end

      # e.g.
      # => #<MatchData
      # "synced_issue: https://github.com/linyows-Z_2/trellohub-foo_aaa-123/issues/127"
      # 1:"linyows-Z_2/trellohub-foo_aaa-123"
      # 2:"127">
      def key_matcher
        /synced_issue:\shttps?:\/\/.*?\/([\w\-\/]+)\/(?:issues|pulls)\/(\d+)/
      end

      def card_name_prefix_matcher
        /^[\w\-]+#\d+\s/
      end

      def build_card_attributes_by_card
        list = Trellohub::List.find_by(id: @origin_card.idList)
        @card_list_name = list.name if list
      end

      def build_issue_attributes_by_card
        @issue_title = @origin_card.name.gsub(card_name_prefix_matcher, '')
        @issue_state = @state = @origin_card.closed ? 'closed' : 'open'

        if @origin_card.desc =~ key_matcher
          @issue_repository = $1
          @issue_number = $2
          @key = "#{$1}##{$2}"

          repo = Trellohub.repository_by(full_name: @issue_repository)
          @issue_milestone = repo.milestone.title if repo.milestone?
        end

        unless @origin_card.idMembers.empty?
          member = Trellohub::Member.find_by(id: @origin_card.idMembers.first)
          @issue_assignee = member.username if member
        end

        if @card_list_name
          label = Trellohub.list_by(name: @card_list_name).issue_label
          @issue_labels = label ? [label] : []
        end
      end

      %i(create update delete).each do |cud|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def card_#{cud}d_at
            card_#{cud}_action.date if card_#{cud}_action
          end

          def card_#{cud}_user
            if card_#{cud}_action && card_#{cud}_action.memberCreator
              card_#{cud}_action.memberCreator.username
            end
          end

          def card_#{cud}_action
            @card_#{cud}_action ||= Trell.card_actions(@card_id, filter: '#{cud}Card').
              sort_by(&:date).last
          end
        METHODS
      end

      def card_update?
        !@card_id.nil?
      end

      def create_card
        Trell.create_card(to_valid_card)
      end

      def update_card
        Trell.update_card(@card_id, to_valid_card)
      end

      def close_card
        Trell.update_card(@card_id, to_valid_card.merge(closed: true))
      end

      def save_as_card
        case
        when card_update? && open? then update_card
        when card_update? && closed? then close_card
        when open? then create_card
        end
      end

      def to_valid_card
        Hash[Trellohub::Form::Card.valid_attributes.map { |key|
          [key, instance_variable_get(:"@card_#{key}")]
        }]
      end

      def to_card
        Hash[Trellohub::Form::Card.accessible_attributes.map { |key|
          [
            key.to_s.gsub('card_', '').to_sym,
            instance_variable_get(:"@#{key}")
          ]
        }]
      end
    end
  end
end
