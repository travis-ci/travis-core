module Travis
  module Addons
    module Hipchat
      autoload :EventHandler, 'travis/addons/hipchat/event_handler'
      autoload :Instruments,  'travis/addons/hipchat/instruments'
      autoload :Task,         'travis/addons/hipchat/task'
    end
  end
end

