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
      accepted? && branches.included?(commit.branch) && !branches.excluded?(commit.branch)
    end

    private

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
