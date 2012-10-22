require 'faraday'
require 'core_ext/hash/compact'
require 'active_support/core_ext/string'

module Travis
  class Task
    autoload :Archive,            'travis/task/archive'
    autoload :Campfire,           'travis/task/campfire'
    autoload :Email,              'travis/task/email'
    autoload :Flowdock,           'travis/task/flowdock'
    autoload :Github,             'travis/task/github'
    autoload :GithubCommitStatus, 'travis/task/github_commit_status'
    autoload :Hipchat,            'travis/task/hipchat'
    autoload :Irc,                'travis/task/irc'
    autoload :Pusher,             'travis/task/pusher'
    autoload :Webhook,            'travis/task/webhook'

    module Shared
      autoload :Template,         'travis/task/shared/template'
    end

    include Logging
    extend  Instrumentation, NewRelic, Exceptions::Handling, Async

    class << self
      extend Exceptions::Handling

      def run(type, *args)
        Travis::Async.run(self, :perform, { :queue => type, :use => async_strategy }, type, *args)
      end

      def async_strategy
        Travis::Features.feature_inactive?(:travis_tasks) ? :threaded : :sidekiq
      end

      def perform(type, *args)
        const_get(type.to_s.camelize).new(*args).run
      end
      rescues :perform, :from => Exception
    end

    attr_reader :data, :options

    def initialize(data, options = {})
      @data = data
      @options = options.symbolize_keys
    end

    def run
      process
    end
    # rescues    :run, :from => Exception
    instrument :run
    new_relic  :run, :category => :task

    private

      def http
        @http ||= Faraday.new(http_options) do |f|
          f.request :url_encoded
          f.adapter :net_http
        end
      end

      def http_options
        { :ssl => Travis.config.ssl.compact }
      end
  end
end
