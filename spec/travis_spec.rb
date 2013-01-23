require 'spec_helper'

describe Travis do
  describe "redis" do
    before do
      Travis.redis = nil
    end

    it "should connect to localhost by default" do
      Travis.start
      client = Travis.redis.client
      client.host.should == 'localhost'
      client.port.should == 6379
    end

    describe "with Travis.config" do
      before do
        Travis.config.redis = { url: 'redis://127.0.0.1:6379' }
      end

      after do
        Travis.config.redis_url = nil
      end

      it "should use the Travis.config if set" do
        Travis.start
      end
    end
  end
end
