module Trellohub
  class Form
    module Issue
      class << self
        def valid_attributes
          %i(
            id
            number
            title
            user
            labels
            state
            assignee
            milestone
            comments
            created_at
            updated_at
            closed_at
            pull_request
            body
          )
        end

        def included(base)
          base.class_eval do
            attr_accessor(*Trellohub::Form::Issue.valid_attributes)
          end
        end
      end

      def import_issue(repository, issue)
        @idBoard = Trellohub::Board.id
        @repository = repository
        @issue = issue.dup
        @issue_id = issue.id

        build_key
        build_name
        build_desc
        build_milestone

        assign_members
        assign_list
      end

      def repository_name
        repo.split('/').last
      end

      def build_key
        @key = "#{repository_name}##{@issue.number}"
      end

      def build_name
        @name = "#{repository_name}##{@issue.number} #{@issue.title}"
      end

      def build_desc
        @desc = "#{Octokit.web_endpoint}#{repo}/issues/#{@issue.number}"
      end

      def build_milestone
        return unless @issue.milestone
        @milestone = @issue.milestone.title
      end

      def assign_members
        return unless @issue.assignee

        member = Trellohub::Member.find_by_github_user(@issue.assignee.login)
        unless member.nil?
          @idMembers = [member.id]
        end
      end

      def assign_list
        labels = @issue.labels.map(&:name).uniq
        list = Trellohub.list_by(labels: labels)
        return unless list
        @idList = list.id
      end

      def save_as_issue
      end

      def to_issue
        Hash[Trellohub::Form::Issue.valid_attributes.map { |key|
          [key, instance_variable_get(:"@#{key == :id ? :issue_id : key}")]
        }]
      end
    end
  end
end
