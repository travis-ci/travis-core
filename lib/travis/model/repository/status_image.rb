class Repository
  class StatusImage
    RESULTS = {
      passed:  :passing,
      failed:  :failing,
      errored: :error
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
        @last_state ||= (state_from_cache || state_from_database)
      end

      def state_from_cache
        return unless repo

        cache.fetch_state(repo.id, branch)
      end

      def state_from_database
        return unless repo

        build = repo.last_completed_build(branch)
        if build
          cache.write(repo.id, build.branch, build)
          build.state.to_sym
        end
      end

      def cache
        Travis.states_cache
      end
  end
end
