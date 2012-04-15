module Travis
  module Notifications
    module Handler
      autoload :Archive,  'travis/notifications/handler/archive'
      autoload :Email,    'travis/notifications/handler/email'
      autoload :Github,   'travis/notifications/handler/github'
      autoload :Irc,      'travis/notifications/handler/irc'
      autoload :Pusher,   'travis/notifications/handler/pusher'
      autoload :Webhook,  'travis/notifications/handler/webhook'
      autoload :Campfire, 'travis/notifications/handler/campfire'
      autoload :Worker,   'travis/notifications/handler/worker'
    end
  end
end
