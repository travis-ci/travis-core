module Travis
  module Notifications
    module Json
      module Pusher
        autoload :Build,  'travis/notifications/json/pusher/build'
        autoload :Job,    'travis/notifications/json/pusher/job'
        autoload :Worker, 'travis/notifications/json/pusher/worker'
      end
    end
  end
end
