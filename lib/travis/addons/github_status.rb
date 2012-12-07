module Travis
  module Addons
    module GithubStatus
      autoload :EventHandler, 'travis/addons/github_status/event_handler'
      autoload :Instruments,  'travis/addons/github_status/instruments'
      autoload :Task,         'travis/addons/github_status/task'
    end
  end
end

