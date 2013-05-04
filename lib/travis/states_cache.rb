require 'dalli'
require 'active_support/core_ext/module/delegation'

module Travis
  class StatesCache
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
      attr_reader :client

      def initialize(options = {})
        @client = options[:client] || Dalli::Client.new(Travis.config.states_cache.memcached)
      end

      def fetch(id, branch = nil)
        data = client.get(key(id, branch))
        data ? JSON.parse(data) : nil
      end

      def write(id, branch, data)
        finished_at = data['finished_at']
        data        = data.to_json

        client.set(key(id), data) if update?(id, nil, finished_at)
        client.set(key(id, branch), data) if update?(id, branch, finished_at)
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
    end

    attr_reader :adapter

    delegate :fetch, :to => :adapter

    def initialize(options = {})
      @adapter = options[:adapter] || MemcachedAdapter.new
    end

    def write(id, branch, build)
      data = {
        finished_at: build.finished_at.to_s,
        state: build.state
      }.stringify_keys

      adapter.write(id, branch, data)
    end
  end
end
