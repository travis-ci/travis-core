class Request

  # Logic that figures out whether a branch is in- or excluded (white- or
  # blacklisted) by the configuration (`.travis.yml`)
  class Branches
    attr_reader :request, :commit

    def initialize(request)
      @request = request
      @commit = request.commit
    end

    def included?(branch)
      !included || includes?(included, branch)
    end

    def excluded?(branch)
      excluded && includes?(excluded, branch)
    end

    private

      def included
        config['only']
      end

      def excluded
        config['except']
      end

      def includes?(branches, branch)
        branches.any? { |pattern| matches?(pattern, branch) }
      end

      def matches?(pattern, branch)
        pattern = pattern =~ %r{^/(.*)/$} ? Regexp.new($1) : pattern
        pattern === branch
      end

      def config
        @config ||= case branches = request.config.try(:[], 'branches')
          when Array
            { :only => branches.is_a?(Numeric) ? branches.to_s : branches }
          when String
            { :only => split(branches) }
          when Hash
            branches.each_with_object({}) { |(k, v), result| result[k] = split(v) }
          else
            {}
        end
      end

      def split(branches)
        if branches.is_a?(Numeric)
          Array(branches.to_s)
        elsif branches.is_a?(String)
          branches.split(',').map(&:strip)
        else
          branches
        end
      end
  end
end
