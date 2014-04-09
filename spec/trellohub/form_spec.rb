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
end
