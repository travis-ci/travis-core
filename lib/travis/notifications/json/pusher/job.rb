module Travis
  module Notifications
    module Json
      module Pusher
        class Job
          autoload :Created,  'travis/notifications/json/pusher/job/created'
          autoload :Log,      'travis/notifications/json/pusher/job/log'
          autoload :Started,  'travis/notifications/json/pusher/job/started'
          autoload :Finished, 'travis/notifications/json/pusher/job/finished'

          attr_reader :job

          def initialize(job)
            @job = job
          end
        end
      end
    end
  end
end
