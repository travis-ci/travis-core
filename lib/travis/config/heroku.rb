module Travis
  class Config
    class Heroku
      def load
        { database: parse_database_url(database_url) || {} }
      end

      private

        def database_url
          ENV.values_at('DATABASE_URL', 'SHARED_DATABASE_URL').first
        end

        def parse_database_url(url)
          pattern = %r((?:.+?)://(?<username>.+):(?<password>.+)@(?<host>[^:]+):?(?<port>.*)/(?<database>.+))
          matches = pattern.match(url.to_s)
          compact(Hash[matches.names.zip(matches.captures)]) if matches
        end

        def compact(hash)
          hash.keys.each { |key| hash.delete(key) if hash[key].blank? }
          hash
        end
    end
  end
end
