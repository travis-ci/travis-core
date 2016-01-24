module Travis
  class Config
    class Database < Struct.new(:options)
      include Helpers

      VARIABLES = { application_name: ENV['DYNO'] || $0, statement_timeout: 10_000 }
      DEFAULTS  = { adapter: 'postgresql', encoding: 'unicode', variables: VARIABLES }

      def config
        config = parse_url
        config = deep_merge(DEFAULTS, config) unless config.empty?
        config[:pool] = pool.to_i if pool
        config
      end

      private

        def parse_url
          Url.parse(url).to_h.compact
        end

        def pool
          env('DB_POOL', 'DATABASE_POOL_SIZE').compact.first
        end

        def url
          env('DATABASE_URL').compact.first
        end

        def env(*keys)
          ENV.values_at(*keys.map { |key| prefix(key) })
        end

        def prefix(key)
          [options[:prefix], key].compact.join('_').upcase
        end

        def options
          super || {}
        end
    end
  end
end
