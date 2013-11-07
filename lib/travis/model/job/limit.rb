class Job
  module Limit
    require 'travis/model/job/limit/by_owner'

    class << self
      def all(owner)
        Job::Limit::ByOwner.new(owner).all
      end

      def enqueueable?(job)
        !Job::Limit::ByOwner.new(job.owner).limited?
      end
    end
  end
end
