module Travis
  module Addons
    module Irc
      autoload :Client,       'travis/addons/irc/client'
      autoload :EventHandler, 'travis/addons/irc/event_handler'
      autoload :Instruments,  'travis/addons/irc/instruments'
      autoload :Task,         'travis/addons/irc/task'
    end
  end
end

