require 'helper'

describe Trellohub::Form::Card do
  describe '#valid_attributes' do
    it 'returns valid_attributes' do
      expect(Trellohub::Form::Card.valid_attributes).to eq %i(
        closed
        desc
        idBoard
        idList
        name
        idMembers
      )
    end
  end

  describe '#accessible_attributes' do
    it 'returns accessible_attributes' do
      expect(Trellohub::Form::Card).to receive(:prefix).and_call_original
      expect(Trellohub::Form::Card.accessible_attributes).to eq %i(
        card_closed
        card_desc
        card_idBoard
        card_idList
        card_name
        card_idMembers
        card_list_name
        card_members
      )
    end
  end

  describe '#readable_attributes' do
    it 'returns readable_attributes' do
      expect(Trellohub::Form::Card).to receive(:prefix).and_call_original
      expect(Trellohub::Form::Card.readable_attributes).to eq %i(
        card_labels
      )
    end
  end
end
