require 'hashr'
require 'yaml'
require 'active_support/core_ext/object/blank'
require 'core_ext/hash/deep_symbolize_keys'

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
       ENV['ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      end

      def load_env
        @load_env ||= YAML.load(ENV['travis_config']) if ENV['travis_config']
      end

      def load_file
        @load_file ||= YAML.load_file(filename)[env] if File.exists?(filename) rescue {}
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
        data.merge!(:database => database_from_env) if database_env_url
        data
      end
    end

    define  :host          => 'travis-ci.org',
            :shorten_host  => 'trvs.io',
            :amqp          => { :username => 'guest', :password => 'guest', :host => 'localhost', :prefetch => 1 },
            :database      => { :adapter => 'postgresql', :database => "travis_#{Travis::Config.env}", :encoding => 'unicode', :min_messages => 'warning' },
            :airbrake      => { :key => 'airbrake-api_key' },
            :pusher        => { :app_id => 'app-id', :key => 'key', :secret => 'secret' },
            :smtp          => { :user_name => 'postmark-api_key' },
            :github        => { :username => 'travisbot', :password => 'password' },
            :async         => {},
            :notifications => [],
            :queues        => [],
            :workers       => { :prune => { :after => 15, :interval => 5 } },
            :jobs          => { :retry => { :after => 60 * 60 * 2, :max_attempts => 1, :interval => 60 * 5 } },
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
      self.class.env
    end

    def http_host
      "http://#{host}"
    end

    def http_shorten_host
      "http://#{shorten_host}"
    end
  end
end
