require 'timeout'
require 'json'

module Travis
  module Github
    class Education < Struct.new(:github_oauth_token)
      include Travis::Logging

      def student?
        data['student']
      end

      def data
        @data ||= fetch
      end

      def fetch
        Timeout::timeout(timeout) do
          remote = GH::Remote.new
          remote.setup('https://education.github.com/api', token: github_oauth_token)
          response = remote.fetch_resource('/user')
          JSON.parse(response.body)
        end
      rescue GH::Error, JSON::ParserError, Timeout::Error => e
        log_exception(e)

        {}
      end

      def timeout
        Travis.config.education_endpoint_timeout || 2
      end
    end
  end
end
