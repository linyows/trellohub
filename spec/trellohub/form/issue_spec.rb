require 'helper'

describe Trellohub::Form::Issue do
  describe '#valid_attributes' do
    it 'returns valid_attributes' do
      expect(Trellohub::Form::Issue.valid_attributes).to eq %i(
        title
        labels
        state
        assignee
        milestone
      )
    end
  end

  describe '#accessible_attributes' do
    it 'returns accessible_attributes' do
      expect(Trellohub::Form::Issue).to receive(:prefix).and_call_original
      expect(Trellohub::Form::Issue.accessible_attributes).to eq %i(
        issue_title
        issue_labels
        issue_state
        issue_assignee
        issue_milestone
        issue_milestone_title
      )
    end
  end

  describe '#readable_attributes' do
    it 'returns readable_attributes' do
      expect(Trellohub::Form::Issue).to receive(:prefix).and_call_original
      expect(Trellohub::Form::Issue.readable_attributes).to eq %i(
        issue_number
        issue_repository
        issue_created_at
        issue_updated_at
        issue_closed_at
      )
    end
  end

  describe '#prefix' do
    it 'returns prefixed symbol array' do
      expect(Trellohub::Form::Issue.prefix %w(aaa bbb)).to eq %i(issue_aaa issue_bbb)
    end
  end

  describe '.import_issue' do
    it 'imports a issue' do
      duped_issue = double
      expect(duped_issue).to receive(:number)
      expect(duped_issue).to receive(:state)
      issue = double(dup: duped_issue)

      form = Trellohub::Form.new
      expect(form).to receive(:build_issue_attributes_by_issue)
      expect(form).to receive(:build_card_attributes_by_issue)

      form.import_issue('aaa/bbb', issue)
    end
  end

  describe '.issue_repository_name' do
    it 'returns repository name' do
      form = Trellohub::Form.new
      form.instance_variable_set(:@issue_repository, 'aaa/bbb')
      expect(form.issue_repository_name).to eq 'bbb'
    end
  end
end
