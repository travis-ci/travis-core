class Worker
  module Repository
    def redis
      Travis.redis
    end

    def create(attrs = {})
      worker = Worker.new(random_id, normalize(attrs))
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
      keys = redis.smembers('workers').select { |key| redis.exists(key) }
      keys.each { |key| Worker.new(key.split(':').last).notify(:remove) }
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

      def random_id
        SecureRandom.hex(16)
      end

    extend self
  end
end
