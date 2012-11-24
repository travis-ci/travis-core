class Repository
  class StatusImage
    RESULTS = {
      passed: :passing,
      failed: :failing,
    }

    attr_reader :repo, :branch

    def initialize(repo, branch = nil)
      @repo = repo
      @branch = branch
    end

    def result
      last_state ? RESULTS[last_state] : :unknown
    end

    private

      def last_state
        @last_state ||= repo && repo.build_status(branch)
      end
  end
end
