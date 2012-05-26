module Travis
  module Api
    module V2
      module Pusher
        autoload :Build,  'travis/api/v2/pusher/build'
        autoload :Job,    'travis/api/v2/pusher/job'
        autoload :Worker, 'travis/api/v2/pusher/worker'
      end
    end
  end
end
