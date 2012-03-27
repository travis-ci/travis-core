require 'redis'
require 'rollout'
require 'active_support/deprecation'
require 'active_support/core_ext/module'

module Travis
  module Features
    mattr_accessor :redis, :rollout
    class << self
      methods = (Rollout.public_instance_methods(false) - [:active?, "active?"]) << {:to => :rollout}
      delegate(*methods)
    end

    def start
      url = Travis.config.redis_url || ENV['REDISTOGO_URL'] || 'redis://localhost:6379'
      self.redis ||= ::Redis.connect(:url => url)
      self.rollout ||= ::Rollout.new(redis)
    end

    def stop
      self.redis = self.rollout = nil
    end

    def active?(feature, repository)
      repository_active?(feature, repository) or
        rollout.active?(feature, repository.owner)
    end

    def activate_repository(feature, repository)
      redis.sadd(repository_key(feature), repository.id)
    end

    def deactivate_repository(feature, repository)
      redis.srem(repository_key(feature), repository.id)
    end

    def repository_active?(feature, repository)
      redis.sismember(repository_key(feature), repository.id) 
    end

    extend self

    private

    def key(name)
      "feature:#{name}"
    end

    def repository_key(feature)
      "#{key(feature)}:repositories"
    end

  end
end
