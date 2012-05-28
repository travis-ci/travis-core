module Travis
  module Api
    module V2
      autoload :Http,          'travis/api/v2/http'
      autoload :Notifications, 'travis/api/v2/notifications'
      autoload :Pusher,        'travis/api/v2/pusher'
    end
  end
end

