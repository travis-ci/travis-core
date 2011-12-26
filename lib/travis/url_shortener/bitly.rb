require 'faraday'
require 'multi_json'
require 'hashr'

module Travis
  module UrlShortener
    class Bitly
      attr_reader :config, :http_config

      class << self
        def create
          new(Travis.config.bitly, { :ssl => Travis.config.ssl })
        end
      end

      def initialize(config = {}, http_config = {})
        @config = Hashr.new(config)
        @http_config = Hashr.new(http_config)
      end

      def shorten(url, options = {})
        response = connection.get('shorten') do |req|
          req.params = { :longUrl => url }
        end

        body = MultiJson.decode(response.body)

        if !!options[:return_response]
          body
        else
          body['data']['url']
        end
      rescue StandardError => e
        url
      end

      def connection
        @connection ||= Faraday.new(http_options)
      end

      protected

      def http_options
        options = { :url => 'http://api.bitly.com/v3' }

        if config && config.api_key && config.login
          options[:params] = {
            :apiKey => config.api_key,
            :login  => config.login
          }
        end

        if ssl = http_config.ssl
          options[:ssl] = { :ca_path => ssl.ca_path } if ssl.ca_path
          options[:ssl] = { :ca_file => ssl.ca_file } if ssl.ca_file
        end

        options
      end
    end
  end
end