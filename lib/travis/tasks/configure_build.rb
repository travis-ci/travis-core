module Travis
  module Tasks
    class ConfigureBuild
      include Logging

      attr_reader :http_client, :commit

      # Task that retrieves the .travis.yml based using the config_url
      # passed to it.
      #
      # I.e. this simply does an HTTP GET request to the Github API and
      # passes the result back.
      def initialize(commit, http = nil)
        @http_client = http
        @commit = commit
      end

      def run
        { 'config' => fetch_and_parse }
      end

      private

        def http_client
          @http_client ||= Faraday.new(http_options) do |f|
            f.adapter :net_http
          end
        end

        def fetch_and_parse
          if response.success?
            parse(response.body)
          elsif response.code == 404
            { ".result" => 'not_found' }
          else
            { ".result" => 'server_error' }
          end
        end

        def response
          @response ||= http_client.get(commit.config_url)
        end

        def parse(yaml)
          result = YAML.load(yaml)
          result.merge('.result' => 'configured')
        rescue StandardError => e
          log_exception(e)
          { ".result" => 'parsing_failed' }
        end

        def http_options
          options, ssl = {}, Travis.config.ssl
          options[:ssl] = { :ca_path => ssl.ca_path } if ssl.ca_path
          options[:ssl] = { :ca_file => ssl.ca_file } if ssl.ca_file
          options
        end

    end
  end
end