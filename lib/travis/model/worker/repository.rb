class Worker
  module Repository
    def redis
      Travis.redis
    end

    def create(attrs = nil)
      worker = Worker.new(random_id, normalize(attrs || {}))
      store(worker)
      worker.notify(:add)
      worker
    end

    def all
      redis.smembers('workers').map { |key| find(key) }.compact.sort
    end

    def count
      redis.scard('workers')
    end

    def find(id)
      attrs = redis.get(key(id))
      Worker.new(id, MultiJson.load(attrs).deep_symbolize_keys) if attrs
    end

    def update(id, attrs)
      if worker = find(id)
        worker.attrs.merge!(attrs)
        store(worker)
        worker.notify(:update)
      end
    end

    def store(worker)
      redis.set(key(worker.id), MultiJson.dump(worker.attrs))
      touch(worker.id)
      redis.sadd('workers', worker.id)
    end

    def touch(id)
      redis.expire(key(id), Travis.config.workers.ttl)
    end

    def prune
      expired_ids.each do |id|
        redis.srem('workers', id)
        Worker.new(id).notify(:remove)
      end
    end

    def ttl(id)
      redis.ttl(key(id))
    end

    private

      def key(id)
        "worker:#{id}"
      end

      def normalize(attrs)
        attrs = attrs.deep_symbolize_keys
        host, name = attrs.values_at(:host, :name)
        attrs[:full_name] ||= [host, name].join(':')
        attrs.slice(:full_name, :state, :payload)
      end

      def expired_ids
        redis.smembers('workers').reject { |id| redis.exists(key(id)) }
      end

      def random_id
        SecureRandom.hex(16)
      end

    extend self
  end
end
