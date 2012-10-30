require 'active_support/core_ext/class/attribute'

module Travis
  module Services
    module Github
      # encapsulates fetching a .travis.yml from a given commit's config_url
      class FetchConfig
        include Logging
        extend Instrumentation

        attr_accessor :request

        def initialize(request)
          @request = request
        end

        def run
          parse(fetch)
        rescue GH::Error => e
          if e.info[:response_status] == 404
            { '.result' => 'not_found' }
          else
            { '.result' => 'server_error' }
          end
        end
        # instrument :run

        private

          def fetch
            GH[request.commit.config_url]
          end

          def parse(yaml)
            YAML.load(yaml).merge('.result' => 'configured')
          rescue StandardError, Psych::SyntaxError => e
            log_exception(e)
            { '.result' => 'parsing_failed' }
          end

          Notification::Instrument::Services::Github::FetchConfig.attach_to(self)
      end
    end
  end
end
