require 'octokit'
require 'trell'
require 'yaml'

require 'trellohub/version'
require 'trellohub/repository'
require 'trellohub/board'
require 'trellohub/list'
require 'trellohub/card'
require 'trellohub/member'
require 'trellohub/form'
require 'trellohub/configurable'
require 'trellohub/mocking'
require 'trellohub/synchronal'

require 'trellohub/core_ext/string'
require 'trellohub/core_ext/array'
require 'trellohub/core_ext/hash'

module Trellohub
  class << self
    include Trellohub::Configurable
    include Trellohub::Synchronal
  end
end
