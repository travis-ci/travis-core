require 'faraday'
require 'hashr'
require 'yaml'

require 'active_support/core_ext/object/blank'
require 'core_ext/hash/deep_symbolize_keys'
require 'core_ext/kernel/run_periodically'

# Encapsulates the configuration necessary for travis-core.
#
# Configuration values will be read from
#
#  * either ENV['travis_config'] (this variable is set on Heroku by `travis config [env]`,
#    see travis-cli) or
#  * a local file config/travis.yml which contains the current env key (e.g. development,
#    production, test)
#
# The env key can be set through various ENV variables, see Travis::Config.env.
#
# On top of that the database configuration can be overloaded by setting a database URL
# to ENV['DATABASE_URL'] or ENV['SHARED_DATABASE_URL'] (which is something Heroku does).
module Travis
  class Config < Hashr
    class << self
      def env
        puts "[DEPRECATED] Travis::Config.env is deprecated. Please use Travis.env."
        Travis.env
      end

      def load_env
        @load_env ||= YAML.load(ENV['travis_config']) if ENV['travis_config']
      end

      def load_file
        @load_file ||= YAML.load_file(filename)[Travis.env] if File.exists?(filename) rescue {}
      end

      def filename
        @filename ||= File.expand_path('config/travis.yml')
      end

      def database_env_url
        ENV.values_at('DATABASE_URL', 'SHARED_DATABASE_URL').first
      end

      def database_from_env
        url = database_env_url
        url ? parse_database_url(url) : {}
      end

      def parse_database_url(url)
        if url =~ %r((.+?)://(.+):(.+)@([^:]+):?(.*)/(.+))
          database = $~.to_a.last
          adapter, username, password, host, port = $~.to_a[1..-2]
          adapter = 'postgresql' if adapter == 'postgres'
          { :adapter => adapter, :username => username, :password => password, :host => host, :database => database }.tap do |config|
            config.merge!(:port => port) unless port.blank?
          end
        else
          {}
        end
      end

      def normalize(data)
        data.deep_symbolize_keys!
        (data[:database] ||= {}).merge!(database_from_env) if database_env_url
        data
      end
    end

    HOSTS = {
      :production  => 'travis-assets.herokuapp.com',
      :staging     => 'travis-assets-staging.herokuapp.com',
      :development => 'localhost:3000'
    }

    include Logging

    define  :host          => 'travis-ci.org',
            :shorten_host  => 'trvs.io',
            :assets        => { :host => HOSTS[Travis.env.to_sym], :version => defined?(Travis::Assets) ? Travis::Assets.version : 'asset-id', :interval => 15 },
            :amqp          => { :username => 'guest', :password => 'guest', :host => 'localhost', :prefetch => 1 },
            :database      => { :adapter => 'postgresql', :database => "travis_#{Travis.env}", :encoding => 'unicode', :min_messages => 'warning' },
            :pusher        => { :app_id => 'app-id', :key => 'key', :secret => 'secret' },
            :sidekiq       => { :namespace => 'sidekiq', :pool_size => 1 },
            :smtp          => { :user_name => 'postmark-api_key' },
            :github        => { :token => 'travisbot-token' },
            :async         => {},
            :notifications => [], # TODO rename to event.handlers
            :queues        => [],
            :workers       => { :prune => { :after => 15, :interval => 5 } },
            :jobs          => { :retry => { :after => 60 * 60 * 2, :max_attempts => 1, :interval => 60 * 5 } },
            :queue         => { :limit => { :default => 5, :by_owner => {} }, :interval => 3 },
            :logs          => { :shards => 1 },
            :email         => {},
            :archive       => {},
            :ssl           => {},
            :sponsors      => { :platinum => [], :gold => [], :workers => {} },
            :redis         => { :url => ENV['REDISTOGO_URL'] || 'redis://localhost:6379' }

    default :_access => [:key]

    def initialize(data = nil, *args)
      data = self.class.normalize(data || self.class.load_env || self.class.load_file || {})
      super
    end

    def env
      puts "[DEPRECATED] Travis.config.env is deprecated. Please use Travis.env."
      Travis.env
    end

    def http_host
      "http://#{host}"
    end

    def http_shorten_host
      "http://#{shorten_host}"
    end

    def update_periodically
      update
      run_periodically(Travis.config.assets.interval, &method(:update))
    end

    protected

      def update
        version = fetch
        if version && assets.version != version
          self.assets.version = version
          puts "[asset-version] Updated asset version from http://#{Travis.config.assets.host}/current to #{assets.version}"
        end
      end

      def fetch
        response = http_client.get("http://#{Travis.config.assets.host}/current")
        if response.success?
          response.body
        else
          log_error "Could not retrieve asset version (#{response[:status]} #{response[:body]})."
          nil
        end
      rescue Faraday::Error::ClientError => e
        log_error "Could not retrieve asset version (#{e.inspect})."
      end

      def http_client
        @http_client ||= Faraday.new do |f|
          f.request :url_encoded
          f.adapter :net_http
        end
      end
  end
end
