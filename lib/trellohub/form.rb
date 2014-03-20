require 'trellohub/form/card'
require 'trellohub/form/issue'

module Trellohub
  class Form
    include Form::Card
    include Form::Issue

    class << self
      def common_attributes
        %i(
          key
        )
      end

      def origin_attributes
        %i(
          origin_issue
          origin_card
        )
      end
    end

    attr_accessor(*self.common_attributes + self.origin_attributes)

    def to_hash
      Hash[instance_variables.map { |variable|
        variable_no_at = variable.to_s.gsub('@', '')

        next if self.class.origin_attributes.include?(:"#{variable_no_at}")

        [variable_no_at.to_sym, instance_variable_get(:"#{variable}")]
      }.compact]
    end
  end
end
