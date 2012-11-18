module Travis
  module Enqueue
    module Services
      autoload :EnqueueJobs, 'travis/enqueue/services/enqueue_jobs'

      class << self
        def register
          constants(false).each do |name|
            Travis.services.add(name.to_s.underscore, const_get(name))
          end
        end
      end
    end
  end
end

