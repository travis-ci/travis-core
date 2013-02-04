require 'faraday'
require 'core_ext/hash/compact'
require 'core_ext/hash/deep_symbolize_keys'
require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute'

module Travis
  class Task
    include Logging
    extend  Instrumentation, NewRelic, Exceptions::Handling, Async

    class_attribute :run_local

    class << self
      extend Exceptions::Handling

      def run(queue, *args)
        Travis::Async.run(self, :perform, { queue: queue, use: run_local? ? :threaded : :sidekiq }, *args)
      end

      def run_local?
        !!run_local || Travis::Features.feature_inactive?(:travis_tasks)
      end

      def perform(*args)
        new(*args).run
      end
      rescues :perform, from: Exception
    end

    attr_reader :payload, :params

    def initialize(payload, params = {})
      @payload = payload.deep_symbolize_keys
      @params  = params.deep_symbolize_keys
    end

    def run
      process
    end
    instrument :run

    private

      def repository
        @repository ||= payload[:repository]
      end

      def job
        @job ||= payload[:job]
      end

      def build
        @build ||= payload[:build]
      end

      def request
        @request ||= payload[:request]
      end

      def commit
        @commit ||= payload[:commit]
      end

      def pull_request?
        build[:pull_request]
      end

      def http
        @http ||= Faraday.new(http_options) do |f|
          f.request :url_encoded
          f.adapter :net_http
        end
      end

      def http_options
        { ssl: Travis.config.ssl.compact }
      end
  end
end
