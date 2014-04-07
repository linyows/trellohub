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
          self.prefix(self.valid_attributes + %i(list_name members))
        end

        def readable_attributes
          self.prefix %i(labels)
        end

        def prefix(array)
          array.map { |key| :"card_#{key}" }
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

      def issue_creation_matcher
        /^((?:[\w\-]+\/)?([\w\-]+))#\s/
      end

      def card_name_prefix_matcher
        /^[\w\-]+#(\d+)?\s/
      end

      def scrum_point_matcher
        /\(\d+\)/
      end

      def build_card_attributes_by_card
        list = Trellohub::List.find_by(id: @origin_card.idList)
        @card_list_name = list.name if list

        @card_members = @origin_card.idMembers.map { |member_id|
          member = Trellohub::Member.find_by(id: member_id)
          member.username if member
        }.compact unless @origin_card.idMembers.empty?
      end

      def sanitized_card_name
        @origin_card.name.gsub(scrum_point_matcher, '').strip
      end

      def card_name_without_prefix
        sanitized_card_name.gsub(card_name_prefix_matcher, '').strip
      end

      def build_issue_attributes_by_card
        @issue_title = card_name_without_prefix
        @issue_state = @state = @origin_card.closed ? 'closed' : 'open'

        if @origin_card.desc =~ key_matcher
          @issue_repository = $1
          @issue_number = $2
          @key = "#{$1}##{$2}"
          assign_issue_milestone_by_card

        elsif sanitized_card_name =~ issue_creation_matcher
          search_key = $1 == $2 ? :name : :full_name
          repo = Trellohub.repository_by(:"#{search_key}" => $1)
          if repo
            @issue_repository = repo.full_name
            assign_issue_milestone_by_card
          end
        end

        assign_issue_assignee_by_card
        assign_issue_labels_by_card
      end

      def assign_issue_milestone_by_card
        repo = Trellohub.repository_by(full_name: @issue_repository)

        if repo && repo.milestone?
          @issue_milestone = repo.milestone.number
          @issue_milestone_title = repo.milestone.title
        end
      end

      def assign_issue_assignee_by_card
        return if @origin_card.idMembers.empty?
        member = Trellohub::Member.find_by(id: @origin_card.idMembers.first)
        @issue_assignee = member.username if member
      end

      def assign_issue_labels_by_card
        return unless @card_list_name
        label = Trellohub.list_by(name: @card_list_name).issue_label
        @issue_labels = label ? [label] : []
      end

      %i(create update delete).each do |cud|
        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def card_#{cud}d_at
            return if @card_id.nil?
            card_#{cud}_action.date if card_#{cud}_action
          end

          def card_#{cud}_user
            return if @card_id.nil?
            if card_#{cud}_action && card_#{cud}_action.memberCreator
              card_#{cud}_action.memberCreator.username
            end
          end

          def card_#{cud}_action
            return if @card_id.nil?
            @card_#{cud}_action ||= Trell.card_actions(@card_id, filter: '#{cud}Card').
              sort_by(&:date).last
          rescue Trell::NotFound
          end
        METHODS
      end

      def card_id
        if @card_id.nil? && @imported_from == :issue
          form = Trellohub::Form.with_cards.find_by_key(@key)
          @card_id = form.card_id if form
        end

        @card_id
      end

      def card_id?
        !card_id.nil?
      end

      def create_card?
        open?
      end

      def update_card?
        card_id? && open?
      end

      def close_card?
        card_id? && close?
      end

      def print_card_attributes(title = nil)
        print_attributes('card', title)
      end

      def create_card
        print_card_attributes('Create a Card')
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
        when update_card? then update_card
        when close_card? then close_card
        when create_card? then create_card
        end
      end

      def delete
        Trell.delete_card(@card_id) if @card_id
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
