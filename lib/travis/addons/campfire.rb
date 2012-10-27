module Travis
  module Addons
    module Campfire
      autoload :EventHandler, 'travis/addons/campfire/event_handler'
      autoload :Task,         'travis/addons/campfire/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/campfire/instruments'
        autoload :Task,         'travis/addons/campfire/instruments'
      end
    end
  end
end
