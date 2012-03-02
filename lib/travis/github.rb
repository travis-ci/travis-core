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
      attr_accessor :connection, :headers, :api_host

      def initialize(options = {})
        token     = options[:token]
        username  = options[:username]
        password  = options[:password]
        @api_host = options[:api_host] || 'https://api.github.com'
        @headers  = options[:headers].try(:dup)  || {
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

      def api_url?(url)
        url.start_with? "/" or url.start_with? api_host
      end

      def get(url, &block)
        notify("get.github", url) { connection.get(url, headers, &block) }.body
      end
    end

    class Resource
      attr_accessor :url, :api_url, :loaded, :session, :_links

      alias public_send send unless method_defined? :public_send
      alias loaded? loaded

      def self.attribute(*names, &block)
        names.each do |name|
          name = name.to_s
          define_method("#{name}=") do |value|
            attributes.delete name
            raw_attributes[name] = value
          end

          define_method(name) do |*a|
            public_send("#{name}=", *a) if a.size > 0
            @current_method = name
            load unless attributes.include? name or raw_attributes.include? name
            attributes[name] ||= begin
              value = raw_attributes[name]
              value = instance_exec(value, &block) if block and value
              value
            end
          end
        end
      end

      def self.new(obj, *)
        self === obj ? obj : super
      end

      def initialize(options = {})
        @loaded = false
        set options
      end

      def session
        @session || Travis::Github.session
      end

      def url=(value)
        self.api_url = value unless value.start_with? "https:\/\/github.com"
        @url = value
      end

      def api_url
        @api_url ||= default_url
      end

      def set(options)
        raise ArgumentError, "no options given" unless options
        options.each_pair { |k, v| raw_attributes[k.to_s] = v }
        options.each_pair { |k, v| public_send "#{k}=", v if respond_to? "#{k}=" }
      end

      def payload=(raw)
        raw = ActiveSupport::JSON.decode(raw.to_str) if raw.respond_to? :to_str
        set raw
      end

      def load
        load! unless loaded?
      end

      def load!
        fail "resource URL unkown for #{inspect}" unless api_url
        @loaded = true
        self.payload = session.get(api_url)
      end

      private

        def default_url
          return _links['self']['href'] if _links and _links['self']
          url if url and session.api_url?
        end

        def raw_attributes
          @raw_attributes ||= {}
        end

        def attributes
          @attributes ||= {}
        end
    end

    class Commit < Resource
      attribute :sha
      attribute(:repository) { |r| Repository.new(r) }

      def initialize(data = {}, repository = nil)
        data = {:sha => data.to_str} if data.respond_to? :to_str
        self.repository = repository if repository
        super data
      end

      def default_url
        "#{repository.url}/commits/#{sha}"
      end

      def commit=(data)
        set data
      end
    end
    class User < Resource
      attribute(:login, :email)
      alias name login
      alias name= login

      def initialize(data = {})
        data = {:login => data.to_str} if data.respond_to? :to_str
        super data
      end

      def default_url
        "/users/#{login}"
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
