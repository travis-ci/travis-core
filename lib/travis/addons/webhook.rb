module Travis
  module Addons
    module Webhook
      autoload :EventHandler, 'travis/addons/webhook/event_handler'
      autoload :Instruments,  'travis/addons/webhook/instruments'
      autoload :Task,         'travis/addons/webhook/task'
    end
  end
end

