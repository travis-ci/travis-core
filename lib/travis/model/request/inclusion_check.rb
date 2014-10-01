class Request

  # Logic that figures out whether a tag or a branch is in- or excluded (white- or
  # blacklisted) by the configuration (`.travis.yml`)
  class InclusionCheck
    attr_reader :request, :commit

    def initialize(request)
      @request = request
      @commit = request.commit
    end

    def included?(item)
      !included || includes?(included, item)
    end

    def excluded?(item)
      excluded && includes?(excluded, item)
    end

    private

      def included
        config['only']
      end

      def excluded
        config['except']
      end

      def includes?(items, item)
        items.any? { |pattern| matches?(pattern, item) }
      end

      def matches?(pattern, item)
        pattern = pattern =~ %r{^/(.*)/$} ? Regexp.new($1) : pattern
        pattern === item
      end

      def config
        @config ||= case items = request.config.try(:[], item_name)
          when Array
            { :only => items }
          when String
            { :only => split(items) }
          when Hash
            items.each_with_object({}) { |(k, v), result| result[k] = split(v) }
          else
            {}
        end
      end

      def split(items)
        items.is_a?(String) ? items.split(',').map(&:strip) : items
      end
  end
end
