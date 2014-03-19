require 'trellohub/form/card'
require 'trellohub/form/issue'

module Trellohub
  class Form
    include Form::Card
    include Form::Issue

    class << self
      def other_attributes
        %i(
          key
          repository
          list_name
          issue
        )
      end
    end

    attr_accessor(*self.other_attributes)
    alias_method :repo, :repository

    def to_hash
      Hash[instance_variables.map { |variable|
        [
          :"#{variable.to_s.gsub('@', '')}",
          instance_variable_get(:"#{variable}")
        ]
      }]
    end
  end
end
