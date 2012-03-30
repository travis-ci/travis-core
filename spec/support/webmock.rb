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

    URLS = %w(
      https://api.github.com/users/svenfuchs/repos?per_page=9999
      https://api.github.com/users/svenfuchs
      https://api.github.com/users/LTe
      https://api.github.com/orgs/travis-ci
      https://github.com/api/v2/json/repos/show/svenfuchs
      http://github.com/api/v2/json/repos/show/svenfuchs/gem-release
      http://github.com/api/v2/json/repos/show/svenfuchs/minimal
      http://github.com/api/v2/json/repos/show/travis-ci/travis-ci
      http://github.com/api/v2/json/user/show/svenfuchs
      http://github.com/api/v2/json/organizations/travis-ci/public_members
      http://github.com/api/v2/json/user/show/LTe
    )

    class Request
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

      def mock!
        @requests = Hash[*URLS.map { |url| [url, Request.new(url).stub] }.flatten]
      end
    end

    def requests
      Support::Webmock.requests
    end
  end
end

