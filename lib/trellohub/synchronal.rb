module Trellohub
  module Synchronal
    SYNCHRONAL_KEYS = %i(
      temporary_cards_by_issues
      temporary_cards
    )

    attr_reader(*SYNCHRONAL_KEYS)

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

    def issues_cards
      @issue_cards ||= Trellohub.repos.each.with_object([]) do |repo, cards|
        cards.concat issues_cards_on(repo)
      end
    end

    def issues_cards_on(repo)
      issues(repo).each.with_object([]) do |issue, cards|
        temp_card = Trellohub::Card.new
        temp_card.import_from_issue repo, issue
        cards << temp_card
      end
    end

    def trello_cards
      @trello_cards ||= Trellohub::Card.all.
        each.with_object([]) do |card, cards|
        temp_card = Trellohub::Card.new
        temp_card.import card
        cards << temp_card
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
