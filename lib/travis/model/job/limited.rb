class Job
  module Limited
    autoload :ByOwner, 'travis/model/job/limited/by_owner'

    class << self
      def first(queue = nil)
        # could look up the strategy from config here
        Job::Limited::ByOwner.new(queue).first
      end
    end
  end
end
