module Travis
  module Services
    module Users
      class FindBroadcasts < Base
        def run
          Broadcast.for(current_user)
        end
      end
    end
  end
end
