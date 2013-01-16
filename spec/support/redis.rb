module Support
  module Redis
    extend ActiveSupport::Concern

    included do
      let(:redis)  { ::Redis.new(url: Travis.config.redis.url) }
      after(:each) { redis.flushall }
    end
  end
end
