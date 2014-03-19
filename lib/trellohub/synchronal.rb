module Trellohub
  module Synchronal
    def synchronize
    end
    alias_method :sync, :synchronize

    def issues_forms
      @issues_forms ||= Trellohub.repositories.each.with_object([]) do |repo, forms|
        forms.concat issues_forms_on(repo)
      end
    end

    def issues_forms_on(repo)
      repo.issues.each.with_object([]) do |issue, forms|
        form = Trellohub::Form.new
        form.import_issue repo.full_name, issue
        forms << form
      end
    end

    def cards_forms
      @cards_forms ||= Trellohub::Card.all.
        each.with_object([]) do |card, forms|
        form = Trellohub::Form.new
        form.import_card card
        forms << form
      end
    end

    # def import_from_github_issues
      # issued_cards(repo, 'open').each do |card|
        # Trell.create_card card.slice(*valid_card_attributes)
      # end
    # end
    # alias_method :import, :import_from_github_issues
  end
end
