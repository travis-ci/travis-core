require 'travis/features'
require 'spec_helper'

describe Travis::Features do
  describe "connecting" do
    before do
      Travis::Features.redis = nil
    end

    it "should connect to localhost by default" do
      Travis::Features.start
      client = Travis::Features.redis.client
      client.host.should == 'localhost'
      client.port.should == 6379
    end

    it "should set up rollout" do
      Travis::Features.start
      Travis::Features.rollout.should_not == nil
    end

    it "should delegate to rollout" do
      expect {
        Travis::Features.info(:short_urls)
      }.to_not raise_error
    end

    describe "with environment variable set" do
      before do
        ENV['REDISTOGO_URL'] = 'redis://127.0.0.1:6379'
      end

      after do
        ENV['REDISTOGO_URL'] = nil
      end

      it "should use the environment variable if available" do
        Travis::Features.start
        client = Travis::Features.redis.client
        client.host.should == '127.0.0.1'
      end
    end

    describe "with Travis.config" do
      before do
        Travis.config.redis_url = 'redis://172.0.0.1:6379'
      end

      after do
        Travis.config.redis_url = nil
      end

      it "should use the Travis.config if set" do
        Travis::Features.start
        client = Travis::Features.redis.client
        client.host.should == '172.0.0.1'
      end
    end
  end
end
