module Trellohub
  module Configurable
    class << self
      def keys
        %i(
          config_file
          board_key
          repositories
          lists
          options
          trello_application_key
          trello_application_token
          github_access_token
          github_api_endpoint
          github_web_endpoint
          dry_run
          debug
        )
      end

      def overrideable_keys
        %i(
          board_key
          trello_application_key
          trello_application_token
          github_access_token
          github_api_endpoint
          github_web_endpoint
          dry_run
          debug
        )
      end
    end

    attr_accessor(*self.keys)

    def configure
      yield self
    end

    def default!
      @config_file              = ENV['CONFIG_FILE']
      @repositories             = []
      @lists                    = []
      @options                  = { default_assignee: true, default_member: true }
      @github_api_endpoint      = Octokit.api_endpoint
      @github_web_endpoint      = Octokit.web_endpoint
      @dry_run                  = false
      @debug                    = true
    end

    def load!(config_file = nil)
      config_file ||= @config_file

      YAML.load_file(config_file).
        symbolize_keys.
        slice(*Trellohub::Configurable.keys).
        each do |key, value|
          case key
          when :repositories
            value = value.map { |v| Trellohub::Repository.new(v) }
          when :lists
            value = value.map { |v| Trellohub::List.new(v) }
          end
          instance_variable_set(:"@#{key}", value)
      end
    end

    def override!
      Trellohub::Configurable.overrideable_keys.each do |key|
        env_name = key.to_s.upcase
        instance_variable_set(:"@#{key}", ENV[env_name]) if ENV[env_name]
      end
    end

    def init!
      Trell.configure do |c|
        c.application_key = @trello_application_key
        c.application_token = @trello_application_token
      end

      Octokit.configure do |c|
        c.access_token = @github_access_token
        c.api_endpoint = @github_api_endpoint
        c.web_endpoint = @github_web_endpoint
        c.auto_paginate = true
      end

      self.dry_run = true if @dry_run
    end

    def setup(config_file = nil)
      default!
      load!(config_file)
      override!
      init!
      self
    end

    def configurations
      Hash[Trellohub::Configurable.keys.map { |key|
        [key, instance_variable_get(:"@#{key}")]
      }]
    end
    alias_method :conf, :configurations

    def list_by(name: nil, default: nil, label: nil)
      case
      when name
        @lists.find { |list| list.name == name }
      when default
        @lists.find { |list| list.default == true }
      when label
        @lists.find { |list| list.issue_label == label }
      end
    end

    def list_custom_conditions
      @list_custom_conditions ||= @lists.select { |list| list.default.nil? && list.issue_label.nil? }.
        each.with_object([]) do |list, arr|
        arr << {
          list_name: list.name,
          attribute: list.to_h.extract(:name).keys.last,
          condition: list.to_h.extract(:name).values.last
        }
      end
    end

    def default_list
      Trellohub.list_by(default: true)
    end

    def list_names
      @lists.map(&:name).compact
    end

    def issue_labels
      @lists.map(&:issue_label).compact
    end

    def repository_by(full_name: nil, name: nil, milestone: nil)
      case
      when full_name
        @repositories.find { |repo| repo.full_name == full_name }
      when name
        @repositories.find { |repo| repo.name == name }
      when milestone
        @repositories.find { |repo| repo.milestone == milestone }
      end
    end

    def repository_full_names
      @repositories.map(&:full_names).compact
    end

    def repository_milestones
      @repositories.map(&:milestone).uniq
    end

    def github_api_endpoint
      File.join(@github_api_endpoint, '')
    end

    def github_web_endpoint
      File.join(@github_web_endpoint, '')
    end

    def dry_run=(bool)
      @dry_run = bool
      Mocking.send(@dry_run ? :start : :stop)
    end

    def board_id
      @board_id ||= if self.shortlink_board_key?
          Trell.board(Trellohub.board_key).id
        else
          Trellohub.board_key
        end
    end

    def shortlink_board_key?
      Trellohub.board_key.length < 24
    end
  end
end
