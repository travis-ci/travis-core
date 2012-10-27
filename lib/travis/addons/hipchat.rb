module Travis
  module Addons
    module Hipchat
      autoload :EventHandler, 'travis/addons/hipchat/event_handler'
      autoload :Task,         'travis/addons/hipchat/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/hipchat/instruments'
        autoload :Task,         'travis/addons/hipchat/instruments'
      end
    end
  end
end

