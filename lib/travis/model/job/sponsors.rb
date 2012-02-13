class Job
  module Sponsors
    def sponsor
      @sponsors ||= Travis.config.sponsors.workers[worker.split(':').first || ''] || Hashr.new
    end

    # TODO this overwrites the activerecord attribute which currently is not populated from the actual worker
    # we should be able to remove this once https://github.com/travis-ci/travis-worker/commit/dcee841d1be7808131395c0976a075c58392a624
    # is in production
    def worker
      read_attribute(:worker) || extract_worker || ''
    end

    protected

      def extract_worker
        (log.content || '').split("\n").first =~ /Using worker: (.+)/ and $1
      end
  end
end
