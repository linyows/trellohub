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

      def compare(base, comparison)
        return unless base.updated_at < comparison.updated_at
        type = base.imported_from

        printings = [[
          "#{type.to_s.bright.underline} attribute",
          "#{'base'.yellow} (#{base.imported_from}: #{base.own_key}, #{base.updated_at})",
          "#{'comparison'.cyan} (#{comparison.imported_from}: #{comparison.own_key}, #{comparison.updated_at})"
        ]] if Trellohub.debug

        diff = comparison.send(:"to_valid_#{type}").each.with_object({}) do |(key, value), hash|
          base_value = base.send(:"to_valid_#{type}")[key]
          hash[key] = value unless value == base_value

          if Trellohub.debug
            _base = base_value.to_s.color(value == base_value ? :yellow : :red)
            _comparison = value.to_s.color(value == base_value ? :cyan : :green)

            case key
            when :idList
              _base += " (#{base.card_list_name})"
              _comparison += " (#{comparison.card_list_name})"
            when :idMembers
              _base += " (#{base.card_members})"
              _comparison += " (#{base.card_members})"
            end

            printings << [key, _base, _comparison]
          end
        end

        if Trellohub.debug && !diff.empty?
          max = printings.max_lengths
          printings.each.with_index(1) do |line, index|
            puts '[DIFF: Update the base]' if index == 1
            puts 3.times.map.with_index { |i| ''.ljust(max[i], '-') }.join(' | ') if index == 2
            puts line.map.with_index { |word, i| "#{word}".ljust(max[i]) }.join(' | ')
          end
        end

        diff unless diff.empty?
      end
    end

    attr_accessor(*self.common_attributes + self.origin_attributes)

    def created_at
      @created_at ||= send(:"#{@imported_from}_#{__method__}")
    end

    def updated_at
      return @issue_updated_at if @imported_from == :issue
      @updated_at ||= card_updated_at || card_created_at
    end

    def closed_at
      return @issue_closed_at if @imported_from == :issue
      @closed_at ||= card_closed_at || card_created_at
    end

    def open?
      @state == 'open'
    end

    def closed?
      @state == 'closed'
    end

    def key?
      !@key.nil?
    end

    def own_key
      if @imported_from == :issue
        @key
      else
        @card_shortLink
      end
    end

    def to_hash
      Hash[instance_variables.map { |variable|
        next if variable.is_a?(Sawyer::Resource)
        variable_no_at = variable.to_s.gsub('@', '')
        [variable_no_at.to_sym, instance_variable_get(:"#{variable}")]
      }.compact]
    end
  end
end
