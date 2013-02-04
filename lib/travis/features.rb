require 'redis'
require 'rollout'
require 'connection_pool'
require 'active_support/deprecation'
require 'active_support/core_ext/module'

class ::Rollout
  def redis
    @redis
  end
end

module Travis
  # Wraps feature flips for Travis.
  # This allows enabling/disabling certain features for users
  # and repositories only.
  #
  # The start method needs to be called before using this module.
  # You can then ask for features to be enabled for repositories:
  #
  # Repository.find_by_slug('rails/rails')
  # if Travis::Features.active?(:pull_requests, repository)
  #   ...
  # end
  #
  # This wraps checking if a repository is enabled and then delegates
  # to the rollout library, where features can be enabled for users,
  # groups and based on percentages.
  module Features
    def with_redis(&blk)
      if @connection_pool
        @connection_pool.with do |rollout|
          blk.call(rollout.redis)
        end
      else
        blk.call(redis)
      end
    end

    def with_rollout(&blk)
      @connection_pool.with(&blk)
    end

    def start
      @connection_pool ||= ConnectionPool.new(size: 10) {
        ::Rollout.new(Redis.new(url: Travis.config.redis.url, timeout: 10))
      } 
    end

    def redis
      Travis.redis
    end

    def active?(feature, repository)
      with_rollout do |rollout|
        feature_active?(feature) or
          (rollout.active?(feature, repository.owner) or
            repository_active?(feature, repository))
      end
    end

    def activate_repository(feature, repository)
      with_redis do |redis|
        redis.sadd(repository_key(feature), repository.id)
      end
    end

    def deactivate_repository(feature, repository)
      with_redis do |redis|
        redis.srem(repository_key(feature), repository.id)
      end
    end

    def activate_user(feature, user)
      with_rollout do |rollout|
        rollout.activate_user(feature, user)
      end
    end

    def deactivate_user(feature, user)
      with_rollout do |rollout|
        rollout.deactivate_user(feature, user)
      end
    end

    def repository_active?(feature, repository)
      with_redis do |redis|
        redis.sismember(repository_key(feature), repository.id)
      end
    end

    def user_active?(feature, user)
      with_rollout do |rollout|
        rollout.active?(feature, user)
      end
    end

    def activate_all(feature)
      with_redis do |redis|
        redis.del(disabled_key(feature))
      end
    end

    def feature_active?(feature)
      enabled_for_all?(feature) and !feature_inactive?(feature)
    end

    def feature_inactive?(feature)
      with_redis do |redis|
        redis.get(disabled_key(feature)) != "1"
      end
    end

    def feature_deactivated?(feature)
      with_redis do |redis|
        redis.get(disabled_key(feature)) == '0'
      end
    end

    def deactivate_all(feature)
      with_redis do |redis|
        redis.set(disabled_key(feature), 0)
      end
    end

    def enabled_for_all?(feature)
      with_redis do |redis|
        redis.get(enabled_for_all_key(feature)) == '1'
      end
    end

    def enable_for_all(feature)
      with_redis do |redis|
        redis.set(enabled_for_all_key(feature), 1)
      end
    end

    def disable_for_all(feature)
      with_redis do |redis|
        redis.set(enabled_for_all_key(feature), 0)
      end
    end

    extend self

    private

    def key(name)
      "feature:#{name}"
    end

    def repository_key(feature)
      "#{key(feature)}:repositories"
    end

    def disabled_key(feature)
      "#{key(feature)}:disabled"
    end

    def enabled_for_all_key(feature)
      "#{key(feature)}:disabled"
    end
  end
end
