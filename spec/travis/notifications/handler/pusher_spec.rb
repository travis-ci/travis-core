require 'spec_helper'
require 'support/active_record'
require 'support/mocks/pusher'

describe Travis::Notifications::Handler::Pusher do
  include Support::ActiveRecord

  let(:channel)   { Support::Mocks::Pusher::Channel.new }
  let(:receiver)  { Travis::Notifications::Handler::Pusher.new }
  let(:build)     { Factory(:build, :config => { :rvm => ['1.8.7', '1.9.2'] }) }
  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }
  let(:worker)    { Factory(:worker) }

  before do
    Travis.config.notifications = [:pusher]
    Travis::Notifications::Handler::Pusher.send(:public, :channels_for, :payload_for)
    Pusher.stubs(:[]).returns(channel)
  end

  # TODO these don't actually match the full behaviour, see Notifications::Handler::Pusher#client_event_for
  describe 'sends a message to pusher' do
    before :each do
      build
    end

    # it 'job:configure:created' do
    #   Travis::Notifications.dispatch('job:configure:created', configure)
    #   channel.should have_message('job:created', configure)
    # end

    # it 'job:configure:finished' do
    #   Travis::Notifications.dispatch('job:configure:finished', configure)
    #   channel.should have_message('job:finished', configure)
    # end

    it 'job:test:created' do
      Travis::Notifications.dispatch('job:test:created', test)
      channel.should have_message('job:created', test)
    end

    it 'job:test:started' do
      Travis::Notifications.dispatch('job:test:started', test)
      channel.should have_message('job:started', test)
    end

    it 'job:log' do
      Travis::Notifications.dispatch('job:test:log', test)
      channel.should have_message('job:log', test)
    end

    it 'job:test:finished' do
      Travis::Notifications.dispatch('job:test:finished', test)
      channel.should have_message('job:finished', test)
    end

    it 'build:started' do
      Travis::Notifications.dispatch('build:started', build)
      channel.should have_message('build:started', build)
    end

    it 'build:finished' do
      Travis::Notifications.dispatch('build:finished', build)
      channel.should have_message('build:finished', build)
    end

    it 'worker:started' do
      Travis::Notifications.dispatch('worker:started', worker)
      channel.should have_message('worker:started', worker)
    end
  end

  describe 'payload_for returns the payload required for client side job events' do
    it 'job:created' do
      receiver.payload_for('job:created', test).keys.should == %w(id build_id repository_id number queue)
    end

    it 'job:started' do
      receiver.payload_for('job:started', test).keys.should == %w(id build_id started_at worker sponsor)
    end

    it 'job:log' do
      receiver.payload_for('job:log', test, 'log' => 'foo').keys.should == %w(id log)
    end

    it 'job:finished' do
      receiver.payload_for('job:finished', test).keys.should == %w(id build_id finished_at result)
    end

    it 'build:started' do
      receiver.payload_for('build:started', build).keys.should == %w(build repository)
    end

    it 'build:finished' do
      receiver.payload_for('build:finished', build).keys.should == %w(build repository)
    end

    it 'worker:started' do
      receiver.payload_for('worker:started', worker).keys.should == %w(id host name state payload last_error)
    end
  end

  describe 'channels_for' do
    it 'returns "common" for the event "job:created"' do
      receiver.channels_for('job:created', test).should include('common')
    end

    it 'returns "common" for the event "job:started"' do
      receiver.channels_for('job:started', test).should include('common')
    end

    it 'returns "job-1" for the event "job:log"' do
      receiver.channels_for('job:log', test).should include("job-#{test.id}")
    end

    it 'returns "common" for the event "job:finished"' do
      receiver.channels_for('job:finished', test).should include('common')
    end

    it 'returns "common" for the event "build:started"' do
      receiver.channels_for('build:started', build).should include('common')
    end

    it 'returns "common" for the event "build:finished"' do
      receiver.channels_for('build:finished', build).should include('common')
    end

    it 'returns "common" for the event "worker:started"' do
      receiver.channels_for('worker:created', build).should include('common')
    end
  end
end

