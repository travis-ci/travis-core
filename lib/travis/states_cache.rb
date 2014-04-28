require 'dalli'
require 'connection_pool'
require 'active_support/core_ext/module/delegation'
require 'travis/api'

module Travis
  class StatesCache
    class CacheError < StandardError; end

    include Travis::Api::Formats

    attr_reader :adapter

    delegate :fetch, :to => :adapter

    def initialize(options = {})
      @adapter = options[:adapter] || MemcachedAdapter.new
    end

    def write(id, branch, data)
      if data.respond_to?(:finished_at)
        data = {
          'finished_at' => format_date(data.finished_at),
          'state' => data.state.to_s
        }
      end

      adapter.write(id, branch, data)
    end

    def fetch_state(id, branch)
      data = fetch(id, branch)
      data['state'].to_sym if data && data['state']
    end

    class TestAdapter
      attr_reader :calls
      def initialize
        @calls = []
      end

      def fetch(id, branch)
        calls << [:fetch, id, branch]
      end

      def write(id, branch, data)
        calls << [:write, id, branch, data]
      end

      def clear
        calls.clear
      end
    end

    class MemcachedAdapter
      attr_reader :pool
      attr_accessor :jitter

      def initialize(options = {})
        @pool = ConnectionPool.new(:size => 10, :timeout => 3) do
          if options[:client]
            options[:client]
          else
            new_dalli_connection
          end
        end
        @jitter = 0.5
      end

      def fetch(id, branch = nil)
        data = get(key(id, branch))
        data ? JSON.parse(data) : nil
      end

      def write(id, branch, data)
        finished_at = data['finished_at']
        data        = data.to_json

        set(key(id), data) if update?(id, nil, finished_at)
        set(key(id, branch), data) if update?(id, branch, finished_at)
      end

      def update?(id, branch, finished_at)
        current_data = fetch(id, branch)
        return true unless current_data

        current_date = Time.parse(current_data['finished_at'])
        new_date     = Time.parse(finished_at)

        new_date > current_date
      end

      def key(id, branch = nil)
        key = "state:#{id}"
        if branch
          key << "-#{branch}"
        end
        key
      end

      private

      def new_dalli_connection
        Dalli::Client.new(Travis.config.states_cache.memcached_servers, Travis.config.states_cache.memcached_options)
      end

      def get(key)
        retry_ringerror do
          pool.with { |client| client.get(key) }
        end
      rescue Dalli::RingError => e
        Metriks.meter("memcached.connect-errors").mark
        raise CacheError, "Couldn't connect to a memcached server: #{e.message}"
      end

      def set(key, data)
        retry_ringerror do
          pool.with { |client| client.set(key, data) }
        end
      rescue Dalli::RingError => e
        Metriks.meter("memcached.connect-errors").mark
        raise CacheError, "Couldn't connect to a memcached server: #{e.message}"
      end

      def retry_ringerror
        retries = 0
        begin
          yield
        rescue Dalli::RingError
          retries += 1
          if retries <= 3
            # Sleep for up to 1/2 * (2^retries - 1) seconds
            # For retries <= 3, this means up to 3.5 seconds
            sleep(jitter * (rand(2 ** retries - 1) + 1))
            retry
          else
            raise
          end
        end
      end
    end
  end
end
