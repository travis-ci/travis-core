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
        !skipped?
    end

    def branch_accepted?
      github_pages_explicitly_enabled? || !github_pages?
    end

    def config_accepted?
      (travis_yml_present? || allow_builds_without_travis_yml?)
    end

    def travis_yml_present?
      request.config && request.config['.result'] == 'configured'
    end

    def allow_builds_without_travis_yml?
      !repository.builds_only_with_travis_yml?
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
      elsif !branch_approved? || !branch_accepted?
        'branch not included or excluded'
      elsif !config_accepted?
        '.travis.yml is missing and builds without .travis.yml are disabled'
      elsif repository.private?
        'private repository'
      end
    end

    private

      def skipped?
        Travis::CommitCommand.new(commit.message).skip?
      end

      def github_pages_explicitly_enabled?
        request.config &&
          request.config['branches'] &&
          request.config['branches']['only'] &&
          Array(request.config['branches']['only']).grep(/gh[-_]pages/i)
      end

      def github_pages?
        commit.branch =~ /gh[-_]pages/i
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
