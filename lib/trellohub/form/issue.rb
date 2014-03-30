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
          )
        end

        def accessible_attributes
          (self.valid_attributes + %i(
            body
           )).map { |key| :"issue_#{key}" }
        end

        def readable_attributes
          %i(
            number
            created_at
            updated_at
            closed_at
          ).map { |key| :"issue_#{key}" }
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

        build_card_attributes_by_issue
        build_issue_attributes_by_issue
      end

      def build_card_attributes_by_issue
        @card_idBoard = Trellohub::Board.id
        @card_name = "#{issue_repo_name}##{@origin_issue.number} #{@origin_issue.title}"
        @card_desc = "synced_issue: #{Octokit.web_endpoint}#{@issue_repository}/issues/#{@origin_issue.number}"
        @card_closed = @origin_issue.state == 'closed'
        assign_card_members_by_issue
        assign_card_list_by_issue
      end

      def build_issue_attributes_by_issue
        @origin_issue.attrs.keys.each do |key|
          next if key == :pull_request

          value = case key
            when :user
              @origin_issue.user.login
            when :assignee
              @origin_issue.assignee ? @origin_issue.assignee.login : nil
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

      def issue_repository_name
        @issue_repository.split('/').last
      end
      alias_method :issue_repo_name, :issue_repository_name

      def assign_card_members_by_issue
        @card_idMembers = []
        return unless @origin_issue.assignee

        member = Trellohub::Member.find_by(username: @origin_issue.assignee.login)
        unless member.nil?
          @card_idMembers << member.id
        end
      end

      def assign_card_list_by_issue
        labels = @origin_issue.labels.map(&:name).uniq
        list = Trellohub.list_by(labels: labels)
        return unless list
        @card_idList = list.id
        @card_list_name = list.name
      end

      def issue_update?
        !@issue_id.nil?
      end

      def issue_body
        if @issue_body.nil? && @imported_from == :card
          form = Trellohub::Form.with_issues.find_by_key(@key)
          @issue_body = form.issue_body if form
        end

        @issue_body
      end

      def create_issue
        return if @issue_repository.nil? || @issue_title.nil?

        Octokit.create_issue(
          @issue_repository,
          @issue_title,
          nil,
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

      def save_as_issue
        case
        when issue_update? && open? then update_issue
        when issue_update? && closed? then close_issue
        when open? then create_issue
        end
      end

      def to_valid_issue
        Hash[Trellohub::Form::Issue.valid_attributes.map { |key|
          [key, instance_variable_get(:"@issue_#{key}")]
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
