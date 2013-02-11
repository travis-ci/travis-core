require 'spec_helper'

describe Travis::RedisPool do
  let(:redis) {Travis::RedisPool.new}
  let(:unpooled_redis) {Redis.new}

  it "increases the metric for number of operations" do
    expect {
      redis.get('test')
    }.to change {Metriks.timer('redis.operations').count}.by(1)
  end

  it "forwards operations to redis" do
    redis.set("some-key", 100)
    unpooled_redis.get('some-key').should == "100"
  end

  it "fails when a non-supported operation is called" do
    expect {
      redis.setssss
    }.to raise_error
  end

  it "adds a wait time for the pool checkout" do
    expect {
      redis.get('test')
    }.to change{Metriks.timer('redis.pool.wait').count}.by(1)
  end
end
