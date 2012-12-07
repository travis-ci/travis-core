module Travis
  module Addons
    module Pusher
      autoload :EventHandler, 'travis/addons/pusher/event_handler'
      autoload :Instruments,  'travis/addons/pusher/instruments'
      autoload :Task,         'travis/addons/pusher/task'
    end
  end
end

