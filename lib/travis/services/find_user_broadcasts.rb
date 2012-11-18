module Travis
  module Services
    class FindUserBroadcasts < Base
      def run
        Broadcast.by_user(current_user)
      end
    end
  end
end
