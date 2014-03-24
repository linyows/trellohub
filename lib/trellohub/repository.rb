require 'ostruct'

module Trellohub
  class Repository < OpenStruct
    def issues
      @issues ||= case
        when milestone.is_a?(String)
          []
        when milestone.nil?
          Octokit.issues(full_name, state: 'all')
        else
          Octokit.issues(full_name, milestone: milestone.number, state: 'all')
        end
    rescue Octokit::NotFound
      []
    # The "state: all" option was not supported by GitHub Enterprise API
    rescue Octokit::UnprocessableEntity
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
