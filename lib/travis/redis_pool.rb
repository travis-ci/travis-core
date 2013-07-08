require 'connection_pool'
require 'redis'
require 'metriks'
 
module Travis
  class RedisPool
    attr_reader :pool

    def initialize(options = {})
      @options = options.delete(:pool) || {}
      @options[:size] ||= 10
      @options[:timeout] ||= 10
      @pool = ConnectionPool.new(@options) do
        ::Redis.new(@options)
      end
    end
   
    def method_missing(name, *args)
      timer = Metriks.timer('redis.pool.wait').time
      @pool.with do |redis|
        timer.stop
        if redis.respond_to?(name)
          Metriks.timer("redis.operations").time do
            redis.send(name, *args)
          end
        else
          super
        end
      end
    end
  end
end
