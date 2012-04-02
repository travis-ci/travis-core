class Request

  # Logic that figures out whether a branch is in- or excluded (white- or
  # blacklisted) by the configuration (`.travis.yml`)
  #
  # TODO somehow feels wrong. maybe this should rather be on a Request::Approval
  # or Request::Vetting as we might vet based on other things than just the
  # branch?
  module Branches
    def branch_included?(branch)
      !included_branches || includes_match?(included_branches, branch)
    end

    def branch_excluded?(branch)
      excluded_branches && includes_match?(excluded_branches, branch)
    end

    def included_branches
      branches_config[:only]
    end

    def excluded_branches
      branches_config[:except]
    end

    def branches_config
      branches = config.try(:[], :branches)
      case branches
      when Array
        { :only => branches }
      when String
        { :only => split_branches(branches) }
      when Hash
        branches.each_with_object({}) { |(k, v), memo| memo[k] = split_branches(v) }
      else
        {}
      end
    end

    private

      def split_branches(branches)
        branches.is_a?(String) ? branches.split(',').map(&:strip) : branches
      end

      def includes_match?(list, str)
        list.any? { |item| regexp_or_string(item) === str }
      end

      def regexp_or_string(str)
        str =~ %r{^/(.*)/$} ? Regexp.new($1) : str
      end
  end
end
