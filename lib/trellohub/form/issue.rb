module Trellohub
  class Form
    module Issue
      class << self
        def valid_attributes
          %i(
            number
            title
            labels
            state
            assignee
          )
        end

        def attributes
          self.valid_attributes.map do |key|
            :"issue_#{key}"
          end
        end

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Issue.attributes)
          end
        end
      end

      def import_issue(repository, issue)
        @origin_issue = issue.dup
        @issue_repository = repository
        @key = "#{issue_repo_name}##{@origin_issue.number}"

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
              if @origin_issue.labels.empty?
                @origin_issue.labels
              else
                @origin_issue.labels.map(&:name)
              end
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
        return unless @origin_issue.assignee

        member = Trellohub::Member.find_by(username: @origin_issue.assignee.login)
        unless member.nil?
          @card_idMembers = [member.id]
        end
      end

      def assign_card_list_by_issue
        labels = @origin_issue.labels.map(&:name).uniq
        list = Trellohub.list_by(labels: labels)
        return unless list
        @card_idList = list.id
        @card_list_name = list.name
      end

      def save_as_issue
      end

      def to_issue
        Hash[Trellohub::Form::Issue.valid_attributes.map { |key|
          [key, instance_variable_get(:"@issue_#{key}")]
        }]
      end
    end
  end
end
