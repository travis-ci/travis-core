require 'faraday'
require 'core_ext/hash/compact'
require 'active_support/core_ext/string'

module Travis
  class Task
    autoload :Archive,  'travis/task/archive'
    autoload :Campfire, 'travis/task/campfire'
    autoload :Email,    'travis/task/email'
    autoload :Github,   'travis/task/github'
    autoload :Irc,      'travis/task/irc'
    autoload :Pusher,   'travis/task/pusher'
    autoload :Request,  'travis/task/request'
    autoload :Webhook,  'travis/task/webhook'

    include Logging
    extend  Instrumentation, Exceptions::Handling, Async

    class << self
      def run(type, *args)
        const_get(type.to_s.camelize).new(*args).run
      end
    end

    def run
      process
    end

    rescues :run, :from => Exception
    instrument :run
    async :run

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
