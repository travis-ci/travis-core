require 'core_ext/hash/compact'

# TODO should take the config_url directly instead of dealing with models.
# It then can also be renamed to something way more general like "HttpGet" or so.
module Travis
  class Task
    module Request
      class Configure < Task
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
          process
        end
        instrument :run

        private

          def process
            { 'config' => fetch }
          end

          def fetch
            if response.success?
              parse(response.body)
            elsif response.status == 404
              { ".result" => 'not_found' }
            else
              { ".result" => 'server_error' }
            end
          end

          def parse(yaml)
            result = YAML.load(yaml)
            result.merge('.result' => 'configured')
          rescue StandardError => e
            log_exception(e)
            { ".result" => 'parsing_failed' }
          end

          def response
            @response ||= http_client.get(commit.config_url)
          end

          def http_client
            @http_client ||= Faraday.new(http_options) do |f|
              f.adapter :net_http
            end
          end

          def http_options
            { :ssl => Travis.config.ssl.compact }
          end
      end
    end
  end
end

