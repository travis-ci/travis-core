module Travis
  module Api
    module Pusher
      class Job
        autoload :Created,  'travis/api/pusher/job/created'
        autoload :Log,      'travis/api/pusher/job/log'
        autoload :Started,  'travis/api/pusher/job/started'
        autoload :Finished, 'travis/api/pusher/job/finished'

        include Formats

        attr_reader :job

        def initialize(job)
          @job = job
        end
      end
    end
  end
end
