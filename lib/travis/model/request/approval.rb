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
      accepted? && request.config.present? && branch_approved?
    end

    def result
      approved? ? :accepted : :rejected
    end

    def message
      if !commit.present?
        'missing commit'
      elsif repository.private?
        'private repository'
      elsif rails_fork?
        'rails fork'
      elsif skipped?
        'skipped through commit message'
      elsif github_pages?
        'github pages branch'
      elsif request.config.blank?
        'missing config'
      elsif !branch_approved?
        'branch not included or excluded'
      end
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

      def branch_approved?
        branches.included?(commit.branch) && !branches.excluded?(commit.branch)
      end

      def branches
        @branches ||= Branches.new(request)
      end
  end
end
