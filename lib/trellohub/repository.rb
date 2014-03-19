require 'ostruct'

module Trellohub
  class Repository < OpenStruct
    def issues
      @issues ||= case
        when milestone.is_a?(String)
          []
        when milestone.nil?
          Octokit.issues(full_name)
        else
          Octokit.issues(full_name, milestone: milestone.number)
        end
    rescue Octokit::NotFound
      []
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
