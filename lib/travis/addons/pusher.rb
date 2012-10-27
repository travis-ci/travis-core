module Travis
  module Addons
    module Pusher
      autoload :EventHandler, 'travis/addons/pusher/event_handler'
      autoload :Task,         'travis/addons/pusher/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/pusher/instruments'
        autoload :Task,         'travis/addons/pusher/instruments'
      end
    end
  end
end

