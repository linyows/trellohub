require 'octokit'
require 'trell'
require 'trellohub/version'
require 'trellohub/repository'
require 'trellohub/board'
require 'trellohub/list'
require 'trellohub/card'
require 'trellohub/member'
require 'trellohub/form'
require 'trellohub/configurable'
require 'trellohub/synchronal'

module Trellohub
  class << self
    include Trellohub::Configurable
    include Trellohub::Synchronal
  end
end
