module Travis
  module Services
    module Users
      class FindBroadcasts < Base
        def run
          Broadcast.by_user(current_user)
        end
      end
    end
  end
end
