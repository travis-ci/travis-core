module Travis
  class Config
    class Docker
      PATTERN = %r(tcp://(?<host>[^:]+):?(?<port>.*))

      def load
        compact(redis: redis, database: database, amqp: amqp)
      end

      private

        def database
          parse(ENV['POSTGRESQL_PORT']) if ENV['POSTGRESQL_PORT']
        end

        def amqp
          parse(ENV['RABBITMQ_PORT']) if ENV['RABBITMQ_PORT']
        end

        def redis
          { url: ENV['REDIS_PORT'] } if ENV['REDIS_PORT']
        end

        def parse(url)
          matches = PATTERN.match(url.to_s)
          compact(Hash[matches.names.zip(matches.captures)]) if matches
        end

        def compact(hash)
          hash.keys.each { |key| hash.delete(key) if hash[key].blank? }
          hash
        end
    end
  end
end
