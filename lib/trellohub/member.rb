module Trellohub
  module Member
    class << self
      def find_by(id: nil, username: nil)
        @members = {} if @members.nil?

        case
        when !id.nil?
          if member = @members.find { |key, value| value.id == id }
            member.last
          else
            member = Trell.member(id)
            @members[:"#{member.username}"] = member
          end
        when !username.nil?
          @members[:"#{username}"] ||= Trell.member(username)
        end

      rescue Trell::NotFound
        nil
      end
    end
  end
end
