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
end
