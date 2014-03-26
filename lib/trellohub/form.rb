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
          state
          imported_from
        )
      end

      def origin_attributes
        %i(
          origin_issue
          origin_card
        )
      end

      def array_ext
        <<-METHODS
          def find_by_key(key)
            self.find { |form| form.key == key }
          end
        METHODS
      end

      def with_issues
        @issues ||= self.with_issues!
      end

      def with_issues!
        array = Trellohub.repositories.each.with_object([]) do |repo, forms|
          forms.concat with_issues_on(repo)
        end
        array.instance_eval array_ext
        array
      end

      def with_issues_on(repo)
        repo.issues.each.with_object([]) do |issue, forms|
          form = Trellohub::Form.new
          form.import_issue repo.full_name, issue
          forms << form
        end
      end

      def with_cards
        @cards ||= self.with_cards!
      end

      def with_cards!
        array = Trellohub::Card.all.
          each.with_object([]) do |card, forms|
          form = Trellohub::Form.new
          form.import_card card
          forms << form
        end
        array.instance_eval array_ext
        array
      end

      def compare(base, target)
        if base.updated_at < target.updated_at
          diff = target.to_hash.each.with_object({}) do |(k, v), hash|
            t = target.imported_from
            hash[k] = v unless target.send(:"to_#{t}")[k] == base.send(:"to_#{t}")[k]
          end
          diff unless diff.empty?
        end
      end
    end

    attr_accessor(*self.common_attributes + self.origin_attributes)

    def open?
      @state == 'open'
    end

    def closed?
      @state == 'closed'
    end

    def to_hash
      Hash[instance_variables.map { |variable|
        variable_no_at = variable.to_s.gsub('@', '')

        next if self.class.origin_attributes.include?(:"#{variable_no_at}")

        [variable_no_at.to_sym, instance_variable_get(:"#{variable}")]
      }.compact]
    end
  end
end
