module Travis
  module Addons
    module GithubStatus
      autoload :EventHandler, 'travis/addons/github_status/event_handler'
      autoload :Task,         'travis/addons/github_status/task'

      module Instruments
        autoload :EventHandler, 'travis/addons/github_status/instruments'
        autoload :Task,         'travis/addons/github_status/instruments'
      end
    end
  end
end

