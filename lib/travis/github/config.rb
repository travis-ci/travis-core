require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    # encapsulates fetching a .travis.yml from a given commit's config_url
    class Config
      include Logging

      attr_accessor :commit

      def initialize(commit)
        @commit = commit
      end

      def config
        fetch
      end

      private

        def fetch
          if response.success?
            parse(response.body)
          elsif response.status == 404
            { '.result' => 'not_found' }
          else
            { '.result' => 'server_error' }
          end
        end

        def parse(yaml)
          YAML.load(yaml).merge('.result' => 'configured')
        rescue StandardError => e
          log_exception(e)
          { '.result' => 'parsing_failed' }
        end

        def response
          @response ||= http.get(commit.config_url)
        end

        def http
          @http ||= Faraday.new(http_options) do |f|
            f.adapter :net_http
          end
        end

        def http_options
          { :ssl => Travis.config.ssl.compact }
        end
    end
  end
end


