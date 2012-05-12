module Travis
  module Api
    module Pusher
      autoload :Build,  'travis/api/pusher/build'
      autoload :Job,    'travis/api/pusher/job'
      autoload :Worker, 'travis/api/pusher/worker'
    end
  end
end
