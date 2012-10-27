module Travis
  module Addons
    module Webhook
      autoload :EventHandler, 'travis/addons/webhook/event_handler'
      autoload :Task,         'travis/addons/webhook/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/webhook/instruments'
        autoload :Task,         'travis/addons/webhook/instruments'
      end
    end
  end
end

