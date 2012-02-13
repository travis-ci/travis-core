require 'hashr'
require 'yaml'
require 'active_support/core_ext/object/blank'

module Travis
  class Config < Hashr
    class << self
      def env
       defined?(Rails) ? Rails.env : ENV['ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
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
    end

    define  :host     => 'http://travis-ci.org',
            :amqp     => { :username => 'guest', :password => 'guest', :host => 'localhost', :prefetch => 1 },
            :database => { :adapter => 'postgresql', :database => "travis_#{Travis::Config.env}", :encoding => 'unicode', :min_messages => 'warning' },
            :airbrake => { :key => 'airbrake-api_key' },
            :pusher   => { :app_id => 'app-id', :key => 'key', :secret => 'secret' },
            :smtp     => { :user_name => 'postmark-api_key' },
            :async    => {},
            :notifications => [],
            :queues   => [],
            :workers  => { :prune => { :after => 15, :interval => 5 } },
            :jobs     => { :retry => { :after => 60 * 60 * 2, :max_attempts => 1, :interval => 60 * 5 } },
            :archive  => {},
            :ssl      => {},
            :sponsors => { :platinum => [], :gold => [], :workers => {} }

    default :_access => [:key]

    def initialize(data = nil, *args)
      data ||= self.class.load_env || self.class.load_file || {}
      data.merge! :database => self.class.database_from_env if self.class.database_env_url
      super
    end

    def env
      self.class.env
    end
  end
end
