module Trellohub
  class Form
    module Issue
      class << self
        def valid_attributes
          %i(
            title
            labels
            state
            assignee
            milestone
          )
        end

        def accessible_attributes
          self.prefix(self.valid_attributes + %i(milestone_title))
        end

        def readable_attributes
          self.prefix %i(
            number
            repository
            created_at
            updated_at
            closed_at
          )
        end

        def prefix(array)
          array.map { |key| :"issue_#{key}" }
        end

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Issue.accessible_attributes)
            attr_reader(*Trellohub::Form::Issue.readable_attributes)
          end
        end
      end

      def import_issue(repository, issue)
        @origin_issue = issue.dup
        @issue_repository = repository
        @key = "#{repository}##{@origin_issue.number}"
        @state = @origin_issue.state
        @imported_from = :issue

        build_issue_attributes_by_issue
        build_card_attributes_by_issue
      end

      def issue_repository_name
        @issue_repository.split('/').last
      end
      alias_method :issue_repo_name, :issue_repository_name

      def build_issue_attributes_by_issue
        @origin_issue.attrs.keys.each do |key|
          next if key == :pull_request

          value = case key
            when :user
              @origin_issue.user.login
            when :assignee
              @origin_issue.assignee ? @origin_issue.assignee.login : ''
            when :labels
              @origin_issue.labels.empty? ? [] : @origin_issue.labels.map(&:name)
            else
              @origin_issue.send(key)
            end

          instance_variable_set(:"@issue_#{key}", value)
        end

        @issue_id = @origin_issue.id
        @issue_number = @origin_issue.number

        if @origin_issue.milestone
          @issue_milestone_title = @origin_issue.milestone.title
          @issue_milestone = @origin_issue.milestone.number
        end
      end

      def build_card_attributes_by_issue
        @card_idBoard = Trellohub::Board.id
        @card_name = "#{issue_repo_name}##{@origin_issue.number} #{@origin_issue.title}"
        @card_closed = @origin_issue.state == 'closed'
        assign_card_desc_by_issue
        assign_card_members_by_issue
        assign_card_list_by_issue
      end

      def assign_card_members_by_issue
        @card_idMembers = []
        @card_members = []
        return unless @origin_issue.assignee

        member = Trellohub::Member.find_by(username: @origin_issue.assignee.login)
        unless member.nil?
          @card_idMembers << member.id
          @card_members << member.username
        end
      end

      def assign_card_list_by_issue
        list = nil

        Trellohub.list_custom_conditions.each do |cond|
          code = <<-CODE.gsub("\s", ' ')
            @origin_issue.#{cond[:attribute].to_s.gsub('issue_', '')} &&
            @origin_issue.#{cond[:attribute].to_s.gsub('issue_', '')} #{cond[:condition]}
          CODE

          if eval code
            list = Trellohub.list_by(name: cond[:list_name])
            break if list
          end
        end

        if list.nil?
          labels = @origin_issue.labels.map(&:name).uniq
          labels.each { |label_name| break if list = Trellohub.list_by(label: label_name) }
        end

        list = Trellohub.default_list if list.nil?

        unless list.nil?
          @card_idList = list.id
          @card_list_name = list.name
        end
      end

      def issue_repository?
        !@issue_repository.nil?
      end

      def create_issue?
        !key? && issue_repository? && open?
      end

      def update_issue?
        key? && open?
      end

      def close_issue?
        key? && close?
      end

      def issue_there?
        !!Trellohub::Form.with_issues.find_by_key(@key) if key?
      end

      def issue_body
        if @issue_body.nil? && @imported_from == :card
          form = Trellohub::Form.with_issues.find_by_key(@key)
          @issue_body = form.issue_body if form
        end

        @issue_body
      end

      def default_issue_body
        "created by @#{card_create_user || card_update_user} in trello: #{@card_shortUrl}"
      end

      def print_issue_attributes(title = nil)
        print_attributes('issue', title)
      end

      def create_issue
        return if @issue_repository.nil? || @issue_title.nil?

        print_issue_attributes('Create a Issue')

        Octokit.create_issue(
          @issue_repository,
          @issue_title,
          default_issue_body,
          to_valid_issue
        )
      end

      def update_issue
        return if @issue_repository.nil? || @issue_number.nil? || @issue_title.nil?

        Octokit.update_issue(
          @issue_repository,
          @issue_number,
          @issue_title,
          issue_body,
          to_valid_issue
        )
      end

      def close_issue
        return if @issue_repository.nil? || @issue_number.nil?

        Octokit.close_issue(
          @issue_repository,
          @issue_number,
          to_valid_issue
        )
      end

      def inject_issue_number_to_card_name(number = nil)
        @card_name.gsub!(/#\s/, "##{@issue_number ||= number} ")
      end

      def assign_card_desc_by_issue
        @card_desc = "synced_issue: #{Octokit.web_endpoint}#{@issue_repository}/issues/#{@issue_number}"
      end

      def save_as_issue
        case
        when create_issue?
          if issue = create_issue
            inject_issue_number_to_card_name(issue.number)
            assign_card_desc_by_issue
            update_card
          end
        when update_issue? then update_issue
        when close_issue? then close_issue
        when open? then create_issue
        end
      end

      def to_valid_issue
        Hash[Trellohub::Form::Issue.valid_attributes.map { |key|
          value = instance_variable_get(:"@issue_#{key}")

          case
          when @imported_from == :issue && !value.empty?
            valid_label = value.find { |v| Trellohub.issue_labels.include?(v) }
            value = []
            value << valid_label if valid_label
          end if key == :labels

          [key, value]
        }]
      end

      def to_issue
        Hash[Trellohub::Form::Issue.accessible_attributes.map { |key|
          [
            key.to_s.gsub('issue_', '').to_sym,
            instance_variable_get(:"@#{key}")
          ]
        }]
      end
    end
  end
end
