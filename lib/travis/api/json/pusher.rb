module Travis
  module Api
    module Json
      module Pusher
        autoload :Build,  'travis/api/json/pusher/build'
        autoload :Job,    'travis/api/json/pusher/job'
        autoload :Worker, 'travis/api/json/pusher/worker'
      end
    end
  end
end
