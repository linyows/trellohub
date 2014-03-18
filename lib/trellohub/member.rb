module Trellohub
  module Member
    class << self
      def find_by_github_user(username)
        @members = {} if @members.nil?
        @members[:"#{username}"] ||= Trell.member(username)
      rescue Trell::NotFound
        nil
      end
    end
  end
end
