require 'spec_helper'
require 'active_support/core_ext/hash/slice'

describe Travis::Config do
  let(:config) { Travis::Config.new }

  after :each do
    ENV.delete('DATABASE_URL')
    ENV.delete('travis_config')
    Travis.instance_variable_set(:@config, nil)
  end

  describe 'Hashr behaviour' do
    it 'is a Hashr instance' do
      config.should be_kind_of(Hashr)
    end

    it 'returns Hashr instances on subkeys' do
      ENV['travis_config'] = YAML.dump('redis' => { 'url' => 'redis://localhost:6379' })
      config.redis.should be_kind_of(Hashr)
    end

    it 'returns Hashr instances on subkeys that were set to Ruby Hashes' do
      config.foo = { :bar => { :baz => 'baz' } }
      config.foo.bar.should be_kind_of(Hashr)
    end
  end

  describe 'defaults' do
    it 'notifications defaults to []' do
      config.notifications.should == []
    end

    it 'notifications.email defaults to {}' do
      config.email.should == {}
    end

    it 'queues defaults to []' do
      config.queues.should == []
    end

    it 'ampq.host defaults to "localhost"' do
      config.amqp.host.should == 'localhost'
    end

    it 'ampq.prefetch defaults to 1' do
      config.amqp.prefetch.should == 1
    end

    it 'jobs.queue.limit.by_owner defaults to {}' do
      config.jobs.queue.limit.by_owner.should == {}
    end

    it 'jobs.queue.limit.default defaults to 5' do
      config.jobs.queue.limit.default.should == 5
    end

    it 'jobs.queue.interval defaults to 3' do
      config.jobs.queue.interval.should == 3
    end

    it 'jobs.queue.interval defaults to 3' do
      config.jobs.queue.interval.should == 3
    end

    it 'database' do
      config.database.should == {
        :adapter => 'postgresql',
        :database => 'travis_test',
        :encoding => 'unicode',
        :min_messages => 'warning'
      }
    end
  end

  describe 'using DATABASE_URL for database configuration if present' do
    it 'works when given a url with a port' do
      ENV['DATABASE_URL'] = 'postgres://username:password@hostname:port/database'

      config.database.to_hash.slice(:adapter, :host, :port, :database, :username, :password).should == {
        :adapter => 'postgresql',
        :host => 'hostname',
        :port => 'port',
        :database => 'database',
        :username => 'username',
        :password => 'password'
      }
    end

    it 'works when given a url without a port' do
      ENV['DATABASE_URL'] = 'postgres://username:password@hostname/database'

      config.database.to_hash.slice(:adapter, :host, :port, :database, :username, :password).should == {
        :adapter => 'postgresql',
        :host => 'hostname',
        :database => 'database',
        :username => 'username',
        :password => 'password'
      }
    end
  end

  describe 'the example config file' do
    let(:data)    { {} }
    before(:each) { Travis::Config.stubs(:load_file).returns(data) }

    it 'can access pusher' do
      lambda { config.pusher.key }.should_not raise_error
    end

    it 'can access all keys recursively' do
      nested_access = lambda do |config, data|
        data.keys.each do |key|
          lambda { config.send(key) }.should_not raise_error
          nested_access.call(config.send(key), data[key]) if data[key].is_a?(Hash)
        end
      end
      nested_access.call(config, data)
    end
  end

  it 'deep symbolizes arrays, too' do
    config = Travis::Config.new('queues' => [{ 'slug' => 'rails/rails', 'queue' => 'rails' }])
    config.queues.first.values_at(:slug, :queue).should == ['rails/rails', 'rails']
  end
end

