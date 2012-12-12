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
        (!excluded_repository? || included_repository?) &&
        !skipped? &&
        (github_pages_explicitly_enabled? || !github_pages?)
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
      elsif excluded_repository?
        'excluded repository'
      elsif skipped?
        'skipped through commit message'
      elsif github_pages?
        'github pages branch'
      elsif request.config.blank?
        'missing config'
      elsif !branch_approved?
        'branch not included or excluded'
      elsif repository.private?
        'private repository'
      end
    end

    private

      def skipped?
        commit.message.to_s =~ /\[ci(?: |:)([\w ]*)\]/i && $1.downcase == 'skip'
      end

      def github_pages_explicitly_enabled?
        request.config &&
          request.config['branches'] &&
          request.config['branches']['only'] &&
          Array(request.config['branches']['only']).grep(/gh[-_]pages/i)
      end

      def github_pages?
        commit.ref =~ /gh[-_]pages/i
      end

      def excluded_repository?
        Travis.config.repository_filter.exclude.any? { |rule| repository.slug =~ rule }
      end

      def included_repository?
        Travis.config.repository_filter.include.any? { |rule| repository.slug =~ rule }
      end

      def branch_approved?
        branches.included?(commit.branch) && !branches.excluded?(commit.branch)
      end

      def branches
        @branches ||= Branches.new(request)
      end
  end
end
