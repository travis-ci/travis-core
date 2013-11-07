module Travis
  module Api
    module V0
      module Pusher
        class Job
          require 'travis/api/v0/pusher/job/canceled'
          require 'travis/api/v0/pusher/job/created'
          require 'travis/api/v0/pusher/job/log'
          require 'travis/api/v0/pusher/job/started'
          require 'travis/api/v0/pusher/job/finished'

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
