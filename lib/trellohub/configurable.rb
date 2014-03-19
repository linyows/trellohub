require 'yaml'
require 'trellohub/core_ext/hash'

module Trellohub
  module Configurable
    class << self
      def keys
        %i(
          config_file
          board_id
          repositories
          lists
          trello_application_key
          trello_application_token
          github_access_token
          github_api_endpoint
          github_web_endpoint
        )
      end
    end

    attr_accessor(*self.keys)

    def configure
      yield self
    end

    def reset
      @repositories             = []
      @lists                    = []
      @config_file              = ENV['CONFIG_FILE']
      @board_id                 = ENV['BOARD_ID']
      @trello_application_key   = ENV['TRELLO_APPLICATION_KEY']
      @trello_application_token = ENV['TRELLO_APPLICATION_TOKEN']
      @github_access_token      = ENV['GITHUB_ACCESS_TOKEN']
      @github_api_endpoint      = Octokit.api_endpoint
      @github_web_endpoint      = Octokit.web_endpoint
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

    def init_trell
      Trell.configure do |c|
        c.application_key = @trello_application_key
        c.application_token = @trello_application_token
      end
    end

    def init_octokit
      Octokit.configure do |c|
        c.access_token = @github_access_token
        c.api_endpoint = @github_api_endpoint
        c.web_endpoint = @github_web_endpoint
        c.auto_paginate = true
      end
    end

    def setup(config_file = nil)
      reset
      load!(config_file)
      init_trell
      init_octokit
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
  end
end
