require 'redis'
require 'multi_json'
require 'active_support/time'

module Travis
  module Notification
    module Publisher
      class Redis
        attr_accessor :redis, :ttl

        def initialize(options = {})
          @redis = options[:redis] || ::Redis.connect(:url => Travis.config.redis.url)
          @ttl   = options[:ttl]   || 5.days.to_i
        end

        def publish(event)
          payload = MultiJson.encode(event)
          list    = "events:" << event[:uuid]

          redis.pipelined do
            redis.publish "events", payload
            redis.multi do
              redis.persist(list)
              redis.rpush(list, payload)
              redis.expire(list, ttl)
            end
          end
        end
      end
    end
  end
end
