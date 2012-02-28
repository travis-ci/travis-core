# This will replace lib/github.rb  and lib/travis/github_api.rb
# We will take care of this after the initial version of pre-tested pull requests
#
# If you find this message here after 2012-06-30, please slap Konstantin.

require "faraday_compat"
require "travis/event_logger"

require "active_support/cache"
require "active_support/core_ext"

module Travis
  module Github
    def self.session
      Thread.current[:'Travis::Github.session'] ||= Session.new
    end

    def self.session=(session)
      session = Session.new(session.to_hash) if session.respond_to? :to_hash
      Thread.current[:'Travis::Github.session'] = session
    end

    def self.with(session)
      session, self.session = session(), session
      yield
    ensure
      self.session = session
    end

    class Session
      include Travis::EventLogger
      attr_accessor :connection, :headers

      def initialize(options = {})
        token    = options[:token]
        username = options[:username]
        password = options[:password]
        api_host = options[:api_host] || 'https://api.github.com'
        @headers = options[:headers].try(:dup)  || {
          "Origin"          => options[:origin] || "http://travis-ci.org",
          "Accept"          => "application/vnd.github.v3.raw+json," \
                               "application/vnd.github.beta.raw+json;q=0.5," \
                               "application/json;q=0.1",
          "Accept-Charset"  => "utf-8"
        }

        @connection = Faraday.new(:url => api_host) do |builder|
          builder.request(:token_auth, token)               if token
          builder.request(:basic_auth, username, password)  if username and password
          builder.request(:retry)
          builder.response(:raise_error)
          builder.adapter(options[:adapter] || :net_http)
        end
      end

      def get(url, &block)
        notify("get.github", url) { connection.get(url, headers, &block) }.body
      end
    end

    class Resource
      attr_accessor :url, :loaded, :session

      alias public_send send unless method_defined? :public_send
      alias loaded? loaded

      def self.attribute(*names)
        names.each do |name|
          name = name.to_s
          define_method("#{name}=") do |value|
            @attributes[name] = value
          end

          define_method(name) do
            load unless @attributes.include? name
            @attributes[name]
          end
        end
      end

      def self.new(obj)
        self === obj ? obj : super
      end

      def initialize(options = {})
        @loaded     = false
        @attributes = {}
        set(options)
      end

      def session
        @session || Travis::Github.session
      end

      def set(options, ignore_missing = false)
        options.each_pair { |k, v| public_send "#{k}=", v if respond_to? "#{k}=" or !ignore_missing }
      end

      def payload=(raw)
        raw = ActiveSupport::JSON.decode(raw.to_str) if raw.respond_to? :to_str
        set raw, true
      end

      def load
        load! unless loaded?
      end

      def load!
        self.payload = session.get(url)
        @loaded      = true
      end
    end

    class Repository < Resource
      attribute :name
      attribute :owner

      def initialize(data = {})
        if data.respond_to? :to_str
          login, name = data.split('/')
          data = { :url => "/repos/#{data}", :owner => { :login => login }, :name => name }
        end

        super data
      end
    end
  end
end
