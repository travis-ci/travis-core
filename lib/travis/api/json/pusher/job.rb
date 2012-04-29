module Travis
  module Api
    module Json
      module Pusher
        class Job
          autoload :Created,  'travis/api/json/pusher/job/created'
          autoload :Log,      'travis/api/json/pusher/job/log'
          autoload :Started,  'travis/api/json/pusher/job/started'
          autoload :Finished, 'travis/api/json/pusher/job/finished'

          include Formats

          attr_reader :job

          def initialize(job)
            @job = job
          end
        end
      end
    end
  end
end
