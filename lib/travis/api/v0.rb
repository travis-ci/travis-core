module Travis
  module Api
    # V0 is an internal api that we can change at any time
    module V0
      autoload :Event,        'travis/api/v0/event'
      autoload :Notification, 'travis/api/v0/notification'
      autoload :Worker,       'travis/api/v0/worker'
    end
  end
end
