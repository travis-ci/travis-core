require 'redis'
require 'multi_json'

module Travis
  module Notification
    module Publisher
      class Redis
        extend Exceptions::Handling
        attr_accessor :redis, :ttl

        def initialize(options = {})
          @redis = options[:redis] || ::Redis.connect(url: Travis.config.redis.url)
          @ttl   = options[:ttl]   || 10
        end

        def publish(event)
          payload = MultiJson.encode(event)
          list    = 'events:' << event[:uuid]

          redis.publish list, payload

          # redis.pipelined do
          #   redis.publish list, payload
          #   redis.multi do
          #     redis.persist(list)
          #     redis.rpush(list, payload)
          #     redis.expire(list, ttl)
          #   end
          # end
        end

        rescues :publish, from: Exception
      end
    end
  end
end
