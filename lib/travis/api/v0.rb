module Travis
  module Api
    # V0 is an internal api that we can change at any time
    module V0
      autoload :Notification, 'travis/api/v0/notification'
      autoload :Worker,       'travis/api/v0/worker'
    end
  end
end
