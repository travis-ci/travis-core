module Travis
  module Api
    module V2
      module Pusher
        class Job
          autoload :Created,  'travis/api/v2/pusher/job/created'
          autoload :Log,      'travis/api/v2/pusher/job/log'
          autoload :Started,  'travis/api/v2/pusher/job/started'
          autoload :Finished, 'travis/api/v2/pusher/job/finished'

          include Formats

          attr_reader :job

          def initialize(job)
            @job = job
          end

          def data(extra = {})
            Http::Job.new(job).data
          end
        end
      end
    end
  end
end
