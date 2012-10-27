module Travis
  module Addons
    module Flowdock
      autoload :EventHandler, 'travis/addons/flowdock/event_handler'
      autoload :Task,         'travis/addons/flowdock/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/flowdock/instruments'
        autoload :Task,         'travis/addons/flowdock/instruments'
      end
    end
  end
end

