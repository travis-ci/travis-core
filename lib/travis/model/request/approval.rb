class Request
  class Approval
    attr_reader :request, :repository, :commit

    def initialize(request)
      @request = request
      @repository = request.repository
      @commit = request.commit
    end

    def accepted?
      commit.present? &&
        !repository.private? &&
        !rails_fork? &&
        !skipped? &&
        !github_pages?
    end

    def approved?
      accepted? && branch_approved? if pull_request_allowed?
    end

    private

      def pull_request_allowed?
        true
        # return true unless request.pull_request?
        # Array(request.config['addons']).include? 'pull_requests'
      end

      def branch_approved?
        branches.included?(commit.branch) && !branches.excluded?(commit.branch)
      end

      def skipped?
        commit.message.to_s =~ /\[ci(?: |:)([\w ]*)\]/i && $1.downcase == 'skip'
      end

      def github_pages?
        commit.ref =~ /gh[-_]pages/i
      end

      def rails_fork?
        repository.slug != 'rails/rails' && repository.slug =~ %r(/rails$)
      end

      def branches
        @branches ||= Branches.new(request)
      end
  end
end
