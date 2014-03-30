module Trellohub
  module Synchronal
    def synchronize
      synchronize_to_cards_from_issues
      synchronize_to_issues_from_cards
      Trellohub::Mocking.print_request_summary if Trellohub.dry_run
      true
    end
    alias_method :sync, :synchronize

    def synchronize_to_cards_from_issues
      Form.with_issues.each do |issue_form|
        card_form = Form.with_cards.find_by_key(issue_form.key)

        case
        when card_form.nil?
          issue_form.save_as_card
        when Form.compare(issue_form, card_form)
          card_form.save_as_issue
        end
      end
    end

    def synchronize_to_issues_from_cards
      Form.with_cards.each do |card_form|
        issue_form = Form.with_issues.find_by_key(card_form.key)

        case
        when issue_form.nil?
          card_form.save_as_issue
        when Form.compare(card_form, issue_form)
          issue_form.save_as_card
        end
      end
    end
  end
end
