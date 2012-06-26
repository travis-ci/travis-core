require 'spec_helper'

describe Travis::Notification::Publisher::Redis do
  include Support::Notifications
  let(:redis) { Redis.connect(:url => Travis.config.redis.url) }
  let(:key) { "events:#{Travis.uuid}" }

  before do
    redis.del key
  end

  it 'adds to the list' do
    redis.llen(key).should be == 0
    publish
    redis.llen(key).should be == 1
    publish
    redis.llen(key).should be == 2
  end

  it 'sets a ttl' do
    publish
    redis.ttl(key).should be <= subject.ttl
  end

  it 'encodes the payload in json' do
    instrument(:result => 42).publish(:foo => 'bar')
    MultiJson.decode(redis.lindex(key, 0)).should be == {
      "result"  => 42,
      "message" => "",
      "uuid"    => Travis.uuid,
      "payload" => { "foo" => "bar" }
    }
  end

  it 'queues new messages on the right' do
    publish(:x => 'foo')
    publish(:x => 'bar')
    redis.lindex(key, 0).should include('foo')
    redis.lindex(key, 1).should include('bar')
  end

  it 'sends out events over pubsub' do
    event = nil

    redis.subscribe(:events) do |on|
      on.message do |channel, message|
        event = MultiJson.decode(message)
        redis.unsubscribe
      end

      on.subscribe do
        instrument(:result => 42).publish(:foo => 'bar')
      end
    end

    event.should be == {
      "result"  => 42,
      "message" => "",
      "uuid"    => Travis.uuid,
      "payload" => { "foo" => "bar" }
    }
  end
end
