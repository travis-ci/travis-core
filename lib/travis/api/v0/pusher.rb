module Travis
  module Api
    module V0
      module Pusher
        autoload :Build,  'travis/api/v0/pusher/build'
        autoload :Job,    'travis/api/v0/pusher/job'
        autoload :Worker, 'travis/api/v0/pusher/worker'
      end
    end
  end
end
