module Support
  module Redis
    extend ActiveSupport::Concern

    included do
      let(:redis)  { Travis.redis }
      after(:each) { redis.flushall }
    end
  end
end
