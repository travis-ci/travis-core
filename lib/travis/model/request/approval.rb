class Request
  class Approval
    attr_reader :request, :repository, :commit

    def initialize(request)
      @request = request
      @repository = request.repository
      @commit = request.commit
    end

    def settings
      repository.settings
    end

    delegate :build_pushes?, :build_pull_requests?, to: :settings

    def accepted?
      commit.present? &&
        !repository.private? &&
        (!excluded_repository? || included_repository?) &&
        !skipped? &&
        enabled_in_settings?
    end

    def enabled_in_settings?
      request.pull_request? ? build_pull_requests? : build_pushes?
    end

    def disabled_in_settings?
      !enabled_in_settings?
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
      elsif disabled_in_settings?
        request.pull_request? ? 'pull requests disabled' : 'pushes disabled'
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
          request.config['branches'].is_a?(Hash) &&
          request.config['branches']['only'] &&
          Array(request.config['branches']['only']).grep(/gh[-_]pages/i)
      end

      def github_pages?
        request.branch_name =~ /gh[-_]pages/i
      end

      def excluded_repository?
        exclude_rules.any? { |rule| repository.slug =~ rule }
      end

      def included_repository?
        include_rules.any? { |rule| repository.slug =~ rule }
      end

      def include_rules
        Travis.config.repository_filter.include.map { |rule| rule.is_a?(Regexp) ? rule : Regexp.new(rule) }
      end

      def exclude_rules
        Travis.config.repository_filter.exclude.map { |rule| rule.is_a?(Regexp) ? rule : Regexp.new(rule) }
      end

      def branch_approved?
        branches.included?(request.branch_name) && !branches.excluded?(request.branch_name)
      end

      def branches
        @branches ||= Branches.new(request)
      end
  end
end
