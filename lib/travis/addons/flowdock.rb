module Travis
  module Addons
    module Flowdock
      autoload :EventHandler, 'travis/addons/flowdock/event_handler'
      autoload :Instruments,  'travis/addons/flowdock/instruments'
      autoload :Task,         'travis/addons/flowdock/task'
    end
  end
end

