require 'helper'

describe Trellohub::Form do
  describe '#common_attributes' do
    it 'returns attributes' do
      expect(Trellohub::Form.common_attributes).to eq %i(
        key
        state
        imported_from
      )
    end
  end

  describe '#origin_attributes' do
    it 'returns attributes' do
      expect(Trellohub::Form.origin_attributes).to eq %i(
        origin_issue
        origin_card
      )
    end
  end

  describe '#array_ext' do
    it 'returns string' do
      expect(Trellohub::Form.array_ext).to eq <<-METHOD
          def find_by_key(key)
            self.find { |form| form.key == key }
          end
      METHOD
    end
  end

  describe '#with_issues' do
    it 'calls #with_issues! at once' do
      expect(Trellohub::Form).to receive(:with_issues!).once.and_return 'hello'
      Trellohub::Form.with_issues
      Trellohub::Form.with_issues
    end
  end

  describe '#with_issues!' do
    it 'calls Trellohub.repositories and Trellohub::Form.array_ext' do
      expect(Trellohub).to receive(:repositories).and_return %w(aaa/bbb ccc/ddd)
      expect(Trellohub::Form).to receive(:with_issues_on).with('aaa/bbb').and_return([])
      expect(Trellohub::Form).to receive(:with_issues_on).with('ccc/ddd').and_return([])
      expect(Trellohub::Form).to receive(:array_ext).and_call_original
      Trellohub::Form.with_issues!
    end
  end

  describe '#with_issues_on' do
    it 'calls issues of repository' do
      repo = double('repository', full_name: 'aaa/bbb')
      issue = double('issue')
      expect(repo).to receive(:issues) { [issue] }
      form = double('form')
      expect(form).to receive(:import_issue).with('aaa/bbb', issue)
      expect(Trellohub::Form).to receive(:new).once.and_return(form)
      expect(Trellohub::Form.with_issues_on repo).to eq [form]
    end
  end

  describe '#with_cards' do
    it 'calls #with_cards! at once' do
      expect(Trellohub::Form).to receive(:with_cards!).once.and_return 'hello'
      Trellohub::Form.with_cards
      Trellohub::Form.with_cards
    end
  end

  describe '#with_cards!' do
    it 'calls Trellohub::Card.all and Trellohub::Form.array_ext' do
      card = double('card')
      expect(Trellohub::Card).to receive(:all).and_return([card])
      form = double('form')
      expect(form).to receive(:import_card).with(card)
      expect(Trellohub::Form).to receive(:new).once.and_return(form)
      expect(Trellohub::Form.with_cards!).to eq [form]
    end
  end

  describe '#compare' do
    context 'when comparison is newer than base' do
      context 'there is a diff' do
        it '' do
        end
      end

      context 'there is no diff' do
        it 'returns nil' do
          base = Trellohub::Form.new
          expect(base).to receive(:updated_at).and_return(Time.now.utc - 60*60*24)
          expect(base).to receive(:imported_from).and_return(:issue)
          comparison = Trellohub::Form.new
          expect(comparison).to receive(:updated_at).and_return(Time.now.utc)
          expect(Trellohub::Form.compare(base, comparison)).to eq nil
        end
      end
    end

    context 'when base is newer than comparison' do
      it 'returns nil' do
        base = double('base')
        expect(base).to receive(:updated_at).and_return(Time.now.utc)
        comparison = double('comparison')
        expect(comparison).to receive(:updated_at).and_return(Time.now.utc - 60*60*24)
        expect(Trellohub::Form.compare base, comparison).to eq nil
      end
    end
  end
end
