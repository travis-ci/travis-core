require 'spec_helper'
require 'active_support/core_ext/hash/slice'

describe Travis::Config do
  let(:config) { Travis::Config.load(:files, :env, :heroku, :docker) }

  describe 'endpoints' do
    it 'returns an object even without endpoints entry' do
      config.endpoints.foo.should be_nil
    end

    it 'returns endpoints if it is set' do
      ENV['travis_config'] = YAML.dump('endpoints' => { 'ssh_key' => true })
      config.endpoints.ssh_key.should be_true
    end

    it 'allows to set keys on enpoints when it is nil' do
      config.endpoints.foo.should be_nil

      config.endpoints.foo = true

      config.endpoints.foo.should be_true
    end
  end

  describe 'Hashr behaviour' do
    after :each do
      ENV.delete('travis_config')
    end

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

    it 'queue.limit.by_owner defaults to {}' do
      config.queue.limit.by_owner.should == {}
    end

    it 'queue.limit.default defaults to 5' do
      config.queue.limit.default.should == 5
    end

    it 'queue.interval defaults to 3' do
      config.queue.interval.should == 3
    end

    it 'queue.interval defaults to 3' do
      config.queue.interval.should == 3
    end

    it 'logs.shards defaults to 1' do
      config.logs.shards.should == 1
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
    after :each do
      ENV.delete('DATABASE_URL')
    end

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
    let(:data) { {} }

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

  describe 'reads custom config files' do
    before :each do
      Dir.stubs(:[]).returns ['config/travis.yml', 'config/travis/foo.yml', 'config/travis/bar.yml']
      YAML.stubs(:load_file).with('config/travis.yml').returns('test' => { 'travis' => 'travis', 'shared' => 'travis' })
      YAML.stubs(:load_file).with('config/travis/foo.yml').returns('test' => { 'foo' => 'foo' })
      YAML.stubs(:load_file).with('config/travis/bar.yml').returns('test' => { 'bar' => 'bar', 'shared' => 'bar' })
    end

    it 'still reads the default config file' do
      config.travis.should == 'travis'
    end

    it 'merges custom files' do
      config.foo.should == 'foo'
      config.bar.should == 'bar'
    end

    it 'overwrites previously set values with values loaded later' do
      config.shared.should == 'bar'
    end
  end

  describe 'loads docker-style env vars' do
    after :each do
      %w(POSTGRESQL_PORT RABBITMQ_PORT REDIS_PORT).each do |key|
        ENV.delete(key)
      end
    end

    describe 'loads POSTGRESQL_PORT to config.database' do
      before :each do
        ENV['POSTGRESQL_PORT'] = 'tcp://172.17.0.11:5432'
      end

      it 'loads host and port from the env var' do
        config.database.values_at(:host, :port).should == ['172.17.0.11', '5432']
      end

      it 'keeps adapter, database, encoding from the regular config' do
        config.database.values_at(:adapter, :database, :encoding).should == ['postgresql', 'travis_test', 'unicode']
      end
    end

    describe 'loads RABBITMQ_PORT to config.amqp' do
      before :each do
        ENV['RABBITMQ_PORT'] = 'tcp://172.17.0.11:5672'
      end

      it 'loads host and port from the env var' do
        config.amqp.values_at(:host, :port).should == ['172.17.0.11', '5672']
      end

      it 'keeps username, password, prefetch from the regular config' do
        config.amqp.values_at(:username, :password, :prefetch).should == ['guest', 'guest', 1]
      end
    end

    it 'loads REDIS_PORT' do
      ENV['REDIS_PORT'] = 'tcp://172.17.0.7:6379'
      config.redis.should == { url: 'tcp://172.17.0.7:6379' }
    end
  end

  it 'deep symbolizes arrays, too' do
    config = Travis::Config.new('queues' => [{ 'slug' => 'rails/rails', 'queue' => 'rails' }])
    config.queues.first.values_at(:slug, :queue).should == ['rails/rails', 'rails']
  end
end

