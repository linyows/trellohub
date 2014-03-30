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
end
