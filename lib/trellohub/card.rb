require 'trellohub/board'
require 'trellohub/cards'

module Trellohub
  class Card
    class << self
      include Trellohub::Cards
    end

    attr_accessor(*self.all_attributes)
    alias_method :repo, :repository

    def repository_name
      repo.split('/').last
    end

    def import(card)
      card.attrs.keys.each do |attr|
        instance_variable_set(:"@#{attr}", card.send(attr))
      end
    end

    def import_from_issue(repository, issue)
      @idBoard = Trellohub::Board.id
      @repository = repository
      @issue = issue.dup

      build_key
      build_name
      build_desc
      build_milestone

      assign_members
      assign_list
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
        @members = [member.username]
      end
    end

    def assign_list
      labels = @issue.labels.map(&:name).uniq
      list = Trellohub.list_by(labels: labels)
      return unless list
      @idList = list.id
      @list_name = list.name
    end

    def save_to_trello
    end

    def save_to_github
    end

    def export
      Hash[self.class.valid_attributes.map { |key|
        [key, instance_variable_get(:"@#{key}")]
      }]
    end

    def to_hash
      Hash[self.class.all_attributes.map { |key|
        [key, instance_variable_get(:"@#{key}")]
      }]
    end
  end
end
