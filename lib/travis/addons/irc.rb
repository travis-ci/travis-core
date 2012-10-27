module Travis
  module Addons
    module Irc
      autoload :Client,       'travis/addons/irc/client'
      autoload :EventHandler, 'travis/addons/irc/event_handler'
      autoload :Task,         'travis/addons/irc/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/irc/instruments'
        autoload :Task,         'travis/addons/irc/instruments'
      end
    end
  end
end

