require 'helper'

describe Trellohub do
  describe '.configure' do
    Trellohub::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Trellohub.configure { |config| config.send("#{key}=", key) }
        expect(Trellohub.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

  describe '.default!' do
    it 'sets defaults' do
      Trellohub.default!
      expect(Trellohub.config_file).to be_nil
      expect(Trellohub.repositories).to eq []
      expect(Trellohub.lists).to eq []
      expect(Trellohub.options).to eq(default_assignee: true, default_member: true)
      expect(Trellohub.github_api_endpoint).to eq Octokit.api_endpoint
      expect(Trellohub.github_web_endpoint).to eq Octokit.web_endpoint
      expect(Trellohub.dry_run).to eq false
      expect(Trellohub.debug).to eq true
    end
  end
end
