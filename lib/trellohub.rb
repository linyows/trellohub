require 'octokit'
require 'trell'
require 'trellohub/version'
require 'trellohub/configurable'
require 'trellohub/board'
require 'trellohub/list'
require 'trellohub/lists'
require 'trellohub/card'
require 'trellohub/cards'
require 'trellohub/member'
require 'trellohub/synchronal'

module Trellohub
  class << self
    include Trellohub::Configurable
    include Trellohub::Synchronal
  end
end
