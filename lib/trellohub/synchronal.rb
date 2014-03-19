module Trellohub
  module Synchronal
    def synchronize
    end
    alias_method :sync, :synchronize

    def issues(repo)
      return Octokit.issues(repo) if Trellohub.milestones.empty?

      milestones = Octokit.milestones(repo)
      return [] if milestones.empty?

      milestones.each.with_object([]) do |milestone, milestoned_issues|
        temp_issues = Octokit.issues(repo, milestone: milestone.number)
        milestoned_issues.concat(temp_issues) unless temp_issues.empty?
      end
    end

    def issues_forms
      @issues_forms ||= Trellohub.repos.each.with_object([]) do |repo, forms|
        forms.concat issues_forms_on(repo)
      end
    end

    def issues_forms_on(repo)
      issues(repo).each.with_object([]) do |issue, forms|
        form = Trellohub::Form.new
        form.import_issue repo, issue
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
