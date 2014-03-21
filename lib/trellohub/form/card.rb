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
            labels
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
          next if key == :card_badges
          instance_variable_set(:"@card_#{key}", card.send(key))
        end

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

      def build_issue_attributes_by_card
        @issue_title = @origin_card.name.gsub(card_name_prefix_matcher, '')
        @issue_state = @origin_card.closed ? 'closed' : 'open'

        if @origin_card.desc =~ key_matcher
          @issue_repository = $1
          @issue_number = $2

          repo = Trellohub.repository_by(full_name: @issue_repository)
          @issue_milestone = repo.milestone.title if repo.milestone?
        end

        unless @origin_card.idMembers.empty?
          member = Trellohub::Member.find_by(id: @origin_card.idMembers.first)
          @issue_assignee = member.username if member
        end

        list = Trellohub::List.find_by(id: @origin_card.idList)
        @issue_labels = list.name if list
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
