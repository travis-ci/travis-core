require 'redis'
require 'rollout'
require 'active_support/deprecation'
require 'active_support/core_ext/module'

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
    mattr_accessor :redis, :rollout

    class << self
      methods = (Rollout.public_instance_methods(false) - [:active?, "active?"]) << {:to => :rollout}
      delegate(*methods)
    end

    def start
      self.redis ||= ::Redis.connect(:url => Travis.config.redis.url)
      self.rollout ||= ::Rollout.new(redis)
    end

    def stop
      self.redis = self.rollout = nil
    end

    def active?(feature, repository)
      feature_active?(feature) or
        (rollout.active?(feature, repository.owner) or
          repository_active?(feature, repository))
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

    def user_active?(feature, user)
      rollout.active?(feature, user)
    end

    def activate_all(feature)
      redis.del(disabled_key(feature))
    end

    def feature_active?(feature)
      enabled_for_all?(feature) and !feature_inactive?(feature)
    end

    def feature_inactive?(feature)
      redis.get(disabled_key(feature)) != "1"
    end

    def feature_deactivated?(feature)
      redis.get(disabled_key(feature)) == '0'
    end

    def deactivate_all(feature)
      redis.set(disabled_key(feature), 0)
    end

    def enabled_for_all?(feature)
      redis.get(enabled_for_all_key(feature)) == '1'
    end

    def enable_for_all(feature)
      redis.set(enabled_for_all_key(feature), 1)
    end

    def disable_for_all(feature)
      redis.set(enabled_for_all_key(feature), 0)
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
