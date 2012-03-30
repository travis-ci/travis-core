require 'active_support'
require 'webmock'
require 'webmock/rspec'
require 'uri'

module Support
  module Webmock
    extend ActiveSupport::Concern

    included do
      before :each do
        Support::Webmock.mock!
      end
    end

    class MockRequest
      attr_reader :uri, :stub

      def initialize(url)
        @uri = URI.parse(url)
      end

      def filename
        @filename ||= "spec/fixtures/github/#{path}"
      end

      def path
        path = uri.path
        path += "?#{uri.query}" if uri.query
        "#{uri.host}#{path}.json"
      end

      def stub
        @stub ||= WebMock.stub_request(:get, uri.to_s).to_return(:status => 200, :body => body, :headers => {})
      end

      def body
        store unless stored?
        File.read(filename)
      end

      def store
        puts "Storing #{uri.to_s} to #{filename}."
        `curl -so #{filename} --create-dirs #{uri.to_s}`
      end

      def stored?
        File.exists?(filename)
      end
    end

    class << self
      attr_reader :requests
      attr_writer :urls

      def mock!
        @requests = Hash[*urls.map { |url| [url, MockRequest.new(url).stub] }.flatten]
      end

      def urls
        @urls ||= []
      end
    end

    def requests
      Support::Webmock.requests
    end
  end
end


