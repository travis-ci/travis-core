module Travis
  module Addons
    module Email
      autoload :EventHandler, 'travis/addons/email/event_handler'
      autoload :Task,         'travis/addons/email/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/email/instruments'
        autoload :Task,         'travis/addons/email/instruments'
      end
    end
  end
end
