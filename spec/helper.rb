# coding: utf-8

require 'simplecov'
require 'coveralls'
require 'trellohub'
require 'rspec'
require 'ap'
require 'vcr'
require 'webmock/rspec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

WebMock.disable_net_connect!(allow: 'coveralls.io')
RSpec.configure { |c| c.include WebMock::API }

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    serialize_with: :json,
    preserve_exact_body_bytes: true,
    decode_compressed_response: true,
    record: :once
  }
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.read(fixture_path + '/' + file)
end

def decode(file)
  JSON.parse(fixture file)
end

def json_response(file)
  {
    body: fixture(file),
    headers: { content_type: 'application/json; charset=utf-8' }
  }
end

def method_missing(method, *args, &block)
  if method =~ /^a_(get|post|put|delete)$/
    a_request(Regexp.last_match[1].to_sym, *args, &block)
  elsif method =~ /^stub_(get|post|put|delete|head|patch)$/
    stub_request(Regexp.last_match[1].to_sym, *args, &block)
  else
    super
  end
end
