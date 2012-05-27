module Travis
  module Api
    module V1
      module Pusher
        class Job
          autoload :Created,  'travis/api/v1/pusher/job/created'
          autoload :Log,      'travis/api/v1/pusher/job/log'
          autoload :Started,  'travis/api/v1/pusher/job/started'
          autoload :Finished, 'travis/api/v1/pusher/job/finished'

          include Formats

          attr_reader :job, :options

          def initialize(job, options = {})
            @job = job
            @options = options
          end
        end
      end
    end
  end
end
