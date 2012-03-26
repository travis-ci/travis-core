require 'redis'
require 'rollout'
require 'active_support/deprecation'
require 'active_support/core_ext/module'

module Travis
  module Features
    mattr_accessor :redis, :rollout
    class << self
      methods = Rollout.public_instance_methods(false) << {:to => self}
      delegate(*methods)
    end

    def self.start
      url = ENV['REDISTOGO_URL'] || 'redis://localhost:6379'
      self.redis ||= ::Redis.connect(:url => url)
      self.rollout ||= ::Rollout.new(redis)
    end
  end
end
