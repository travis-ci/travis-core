require 'spec_helper'
require 'support/active_record'
require 'support/mocks/pusher'

describe Travis::Notifications::Handler::Pusher do
  include Support::ActiveRecord

  let(:channel)   { Support::Mocks::Pusher::Channel.new }
  let(:handler)   { Travis::Notifications::Handler::Pusher.new }
  let(:build)     { Factory(:build) }
  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }
  let(:worker)    { Factory.build(:worker) }

  before do
    Travis.config.notifications = [:pusher]
    Pusher.stubs(:[]).returns(channel)
  end

  describe 'subscription' do
    it 'job:configure:created' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify).never
      Travis::Notifications.dispatch('job:configure:created', configure)
    end

    it 'job:configure:finished' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify).never
      Travis::Notifications.dispatch('job:configure:finished', configure)
    end

    it 'job:test:created' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('job:test:created', test)
    end

    it 'job:test:started' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('job:test:started', test)
    end

    it 'job:log' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('job:test:log', test)
    end

    it 'job:test:finished' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('job:test:finished', test)
    end

    it 'build:started' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('build:started', build)
    end

    it 'build:finished' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('build:finished', build)
    end

    it 'worker:started' do
      Travis::Notifications::Handler::Pusher.any_instance.expects(:notify)
      Travis::Notifications.dispatch('worker:started', worker)
    end
  end

  describe 'subscription' do
    it 'job:test:created' do
      handler.notify('job:test:created', test)
      channel.should have_message('job:created', test)
    end

    it 'job:test:started' do
      handler.notify('job:test:started', test)
      channel.should have_message('job:started', test)
    end

    it 'job:log' do
      handler.notify('job:test:log', test)
      channel.should have_message('job:log', test)
    end

    it 'job:test:finished' do
      handler.notify('job:test:finished', test)
      channel.should have_message('job:finished', test)
    end

    it 'build:started' do
      handler.notify('build:started', build)
      channel.should have_message('build:started', build)
    end

    it 'build:finished' do
      handler.notify('build:finished', build)
      channel.should have_message('build:finished', build)
    end

    it 'worker:started' do
      handler.notify('worker:started', worker)
      channel.should have_message('worker:started', worker)
    end
  end

  describe 'channels_for' do
    it 'returns "common" for the event "job:created"' do
      handler.send(:channels_for, 'job:created', test).should include('common')
    end

    it 'returns "common" for the event "job:started"' do
      handler.send(:channels_for, 'job:started', test).should include('common')
    end

    it 'returns "job-1" for the event "job:log"' do
      handler.send(:channels_for, 'job:log', test).should include("job-#{test.id}")
    end

    it 'returns "common" for the event "job:finished"' do
      handler.send(:channels_for, 'job:finished', test).should include('common')
    end

    it 'returns "common" for the event "build:started"' do
      handler.send(:channels_for, 'build:started', build).should include('common')
    end

    it 'returns "common" for the event "build:finished"' do
      handler.send(:channels_for, 'build:finished', build).should include('common')
    end

    it 'returns "common" for the event "worker:started"' do
      handler.send(:channels_for, 'worker:created', build).should include('common')
    end
  end
end
