module Trellohub
  module Configurable
    class << self
      def keys
        %i(
          config_file
          board_id
          repositories
          lists
          options
          trello_application_key
          trello_application_token
          github_access_token
          github_api_endpoint
          github_web_endpoint
          dry_run
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
      @board_id                 = ENV['BOARD_ID'] if ENV['BOARD_ID']
      @trello_application_key   = ENV['TRELLO_APPLICATION_KEY'] if ENV['TRELLO_APPLICATION_KEY']
      @trello_application_token = ENV['TRELLO_APPLICATION_TOKEN'] if ENV['TRELLO_APPLICATION_TOKEN']
      @github_access_token      = ENV['GITHUB_ACCESS_TOKEN'] if ENV['GITHUB_ACCESS_TOKEN']
      @github_api_endpoint      = ENV['GITHUB_API_ENDPOINT'] if ENV['GITHUB_API_ENDPOINT']
      @github_web_endpoint      = ENV['GITHUB_WEB_ENDPOINT'] if ENV['GITHUB_WEB_ENDPOINT']
      @dry_run                  = !!ENV['DRY_RUN'] if ENV['DRY_RUN']
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

    def list_by(name: nil, default: nil, label: nil, labels: [])
      case
      when name
        @lists.find { |list| list.name == name }
      when default
        @lists.find { |list| list.default == true }
      when label
        @lists.find { |list| list.issue_label == label }
      else
        labels.each { |label_name|
          list = Trellohub.list_by(label: label_name)
          return list if list
        } unless labels.empty?

        Trellohub.default_list
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

    def repository_by(full_name: nil, milestone: nil)
      case
      when full_name
        @repositories.find { |repo| repo.full_name == full_name }
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
  end
end
