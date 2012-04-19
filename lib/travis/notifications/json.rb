module Travis
  module Notifications
    module Json
      autoload :Archive, 'travis/notifications/json/archive'
      # autoload :Email,   'travis/notifications/json/email'
      autoload :Pusher,  'travis/notifications/json/pusher'
      autoload :Webhook, 'travis/notifications/json/webhook'
      autoload :Worker,  'travis/notifications/json/worker'
    end
  end
end
