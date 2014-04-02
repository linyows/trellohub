require 'ostruct'

module Trellohub
  class Repository < OpenStruct
    def name
      full_name.split('/').last
    end

    def issues
      issues_with_state_all
    rescue Octokit::UnprocessableEntity
      issues_without_state_all
    rescue Octokit::NotFound
      []
    end

    def issues_with_state_all
      @issues ||= case
        when milestone.is_a?(String)
          []
        when milestone.nil?
          Octokit.issues(full_name, state: 'all')
        else
          Octokit.issues(full_name, milestone: milestone.number, state: 'all')
        end
    end

    # The "state: all" option was not supported by GitHub Enterprise API
    def issues_without_state_all
      @issues ||= case
        when milestone.nil?
          Octokit.issues(full_name, state: 'open') +
          Octokit.issues(full_name, state: 'closed')
        else
          Octokit.issues(full_name, milestone: milestone.number, state: 'open') +
          Octokit.issues(full_name, milestone: milestone.number, state: 'closed')
        end
    end

    def milestone
      @milestone ||= super
      if @milestone.is_a?(String)
        m = find_milestone
        @milestone = m if m
      end
      @milestone
    end

    def milestone?
      @milestone.is_a?(Sawyer::Resource)
    end

    def find_milestone
      return nil if all_milestones.empty?
      milestone = @all_milestones.find { |m| m.title == @milestone }
      milestone if milestone
    end

    def all_milestones
      @all_milestones ||= Octokit.milestones(full_name)
    end
  end
end
