module Travis
  module Notification
    module Publisher
      autoload :Log,    'travis/notification/publisher/log'
      autoload :Redis,  'travis/notification/publisher/redis'
      autoload :Memory, 'travis/notification/publisher/memory'
    end
  end
end
