require 'faraday'

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

    def http
      @http ||= Faraday.new(http_options) do |f|
        f.request :url_encoded
        f.adapter :net_http
      end
    end

    def http_options
      ssl = Travis.config.ssl
      options = {}
      options[:ssl] = { :ca_path => ssl.ca_path } if ssl.ca_path
      options[:ssl] = { :ca_file => ssl.ca_file } if ssl.ca_file
      options
    end
  end
end
